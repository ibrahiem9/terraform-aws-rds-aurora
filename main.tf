locals {
  create = var.create

  default_port = contains([
    "aurora-postgresql",
    "postgres",
    "aurora-postgresql13",
    "aurora-postgresql14",
    "aurora-postgresql15",
  ], var.engine) ? 5432 : 3306

  port = coalesce(var.port, local.default_port)

  security_group_name = coalesce(var.security_group_name, var.name)

  reader_instance_class = coalesce(var.reader_instance_class, var.writer_instance_class)

  writer_az = length(var.instance_availability_zones) > 0 ? var.instance_availability_zones[0] : null

  reader_azs = length(var.instance_availability_zones) > 1 ? slice(var.instance_availability_zones, 1, length(var.instance_availability_zones)) : []
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  count = local.create && var.create_db_subnet_group ? 1 : 0

  name       = coalesce(var.db_subnet_group_name, var.name)
  subnet_ids = var.subnets

  description = "Subnets for Aurora cluster ${var.name}"

  tags = var.tags
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "this" {
  count = local.create && var.create_security_group ? 1 : 0

  name        = local.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = local.security_group_name })
}

resource "aws_security_group_rule" "ingress_cidr" {
  count = local.create && var.create_security_group && length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this[0].id
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each = local.create && var.create_security_group ? toset(var.allowed_security_group_ids) : []

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this[0].id
}

resource "aws_security_group_rule" "egress" {
  count = local.create && var.create_security_group ? 1 : 0

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.this[0].id
}

################################################################################
# Cluster
################################################################################

resource "aws_rds_cluster" "this" {
  count = local.create ? 1 : 0

  cluster_identifier                  = var.name
  engine                              = var.engine
  engine_version                      = var.engine_version
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = var.master_password
  port                                = local.port
  apply_immediately                   = var.apply_immediately
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : var.final_snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  db_subnet_group_name   = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  vpc_security_group_ids = compact(concat(var.vpc_security_group_ids, var.create_security_group ? [aws_security_group.this[0].id] : []))

  tags = var.tags
}

################################################################################
# Cluster Instances
################################################################################

resource "aws_rds_cluster_instance" "writer" {
  count = local.create ? 1 : 0

  identifier              = "${var.name}-writer"
  cluster_identifier      = aws_rds_cluster.this[0].id
  instance_class          = var.writer_instance_class
  engine                  = var.engine
  engine_version          = var.engine_version
  availability_zone       = local.writer_az
  apply_immediately       = var.apply_immediately
  publicly_accessible     = var.publicly_accessible
  preferred_maintenance_window = var.preferred_maintenance_window

  tags = var.tags
}

resource "aws_rds_cluster_instance" "readers" {
  count = local.create ? var.reader_count : 0

  identifier         = format("%s-reader-%02d", var.name, count.index + 1)
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = local.reader_instance_class
  engine             = var.engine
  engine_version     = var.engine_version
  availability_zone = length(local.reader_azs) > count.index ? local.reader_azs[count.index] : null
  apply_immediately  = var.apply_immediately
  publicly_accessible = var.publicly_accessible

  preferred_maintenance_window = var.preferred_maintenance_window

  tags = var.tags
}
