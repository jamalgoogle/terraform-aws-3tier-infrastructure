variable "domain_name" {
  type = string
}

variable "zone_id" {
  description = "Route 53 hosted zone used for DNS validation."
  type        = string
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}
