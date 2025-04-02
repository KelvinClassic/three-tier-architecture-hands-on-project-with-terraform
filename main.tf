provider "aws" {
  region = var.project_region
}

module "vpc_network" {
  source = "./modules/network"

  public_subnets_config = var.public_subnets_config
  private_subnets_config = var.private_subnets_config
  database_subnet_config = var.database_subnet_config
}

module "rds_servers" {
  source = "./modules/databases"

  db_sg = module.vpc_network.db_tier_sg
  db_subnet_group_name = module.vpc_network.private_subnet_db
}

module "servers_instances" {
  source = "./modules/servers"

  vpc_name = module.vpc_network.vpc_name
  external_lb_sg = module.vpc_network.external_lb_sg_id
  internal_lb_sg = module.vpc_network.internal_lb_sg_id
  public_subnets = module.vpc_network.private_subnets
  private_subnets = module.vpc_network.private_subnets
  web_tier_sg = module.vpc_network.web_tier_sg_id
  app_tier_sg = module.vpc_network.app_tier_sg_id
}
