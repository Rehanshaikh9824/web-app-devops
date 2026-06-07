variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "admin_ip_cidr" {
  description = "Your IP CIDR for bastion SSH access (e.g. 203.0.113.5/32)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for bastion host"
  type        = string
}

variable "alert_email" {
  description = "Email address for CloudWatch SNS alerts"
  type        = string
}
