output "web_public_ip" {
  value = module.web_tier.web_public_ip
}

output "app_private_ip" {
  value = module.app_tier.app_private_ip
}

output "db_endpoint" {
  value = module.db_tier.db_endpoint
}

output "ssh_key_name" {
  value = aws_key_pair.lamp_key.key_name
}
