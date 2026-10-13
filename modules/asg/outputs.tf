output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
