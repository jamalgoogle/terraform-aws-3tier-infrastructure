output "address" {
  value = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "instance_id" {
  value = aws_db_instance.this.identifier
}

output "secret_arn" {
  description = "Secrets Manager secret with the master username/password."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
