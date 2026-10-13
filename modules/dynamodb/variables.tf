variable "name" {
  type = string
}

variable "hash_key" {
  type    = string
  default = "id"
}

variable "deletion_protection" {
  type    = bool
  default = false
}
