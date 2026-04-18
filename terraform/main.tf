locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix = local.name_prefix
  vpc_cidr    = var.vpc_cidr
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
  project     = var.project
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  name_prefix = local.name_prefix
  project     = var.project
  environment = var.environment
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix    = local.name_prefix
  project        = var.project
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  app_port       = var.app_port
  app_image      = var.app_image
  desired_count  = var.desired_count
  cpu            = var.cpu
  memory         = var.memory
  log_group_name = module.cloudwatch.log_group_name
  aws_region     = var.aws_region
}
