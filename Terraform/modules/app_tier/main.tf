resource "aws_security_group" "app_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [var.web_security_group_id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "LAMP-App-SG"
    Tier = "App"
  }
}

resource "aws_instance" "app" {
  ami             = "ami-0803576f0c0169402"
  instance_type   = "t2.micro"
  subnet_id       = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name         = var.key_name
  
  tags = {
    Name = "LAMP-App-Server"
    Tier = "App"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y php
              cat << 'PHP' > /var/www/html/app.php
              <?php
              function processRequest(\$data) {
                  return "Processed: " . \$data;
              }
              ?>
              PHP
              EOF
}
