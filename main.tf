# 1. Module of network
module "vpc" {
  source                   = "./modules/vpc"
  private_app_subnets_cidr = var.private_app_subnet_cidr
}

# 2. Module of compute (Depend on the network module)
module "compute" {
  source = "./modules/ec2_cluster"

  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
}

# 3. Module of database (Depend on the network module)
module "database" {
  source = "./modules/rds_database"

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  app_subnets_cidr     = var.private_app_subnet_cidr
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password

}