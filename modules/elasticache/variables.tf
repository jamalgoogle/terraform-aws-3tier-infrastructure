variable "name" {
  description = "Lowercase, max 40 chars."
  type        = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "1 = single node. 2+ = primary + replicas with automatic failover across AZs."
  type        = number
  default     = 1
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "parameter_group_name" {
  type    = string
  default = "default.redis7"
}

variable "snapshot_retention_limit" {
  type    = number
  default = 1
}
