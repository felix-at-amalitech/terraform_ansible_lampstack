variable "vpc_id" {}
variable "private_subnet_id" {}
variable "key_name" {}
variable "web_security_group_id" {}

# modules/app_tier/outputs.tf
output "app_private_ip" {
  value = aws_instance.app.private_ip
}
output "app_sg_id" {
  value = aws_security_group.app_sg.id
}
