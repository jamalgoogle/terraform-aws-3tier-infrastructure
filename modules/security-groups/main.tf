# One SG per layer. Traffic is allowed only from the layer above:
# Internet -> ALB -> web -> internal ALB -> app -> (db, cache)
locals {
  layers = toset(["alb", "web", "internal-alb", "app", "db", "cache"])
}

resource "aws_security_group" "this" {
  for_each    = local.layers
  name_prefix = "${var.name}-${each.key}-"
  description = "${each.key} layer"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name}-${each.key}" }

  lifecycle {
    create_before_destroy = true
  }
}

# ---- Internet -> public ALB ----
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.this["alb"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP from internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.this["alb"].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS from internet"
}

# ---- public ALB -> web ----
resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.this["alb"].id
  referenced_security_group_id = aws_security_group.this["web"].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.this["web"].id
  referenced_security_group_id = aws_security_group.this["alb"].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# web servers need outbound (package install via NAT, internal ALB)
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.this["web"].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---- web -> internal ALB ----
resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_web" {
  security_group_id            = aws_security_group.this["internal-alb"].id
  referenced_security_group_id = aws_security_group.this["web"].id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# ---- internal ALB -> app ----
resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id            = aws_security_group.this["internal-alb"].id
  referenced_security_group_id = aws_security_group.this["app"].id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_from_internal_alb" {
  security_group_id            = aws_security_group.this["app"].id
  referenced_security_group_id = aws_security_group.this["internal-alb"].id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.this["app"].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---- app -> db / cache ----
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.this["db"].id
  referenced_security_group_id = aws_security_group.this["app"].id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "cache_from_app" {
  security_group_id            = aws_security_group.this["cache"].id
  referenced_security_group_id = aws_security_group.this["app"].id
  from_port                    = var.cache_port
  to_port                      = var.cache_port
  ip_protocol                  = "tcp"
}
