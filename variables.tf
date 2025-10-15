variable "create" {
  description = "Whether to create the Aurora resources at all."
  type        = bool
  default     = true
}

variable "name" {
  description = "Distinct name used for the cluster, subnet group, and security group where applicable."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all created resources."
  type        = map(string)
  default     = {}
}

################################################################################
# Networking
################################################################################

variable "create_db_subnet_group" {
  description = "Create and manage a DB subnet group for the cluster."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "Name of an existing DB subnet group to use when not creating one."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnet IDs used when creating the DB subnet group."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Create a security group dedicated to the cluster."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Explicit name for the security group; defaults to the cluster name."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Description used for the security group."
  type        = string
  default     = "Aurora access security group"
}

variable "vpc_id" {
  description = "VPC identifier required when creating the security group."
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitted to connect to the cluster when the module manages the security group."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs permitted to connect when the module manages the security group."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Additional security groups to attach to the cluster."
  type        = list(string)
  default     = []
}

################################################################################
# Cluster
################################################################################

variable "engine" {
  description = "Aurora database engine for the cluster."
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Optional engine version to pin for the cluster."
  type        = string
  default     = null
}

variable "database_name" {
  description = "Initial database name created on cluster creation."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Master user name for the cluster."
  type        = string
}

variable "master_password" {
  description = "Master user password for the cluster (stored in state; handle carefully)."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "Port the cluster listens on; defaults to 5432 for PostgreSQL and 3306 for MySQL."
  type        = number
  default     = null
}

variable "apply_immediately" {
  description = "Apply modifications outside the maintenance window."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily backup window in UTC."
  type        = string
  default     = "02:00-03:00"
}

variable "preferred_maintenance_window" {
  description = "Weekly maintenance window in UTC."
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "deletion_protection" {
  description = "Enable deletion protection on the cluster."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip taking a final snapshot when destroying the cluster."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Identifier to use for the final snapshot when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Enable storage encryption for the cluster."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN used when storage encryption is enabled."
  type        = string
  default     = null
}

variable "copy_tags_to_snapshot" {
  description = "Copy cluster tags to automated snapshots."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Expose the cluster instances to the public internet."
  type        = bool
  default     = false
}

################################################################################
# Instances
################################################################################

variable "writer_instance_class" {
  description = "Instance class used for the cluster writer."
  type        = string
}

variable "reader_count" {
  description = "Number of reader instances to create."
  type        = number
  default     = 0
}

variable "reader_instance_class" {
  description = "Instance class for reader instances; defaults to the writer class."
  type        = string
  default     = null
}

variable "instance_availability_zones" {
  description = "Availability zones for the cluster instances; first entry applies to the writer, remaining entries to readers."
  type        = list(string)
  default     = []
}
