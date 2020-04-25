variable "testing_node_ip" {
  description = "The IP to be used by the testing node in CIDR notation (e.g. 2.4.22.10/32)."
  type        = string
}

variable "zone_name" {
  description = "Route53 zone name (e.g. my-awesome-domain.com)."
  type        = string
  default     = "local.app"
}

variable "role_arn" {
  description = "The role to be assumed by Terraform (e.g. arn:aws:iam::123456789012:role/Admin)."
  type        = string
}

variable "session_name" {
  description = "The session name of the assumed role."
  type        = string
  default     = "Terraform"
}
