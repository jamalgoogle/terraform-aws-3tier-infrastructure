# ---------- General ----------
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  description = "Lowercase, used in resource names."
  type        = string
  default     = "novacart"
}

variable "environment" {
  type = string
}

variable "protect_resources" {
  description = "true = deletion protection on ALB/RDS/DynamoDB and a final DB snapshot."
  type        = bool
  default     = false
}

# ---------- Network ----------
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

# ---------- Compute ----------
variable "app_port" {
  type    = number
  default = 8080
}

variable "web_instance_type" {
  type    = string
  default = "t3.small"
}

variable "web_min_size" {
  type    = number
  default = 1
}

variable "web_max_size" {
  type    = number
  default = 2
}

variable "web_desired_size" {
  type    = number
  default = 1
}

variable "app_instance_type" {
  type    = string
  default = "t3.small"
}

variable "app_min_size" {
  type    = number
  default = 1
}

variable "app_max_size" {
  type    = number
  default = 2
}

variable "app_desired_size" {
  type    = number
  default = 1
}

# ---------- Database ----------
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_backup_retention" {
  type    = number
  default = 7
}

# ---------- Cache ----------
variable "cache_node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "cache_num_nodes" {
  type    = number
  default = 1
}

# ---------- DNS / TLS ----------
variable "enable_dns" {
  description = "true = Route 53 records + ACM certificates (needs an existing hosted zone)."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Existing Route 53 zone, e.g. novacart.app. Used when enable_dns = true."
  type        = string
  default     = ""
}

# ---------- Notifications ----------
variable "ses_email_identities" {
  type    = list(string)
  default = []
}

variable "alarm_email" {
  type    = string
  default = ""
}
