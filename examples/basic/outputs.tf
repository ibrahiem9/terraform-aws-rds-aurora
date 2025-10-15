output "cluster_id" {
  description = "Identifier of the Aurora cluster."
  value       = module.aurora.cluster_id
}

output "cluster_endpoint" {
  description = "Writer endpoint for the Aurora cluster."
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Reader endpoint for the Aurora cluster."
  value       = module.aurora.cluster_reader_endpoint
}

output "writer_instance_id" {
  description = "Identifier of the writer instance."
  value       = module.aurora.writer_instance_id
}

output "reader_instance_ids" {
  description = "Identifiers of reader instances."
  value       = module.aurora.reader_instance_ids
}

output "security_group_id" {
  description = "ID of the security group created for database access."
  value       = module.aurora.security_group_id
}
