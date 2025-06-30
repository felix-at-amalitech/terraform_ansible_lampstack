variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}

# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}
output "private_subnet_id" {
  value = aws_subnet.private.id
}