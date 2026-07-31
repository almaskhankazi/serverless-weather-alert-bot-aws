variable "aws_region" {
  default = "us-east-1"
}

variable "alert_email" {
  description = "Email for SNS alerts"
  default     = "your-email@example.com"
}