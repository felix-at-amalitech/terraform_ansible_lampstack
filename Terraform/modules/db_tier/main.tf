resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [var.app_security_group_id]
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "lamp-db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  storage_type = "gp2"
  username = "admin"
  password = "SecurePass123!"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "main" {
  name = "lamp-db-subnet-group"
  subnet_ids = [var.private_subnet_id]
}