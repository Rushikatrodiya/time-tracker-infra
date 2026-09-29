variable "rds_password" {
  type      = string
  sensitive = true
  description = "RDS admin password"
}

variable "aws_region" {
  type = string
}