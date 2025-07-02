output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}
