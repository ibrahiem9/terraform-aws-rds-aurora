# Basic Aurora Example

This example provisions the minimal networking required for an Aurora PostgreSQL cluster and then calls the module with a single writer and one reader instance.

## Usage

```bash
terraform init
terraform apply
```

Destroy the resources when finished to avoid ongoing charges.

## Notes

- A random password is generated for the master user and surfaced only in Terraform output.
- The sample VPC uses the community VPC module for brevity; replace it with your own networking configuration if desired.
