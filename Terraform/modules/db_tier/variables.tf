variable "vpc_id" {}
variable "private_subnet_id" {}
variable "app_security_group_id" {}

# modules/db_tier/outputs.tf
output "db_endpoint" {
  value = aws_db_instance.mysql.endpoint
}