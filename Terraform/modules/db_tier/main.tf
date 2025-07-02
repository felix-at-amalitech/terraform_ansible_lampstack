resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id, var.web_security_group_id]
  }
  tags = {
    Name = "LAMP-DB-SG"
    Tier = "Database"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = var.db_subnet_group_name
  }
}

resource "aws_db_parameter_group" "mysql_params" {
  family = "mysql8.0"
  name   = "lamp-mysql-params"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "lamp-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = "your_username_here"
  password               = "your_password_here"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.mysql_params.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_name                = "your_database_name_here"

  depends_on = [aws_db_subnet_group.main]
}
