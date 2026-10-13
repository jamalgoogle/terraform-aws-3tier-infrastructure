data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  name       = "${var.project}-${var.environment}"
  www_domain = "www.${var.domain_name}"
  cdn_domain = "media.${var.domain_name}"
}

# Existing hosted zone (only when DNS is enabled)
data "aws_route53_zone" "this" {
  count = var.enable_dns ? 1 : 0
  name  = var.domain_name
}

# =====================================================================
# Network + security groups
# =====================================================================
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs
}

module "security_groups" {
  source = "../../modules/security-groups"

  name     = local.name
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
}

# =====================================================================
# TLS certificates (optional)
# =====================================================================
module "acm_alb" {
  count  = var.enable_dns ? 1 : 0
  source = "../../modules/acm"

  domain_name = local.www_domain
  zone_id     = data.aws_route53_zone.this[0].zone_id
}

module "acm_cdn" {
  count  = var.enable_dns ? 1 : 0
  source = "../../modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = local.cdn_domain
  zone_id     = data.aws_route53_zone.this[0].zone_id
}

# =====================================================================
# Load balancers
# =====================================================================
# Public ALB -> web tier
module "public_alb" {
  source = "../../modules/alb"

  name                       = "${local.name}-web"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_id          = module.security_groups.alb_sg_id
  target_port                = 80
  certificate_arn            = try(module.acm_alb[0].certificate_arn, "")
  enable_deletion_protection = var.protect_resources
}

# Internal ALB: web tier -> app tier (gives web servers one stable address
# for the Auto Scaling app servers)
module "internal_alb" {
  source = "../../modules/alb"

  name                       = "${local.name}-app"
  internal                   = true
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.app_subnet_ids
  security_group_id          = module.security_groups.internal_alb_sg_id
  target_port                = var.app_port
  enable_deletion_protection = var.protect_resources
}

# =====================================================================
# Data tier
# =====================================================================
module "rds" {
  source = "../../modules/rds"

  name                    = local.name
  subnet_ids              = module.vpc.db_subnet_ids
  security_group_id       = module.security_groups.db_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  deletion_protection     = var.protect_resources
  skip_final_snapshot     = !var.protect_resources
}

module "cache" {
  source = "../../modules/elasticache"

  name              = "${local.name}-cache"
  subnet_ids        = module.vpc.db_subnet_ids
  security_group_id = module.security_groups.cache_sg_id
  node_type         = var.cache_node_type
  num_cache_nodes   = var.cache_num_nodes
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  name                = "${local.name}-data"
  deletion_protection = var.protect_resources
}

# =====================================================================
# Static content: S3 + CloudFront
# =====================================================================
module "storage" {
  source = "../../modules/s3-cloudfront"

  name                = "${local.name}-media"
  bucket_name         = "${local.name}-media-${data.aws_caller_identity.current.account_id}"
  domain_name         = var.enable_dns ? local.cdn_domain : ""
  acm_certificate_arn = try(module.acm_cdn[0].certificate_arn, "")
}

# =====================================================================
# Email (SES)
# =====================================================================
module "ses" {
  source = "../../modules/ses"

  email_identities = var.ses_email_identities
}

# =====================================================================
# Web tier (Apache) and app tier: Auto Scaling groups
# =====================================================================
data "aws_iam_policy_document" "web" {
  statement {
    sid       = "ReadMedia"
    actions   = ["s3:GetObject"]
    resources = ["${module.storage.bucket_arn}/*"]
  }
}

data "aws_iam_policy_document" "app" {
  statement {
    sid       = "Media"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.storage.bucket_arn}/*"]
  }

  statement {
    sid = "DynamoDB"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [module.dynamodb.table_arn, "${module.dynamodb.table_arn}/index/*"]
  }

  statement {
    sid       = "DatabaseSecret"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.rds.secret_arn]
  }

  dynamic "statement" {
    for_each = length(module.ses.identity_arns) > 0 ? [1] : []
    content {
      sid       = "SendEmail"
      actions   = ["ses:SendEmail", "ses:SendRawEmail"]
      resources = module.ses.identity_arns
    }
  }
}

module "web" {
  source = "../../modules/asg"

  name               = "${local.name}-web"
  subnet_ids         = module.vpc.web_subnet_ids
  security_group_ids = [module.security_groups.web_sg_id]
  instance_type      = var.web_instance_type
  min_size           = var.web_min_size
  max_size           = var.web_max_size
  desired_size       = var.web_desired_size
  target_group_arns  = [module.public_alb.target_group_arn]
  iam_policy_json    = data.aws_iam_policy_document.web.json

  user_data = templatefile("${path.module}/../../templates/web_user_data.sh.tpl", {
    app_endpoint = module.internal_alb.dns_name
  })
}

module "app" {
  source = "../../modules/asg"

  name               = "${local.name}-app"
  subnet_ids         = module.vpc.app_subnet_ids
  security_group_ids = [module.security_groups.app_sg_id]
  instance_type      = var.app_instance_type
  min_size           = var.app_min_size
  max_size           = var.app_max_size
  desired_size       = var.app_desired_size
  target_group_arns  = [module.internal_alb.target_group_arn]
  iam_policy_json    = data.aws_iam_policy_document.app.json

  user_data = templatefile("${path.module}/../../templates/app_user_data.sh.tpl", {
    app_port       = var.app_port
    region         = data.aws_region.current.name
    db_host        = module.rds.address
    db_secret_arn  = module.rds.secret_arn
    cache_host     = module.cache.primary_endpoint
    dynamodb_table = module.dynamodb.table_name
    media_bucket   = module.storage.bucket_name
  })
}

# =====================================================================
# DNS records (optional)
# =====================================================================
module "dns" {
  count  = var.enable_dns ? 1 : 0
  source = "../../modules/route53"

  zone_id = data.aws_route53_zone.this[0].zone_id

  alias_records = {
    (local.www_domain) = {
      dns_name               = module.public_alb.dns_name
      zone_id                = module.public_alb.zone_id
      evaluate_target_health = true
    }
    (local.cdn_domain) = {
      dns_name = module.storage.cloudfront_domain_name
      zone_id  = module.storage.cloudfront_zone_id
    }
  }
}

# =====================================================================
# Monitoring
# =====================================================================
module "monitoring" {
  source = "../../modules/monitoring"

  name                       = local.name
  alarm_email                = var.alarm_email
  alb_arn_suffix             = module.public_alb.arn_suffix
  target_group_arn_suffix    = module.public_alb.target_group_arn_suffix
  web_asg_name               = module.web.asg_name
  app_asg_name               = module.app.asg_name
  rds_instance_id            = module.rds.instance_id
  cache_replication_group_id = module.cache.replication_group_id
}
