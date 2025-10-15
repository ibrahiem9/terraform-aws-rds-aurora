# Minimal AWS Aurora Module

This fork provides the smallest possible Terraform module for provisioning an Aurora cluster: a subnet group (optional), one writer instance, an optional pool of reader instances, and a simple security group. All advanced features from the upstream module—such as autoscaling, serverless modes, activity streams, custom endpoints, IAM integration, and DSQL—have been removed to keep the interface and behaviour focused on the core database resources.

The module supports Aurora PostgreSQL and Aurora MySQL engines.

## Usage

```hcl
module "aurora" {
  source = "github.com/your-org/terraform-aws-rds-aurora"

  name                = "app-aurora"
  engine              = "aurora-postgresql"
  engine_version      = "15.4"
  database_name       = "app"
  master_username     = "appadmin"
  master_password     = var.master_password
  writer_instance_class = "db.r6g.large"
  reader_count          = 1
  instance_availability_zones = ["us-east-1a", "us-east-1b"]

  create_db_subnet_group = true
  subnets                = ["subnet-123", "subnet-456"]
  vpc_id                 = "vpc-abc"
  allowed_cidr_blocks    = ["10.0.0.0/16"]

  backup_retention_period      = 3
  preferred_backup_window      = "07:00-09:00"
  preferred_maintenance_window = "sun:03:00-sun:05:00"
  apply_immediately            = true

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `allowed_cidr_blocks` | `list(string)` | `[]` | CIDR blocks granted ingress when the module manages the security group. |
| `allowed_security_group_ids` | `list(string)` | `[]` | Security group IDs granted ingress when the module manages the security group. |
| `apply_immediately` | `bool` | `false` | Apply cluster and instance changes outside the maintenance window. |
| `backup_retention_period` | `number` | `7` | Days to retain automated backups. |
| `copy_tags_to_snapshot` | `bool` | `true` | Copy resource tags to automated snapshots. |
| `create` | `bool` | `true` | Master flag controlling whether any resources are created. |
| `create_db_subnet_group` | `bool` | `true` | Manage a DB subnet group for the cluster. |
| `create_security_group` | `bool` | `true` | Manage a security group dedicated to the cluster. |
| `database_name` | `string` | `null` | Initial database name created with the cluster. |
| `db_subnet_group_name` | `string` | `null` | Existing subnet group name to use when not creating one. |
| `deletion_protection` | `bool` | `false` | Enable deletion protection on the cluster. |
| `engine` | `string` | `"aurora-postgresql"` | Aurora database engine identifier. |
| `engine_version` | `string` | `null` | Optional engine version to pin. |
| `final_snapshot_identifier` | `string` | `null` | Snapshot identifier to use when `skip_final_snapshot` is `false`. |
| `instance_availability_zones` | `list(string)` | `[]` | Availability zones for instances: first entry for the writer, subsequent entries for readers. |
| `kms_key_id` | `string` | `null` | KMS key ARN used when storage encryption is enabled. |
| `master_password` | `string` | n/a | Master user password (stored in state; mark sensitive in calling code). |
| `master_username` | `string` | n/a | Master user name. |
| `name` | `string` | n/a | Base name used for created resources. |
| `port` | `number` | `null` | Listener port; defaults to 5432 for PostgreSQL and 3306 for MySQL. |
| `preferred_backup_window` | `string` | `"02:00-03:00"` | Daily backup window in UTC. |
| `preferred_maintenance_window` | `string` | `"sun:05:00-sun:06:00"` | Weekly maintenance window in UTC. |
| `publicly_accessible` | `bool` | `false` | Expose cluster instances to the public internet. |
| `reader_count` | `number` | `0` | Number of reader instances to create. |
| `reader_instance_class` | `string` | `null` | Instance class for readers; defaults to the writer class. |
| `security_group_description` | `string` | `"Aurora access security group"` | Description applied to the managed security group. |
| `security_group_name` | `string` | `null` | Explicit name for the managed security group. |
| `skip_final_snapshot` | `bool` | `true` | Skip the final snapshot when destroying the cluster. |
| `storage_encrypted` | `bool` | `true` | Enable storage encryption. |
| `subnets` | `list(string)` | `[]` | Subnet IDs used when creating the subnet group. |
| `tags` | `map(string)` | `{}` | Tags applied to all managed resources. |
| `vpc_id` | `string` | `null` | VPC ID required when managing the security group. |
| `vpc_security_group_ids` | `list(string)` | `[]` | Additional security groups attached to the cluster. |
| `writer_instance_class` | `string` | n/a | Instance class for the cluster writer. |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_arn` | ARN of the Aurora cluster. |
| `cluster_engine_version_actual` | Engine version reported by the running cluster. |
| `cluster_endpoint` | Writer endpoint of the cluster. |
| `cluster_id` | Identifier of the Aurora cluster. |
| `cluster_port` | Port the cluster is listening on. |
| `cluster_reader_endpoint` | Reader endpoint of the cluster. |
| `db_subnet_group_name` | Name of the subnet group associated with the cluster. |
| `reader_instance_ids` | Identifiers of reader instances. |
| `security_group_id` | ID of the managed security group. |
| `writer_instance_id` | Identifier of the writer instance. |

## Example

See [`examples/basic`](examples/basic) for a complete, runnable configuration that provisions a VPC, generates a random master password, and launches an Aurora PostgreSQL cluster with one reader.
