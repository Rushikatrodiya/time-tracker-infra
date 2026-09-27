# Time Tracker Infrastructure

Terraform code for AWS infrastructure (VPC, ALB, ECR, security groups).

## Quick Start

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

## Prerequisites

- Terraform v1.9.0+
- AWS CLI v2 configured (`aws configure`)
- Region: `ap-south-1`

## What's Built

- **VPC:** 10.0.0.0/16, 2 public subnets across 2 AZs
- **ALB:** Internet-facing, listens on port 80
- **ECR:** Private Docker image registry
- **Security Groups:** ALB (port 80) + ECS (port 3000)

## State

Remote state stored in S3 (`terraform-state-time-tracker`) with DynamoDB lock.

## Structure

```
environments/prod/  → production config & state
modules/            → reusable modules (vpc, alb, ecr, security-groups)
```

## Common Commands

```bash
terraform plan          # See what changes
terraform apply         # Create/update resources
terraform destroy       # Delete all resources
terraform show          # View current state
```

## Next Steps

- [ ] RDS (PostgreSQL)
- [ ] ElastiCache (Redis)
- [ ] ECS Cluster, Task Definition, Service

**Status:** WIP (Networking & ALB complete)