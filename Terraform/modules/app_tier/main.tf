resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    security_groups = [var.web_security_group_id]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami = "ami-000ec6c25978d5999"
  instance_type = "t2.micro"
  subnet_id = var.private_subnet_id
  security_groups = [aws_security_group.app_sg.id]
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y php
              EOF
}