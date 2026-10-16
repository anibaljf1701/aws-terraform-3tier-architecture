# 1. Module of network
module "vpc" {
  source                   = "./modules/vpc"
  private_app_subnets_cidr = var.private_app_subnet_cidr
}

# 2. Module of compute (Depend on the network module)
module "compute" {
  source = "./modules/ec2_cluster"

  project_name           = var.project_name
  environment            = var.environment
  common_tags            = var.common_tags
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  instance_type          = var.instance_type
  min_size               = var.asg_min_size
  desired_capacity       = var.asg_desired_capacity
  max_size               = var.asg_max_size
  cpu_target_value       = var.asg_cpu_target_value
}

# 3. Module of database (Depend on the network module)
module "database" {
  source = "./modules/rds_database"

  project_name            = var.project_name
  environment             = var.environment
  common_tags             = var.common_tags
  vpc_id                  = module.vpc.vpc_id
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  app_security_group_id   = module.compute.app_security_group_id
  db_name                 = var.db_name
  db_username             = var.db_username
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  backup_retention_period = var.db_backup_retention_days
  storage_encrypted       = var.db_storage_encrypted
  apply_immediately       = var.db_apply_immediately

}