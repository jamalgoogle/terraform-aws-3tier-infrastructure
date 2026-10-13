variable "email_identities" {
  description = "Sender email addresses to verify (AWS sends each one a confirmation link)."
  type        = list(string)
  default     = []
}
