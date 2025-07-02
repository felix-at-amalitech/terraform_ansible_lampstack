variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_1" {
  type    = string
  default = "10.0.4.0/24"
}

variable "private_subnet_cidr_2" {
  type    = string
  default = "10.0.5.0/24"
}

variable "az1" {
  type    = string
  default = "eu-west-1a"
}

variable "az2" {
  type    = string
  default = "eu-west-1b"
}

variable "db_subnet_group_name" {
  type    = string
  default = "lamp-db-subnet-group-2025"
}
