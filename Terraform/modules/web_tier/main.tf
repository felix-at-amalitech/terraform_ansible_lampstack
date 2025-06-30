resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_instance" "web" {
  ami = "ami-000ec6c25978d5999" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id = var.public_subnet_id
  security_groups = [aws_security_group.web_sg.id]
  key_name = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php
              systemctl start httpd
              systemctl enable httpd
              echo "<?php phpinfo(); ?>" > /var/www/html/info.php
              EOF
}
