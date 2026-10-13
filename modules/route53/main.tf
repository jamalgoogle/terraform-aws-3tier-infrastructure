resource "aws_route53_record" "alias" {
  for_each = var.alias_records

  zone_id = var.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = each.value.dns_name
    zone_id                = each.value.zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}
