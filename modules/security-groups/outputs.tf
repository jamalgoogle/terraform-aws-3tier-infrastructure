output "alb_sg_id" {
  value = aws_security_group.this["alb"].id
}

output "web_sg_id" {
  value = aws_security_group.this["web"].id
}

output "internal_alb_sg_id" {
  value = aws_security_group.this["internal-alb"].id
}

output "app_sg_id" {
  value = aws_security_group.this["app"].id
}

output "db_sg_id" {
  value = aws_security_group.this["db"].id
}

output "cache_sg_id" {
  value = aws_security_group.this["cache"].id
}
