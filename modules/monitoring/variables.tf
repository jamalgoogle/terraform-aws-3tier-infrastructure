variable "name" {
  type = string
}

variable "alarm_email" {
  description = "Email that receives alarm notifications (must confirm the subscription). Empty = none."
  type        = string
  default     = ""
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "web_asg_name" {
  type = string
}

variable "app_asg_name" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "cache_replication_group_id" {
  type = string
}

variable "cpu_threshold" {
  type    = number
  default = 80
}
