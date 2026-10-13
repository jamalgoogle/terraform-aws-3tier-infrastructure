variable "name" {
  description = "Max 32 chars (used for ALB and target group names)."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "target_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "certificate_arn" {
  description = "If set: HTTPS listener on 443 and HTTP redirects to it. If empty: HTTP only."
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}
