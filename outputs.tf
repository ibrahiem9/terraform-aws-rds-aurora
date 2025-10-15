################################################################################
# DB Subnet Group
################################################################################

output "db_subnet_group_name" {
  description = "Name of the DB subnet group associated with the cluster."
  value       = var.create_db_subnet_group ? try(aws_db_subnet_group.this[0].name, null) : var.db_subnet_group_name
}

################################################################################
# Cluster
################################################################################

output "cluster_id" {
  description = "Identifier of the Aurora cluster."
  value       = try(aws_rds_cluster.this[0].id, null)
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = try(aws_rds_cluster.this[0].arn, null)
}

output "cluster_endpoint" {
  description = "Writer endpoint address for the cluster."
  value       = try(aws_rds_cluster.this[0].endpoint, null)
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint address for the cluster."
  value       = try(aws_rds_cluster.this[0].reader_endpoint, null)
}

output "cluster_engine_version_actual" {
  description = "Engine version reported by the running cluster."
  value       = try(aws_rds_cluster.this[0].engine_version_actual, null)
}

output "cluster_port" {
  description = "Port the cluster is listening on."
  value       = try(aws_rds_cluster.this[0].port, null)
}

################################################################################
# Instances
################################################################################

output "writer_instance_id" {
  description = "Identifier of the writer instance."
  value       = try(aws_rds_cluster_instance.writer[0].id, null)
}

output "reader_instance_ids" {
  description = "Identifiers of reader instances."
  value       = [for i in aws_rds_cluster_instance.readers : i.id]
}

################################################################################
# Networking
################################################################################

output "security_group_id" {
  description = "ID of the managed security group."
  value       = try(aws_security_group.this[0].id, null)
}
