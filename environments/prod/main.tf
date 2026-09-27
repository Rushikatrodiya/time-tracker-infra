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