output "identity_arns" {
  value = [for i in aws_sesv2_email_identity.this : i.arn]
}
