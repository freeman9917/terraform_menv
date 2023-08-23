provider "aws" {
  region     = "eu-central-1"
}


terraform {
  backend "s3" {
    bucket = "my-brain-bucket"
    key = "tr-state/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "dynamodb-state-locking"    
}  
}




module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block         = var.vpc_cidr_block
  pub1_subnet_cidr_block = var.pub1_subnet
  pub2_subnet_cidr_block = var.pub2_subnet
  avail_zone1            = var.avail_zone1
  avail_zone2            = var.avail_zone2
  env_prefix             = var.env_prefix
}


module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  security_groups = module.vpc.sec_group_id
  pub1_subnet_id = module.vpc.pub1_subnet_id
  pub2_subnet_id = module.vpc.pub2_subnet_id
  env_prefix             = var.env_prefix
}

module "asg" {
  source = "./modules/asg"
  security_groups = module.vpc.sec_group_id
  pub1_subnet_id = module.vpc.pub1_subnet_id
  pub2_subnet_id = module.vpc.pub2_subnet_id
  target_group_id = module.alb.target_group_id
  env_prefix             = var.env_prefix
}
