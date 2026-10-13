variable "name" {
  type = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "domain_name" {
  description = "Custom domain such as media.novacart.app. Empty = use the *.cloudfront.net name."
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "Certificate in us-east-1 for domain_name. Required when domain_name is set."
  type        = string
  default     = ""
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
