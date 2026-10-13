variable "zone_id" {
  type = string
}

variable "alias_records" {
  description = "Map of record name (FQDN) => alias target."
  type = map(object({
    dns_name               = string
    zone_id                = string
    evaluate_target_health = optional(bool, false)
  }))
}
