provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "web_tier" {
  source = "./modules/web_tier"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  key_name = var.key_name
}

module "app_tier" {
  source = "./modules/app_tier"
  vpc_id = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
  key_name = var.key_name
  web_security_group_id = module.web_tier.web_sg_id
}

module "db_tier" {
  source = "./modules/db_tier"
  vpc_id = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
  app_security_group_id = module.app_tier.app_sg_id
}
