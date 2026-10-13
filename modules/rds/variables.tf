variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling (GiB)."
  type        = number
  default     = 100
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "username" {
  type    = string
  default = "appuser"
}

variable "multi_az" {
  description = "true = synchronous standby in a second AZ (as in the diagram)."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "performance_insights_enabled" {
  description = "Not supported on the smallest instance classes."
  type        = bool
  default     = false
}
