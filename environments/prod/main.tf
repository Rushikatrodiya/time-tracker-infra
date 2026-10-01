module "vpc" {
  source       = "../../modules/vpc"
  project_name = "time-tracker"
}

module "ecr" {
  source          = "../../modules/ecr"
  repository_name = "time-tracker-backend"
}

module "security_groups" {
  source         = "../../modules/security-groups"
  project_name   = "time-tracker"
  vpc_id         = module.vpc.vpc_id
  container_port = 3000
}

module "alb" {
  source                 = "../../modules/alb"
  project_name           = "time-tracker"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  alb_security_group_id  = module.security_groups.alb_sg_id
  container_port         = 3000
}

module "rds" {
  source                 = "../../modules/rds"
  project_name           = "time-tracker"
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  ecs_security_group_id  = module.security_groups.ecs_sg_id
  db_name                = "time_tracker"
  db_username            = "postgres"
  db_password            = var.rds_password
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
}

module "elasticache" {
  source                = "../../modules/elasticache"
  project_name          = "time-tracker"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_sg_id
  node_type             = "cache.t3.micro"
}

module "ecs" {
  source                = "../../modules/ecs"
  project_name          = "time-tracker"
  aws_region            = var.aws_region
  ecr_repository_url    = module.ecr.repository_url
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_sg_id
  alb_target_group_arn  = module.alb.target_group_arn
  
  db_username = "postgres"
  db_password = var.rds_password
  db_host     = module.rds.rds_host
  db_port     = 5432
  db_name     = "time_tracker"
  
  redis_host = module.elasticache.redis_endpoint
  redis_port = 6379
}