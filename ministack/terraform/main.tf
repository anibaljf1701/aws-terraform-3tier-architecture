terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-west-2"
  access_key                  = "test"
  secret_key                  = "test"
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    ec2            = "http://localhost:4566"
    autoscaling    = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    rds            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
  }
}

locals {
  project_name = "portfolio"
  environment  = "local"
  common_tags = {
    ManagedBy = "Terraform"
    Runtime   = "Ministack"
  }
}

module "vpc" {
  source                   = "../../modules/vpc"
  private_app_subnets_cidr = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "compute" {
  source = "../../modules/ec2_cluster"

  project_name             = local.project_name
  environment              = local.environment
  common_tags              = local.common_tags
  vpc_id                   = module.vpc.vpc_id
  public_subnet_ids        = module.vpc.public_subnet_ids
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  attach_target_group_arns = false
  instance_type            = "t2.micro"
  ami_id                   = "ami-00000001"
  ami_root_device_name     = "/dev/xvda"
  min_size                 = 1
  desired_capacity         = 1
  max_size                 = 2
  cpu_target_value         = 60
}

module "database" {
  source = "../../modules/rds_database"

  project_name            = local.project_name
  environment             = local.environment
  common_tags             = local.common_tags
  vpc_id                  = module.vpc.vpc_id
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  app_security_group_id   = module.compute.app_security_group_id
  db_name                 = "localdb"
  db_username             = "localadmin"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 20
  backup_retention_period = 1
  storage_encrypted       = true
  apply_immediately       = true
}
