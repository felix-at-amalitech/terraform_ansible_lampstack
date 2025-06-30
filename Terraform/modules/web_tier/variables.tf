variable "vpc_id" {}
variable "public_subnet_id" {}
variable "key_name" {}

# modules/web_tier/outputs.tf
output "web_public_ip" {
  value = aws_instance.web.public_ip
}
output "web_sg_id" {
  value = aws_security_group.web_sg.id
}