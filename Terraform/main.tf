terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "sandbox_terraform_felix_user"
  region = var.region
}

# Create SSH key pair
resource "aws_key_pair" "lamp_key" {
  key_name         = "lamp-ssh-key"
  public_key = file("~/.ssh/lamp_key.pub") # this key locally pregenerated
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidr_1 = var.private_subnet_cidr_1
  private_subnet_cidr_2 = var.private_subnet_cidr_2
  az1                  = var.az1
  az2                  = var.az2
}

module "web_tier" {
  source           = "./modules/web_tier"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  key_name         = aws_key_pair.lamp_key.key_name
  db_endpoint      = module.db_tier.db_endpoint
  region           = var.region
}

module "app_tier" {
  source                = "./modules/app_tier"
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.private_subnet_id_1
  key_name              = aws_key_pair.lamp_key.key_name
  web_security_group_id = module.web_tier.web_sg_id
  db_endpoint           = module.db_tier.db_endpoint
}

module "db_tier" {
  source                = "./modules/db_tier"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = [module.vpc.private_subnet_id_1, module.vpc.private_subnet_id_2]
  app_security_group_id = module.app_tier.app_sg_id
  web_security_group_id = module.web_tier.web_sg_id
  region                = var.region
  db_subnet_group_name  = var.db_subnet_group_name
}