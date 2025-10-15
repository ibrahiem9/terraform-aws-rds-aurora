provider "aws" {
  region = local.region
}

data "aws_availability_zones" "selected" {
  state = "available"
}

resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

resource "random_pet" "suffix" {
  length = 2
}

locals {
  region = "us-east-1"
  name   = "aurora-basic-${random_pet.suffix.id}"

  tags = {
    Project     = "aurora-basic"
    Environment = "test"
  }

  azs = slice(data.aws_availability_zones.selected.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs              = local.azs
  public_subnets   = [for idx, az in local.azs : cidrsubnet("10.0.0.0/16", 8, idx)]
  private_subnets  = [for idx, az in local.azs : cidrsubnet("10.0.0.0/16", 8, idx + 2)]
  database_subnets = [for idx, az in local.azs : cidrsubnet("10.0.0.0/16", 8, idx + 4)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "aurora" {
  source = "../../"

  name              = local.name
  engine            = "aurora-postgresql"
  engine_version    = "15.4"
  database_name     = "app"
  master_username   = "appadmin"
  master_password   = random_password.master.result
  writer_instance_class = "db.r6g.large"
  reader_count          = 1
  reader_instance_class = "db.r6g.large"
  instance_availability_zones = local.azs

  create_db_subnet_group = true
  subnets                = module.vpc.database_subnets
  vpc_id                 = module.vpc.vpc_id
  allowed_cidr_blocks    = module.vpc.private_subnets_cidr_blocks

  backup_retention_period      = 3
  preferred_backup_window      = "07:00-09:00"
  preferred_maintenance_window = "sun:03:00-sun:05:00"
  apply_immediately            = true
  skip_final_snapshot          = true

  tags = local.tags
}
