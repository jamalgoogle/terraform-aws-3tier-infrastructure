resource "aws_sesv2_email_identity" "this" {
  for_each       = toset(var.email_identities)
  email_identity = each.value
}
