variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  description = "AMI id, or an SSM parameter reference (default = latest Amazon Linux 2023)."
  type        = string
  default     = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "cpu_target" {
  description = "Target average CPU % for scaling."
  type        = number
  default     = 60
}

variable "user_data" {
  type    = string
  default = ""
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "iam_policy_json" {
  description = "Extra inline IAM policy for the instances (tier-specific permissions)."
  type        = string
  default     = null
}
