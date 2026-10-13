output "alb_dns_name" {
  description = "Open this in a browser (or use www.<domain> when DNS is enabled)."
  value       = module.public_alb.dns_name
}

output "cloudfront_domain_name" {
  value = module.storage.cloudfront_domain_name
}

output "media_bucket" {
  value = module.storage.bucket_name
}

output "rds_endpoint" {
  value = module.rds.address
}

output "rds_secret_arn" {
  value = module.rds.secret_arn
}

output "cache_endpoint" {
  value = module.cache.primary_endpoint
}

output "dynamodb_table" {
  value = module.dynamodb.table_name
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}
