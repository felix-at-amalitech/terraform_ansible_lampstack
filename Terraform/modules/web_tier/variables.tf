variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}