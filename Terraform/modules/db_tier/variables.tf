variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "web_security_group_id" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "db_subnet_group_name" {
  type = string
}