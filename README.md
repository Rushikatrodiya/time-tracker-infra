# Time Tracker Infrastructure (Terraform)

Infrastructure-as-Code setup for deploying the Time Tracker backend on AWS ECS Fargate using Terraform.

---

## Current Status (WIP)

### ✅ Completed
- [x] Remote state backend (S3 + DynamoDB)
- [x] VPC with 2 public subnets across 2 availability zones
- [x] Internet Gateway + routing
- [x] ECR repository for Docker images
- [x] Security groups (ALB + ECS)
- [x] Application Load Balancer (ALB) with target group & listener
- [x] CloudWatch Logs setup (via ALB)

### 📋 Pending
- [ ] RDS (PostgreSQL) — managed database
- [ ] ElastiCache (Redis) — managed cache
- [ ] ECS Cluster
- [ ] ECS Task Definition
- [ ] ECS Service
- [ ] IAM roles & policies

---

## Project Structure

```
infra/
├── environments/
│   └── prod/
│       ├── backend.tf           # S3 + DynamoDB state config
│       ├── versions.tf          # Terraform & provider versions
│       ├── provider.tf          # AWS provider config
│       ├── main.tf              # Module declarations
│       ├── terraform.tfvars     # (optional) variable overrides
│       └── .terraform/          # (auto-generated) provider cache
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-groups/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── alb/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── README.md
```

---

## Prerequisites

### Tools
- **Terraform** v1.9.0+ (check: `terraform -version`)
- **AWS CLI v2** (check: `aws --version`)
- **Git** (for version control)

### AWS Credentials
Configured via `aws configure`:
- Access Key ID
- Secret Access Key
- Region: `ap-south-1` (Mumbai)
- Output format: `json`

Verify:
```bash
aws configure list
```

---

## Architecture Overview

### Current Deployment (WIP)

```
Internet
   ↓
[ALB: time-tracker-alb]
   ↓ (port 80)
[Target Group: time-tracker-tg]
   ↓
[VPC: 10.0.0.0/16]
   ├── Public Subnet 1 (ap-south-1a): 10.0.1.0/24
   └── Public Subnet 2 (ap-south-1b): 10.0.2.0/24
        ↓
   [Security Groups]
   ├── alb-sg: allows 0.0.0.0/0 → port 80
   └── ecs-sg: allows alb-sg → port 3000
```

### Final Architecture (After RDS/ElastiCache/ECS)

```
Internet
   ↓
[ALB] → [Target Group] → [ECS Fargate Tasks]
                              ↓
                         [App Container]
                              ↓
                         ┌─────┴─────┐
                         ↓           ↓
                       [RDS]    [ElastiCache]
                     (Postgres)   (Redis)
```

---

## Key Resources Created

### VPC & Networking
| Resource | Name | Details |
|----------|------|---------|
| VPC | `time-tracker-vpc` | 10.0.0.0/16 |
| Subnet 1 | `time-tracker-public-0` | 10.0.1.0/24 (ap-south-1a) |
| Subnet 2 | `time-tracker-public-1` | 10.0.2.0/24 (ap-south-1b) |
| IGW | `time-tracker-igw` | Internet access |
| Route Table | `time-tracker-public-rt` | Routes 0.0.0.0/0 to IGW |

### Load Balancing
| Resource | Name | Details |
|----------|------|---------|
| ALB | `time-tracker-alb` | Internet-facing, listens on port 80 |
| Target Group | `time-tracker-tg` | Routes to port 3000 (app port) |
| Listener | (auto) | HTTP listener on port 80 |

**ALB DNS:** `time-tracker-alb-1846152148.ap-south-1.elb.amazonaws.com`

### Security
| Resource | Name | Details |
|----------|------|---------|
| SG (ALB) | `time-tracker-alb-sg` | Ingress: 0.0.0.0/0:80, Egress: all |
| SG (ECS) | `time-tracker-ecs-sg` | Ingress: alb-sg:3000, Egress: all |

### Container Registry
| Resource | Name | Details |
|----------|------|---------|
| ECR | `time-tracker-backend` | Private Docker image repo |

---

## How to Use

### 1. Navigate to Production Environment
```bash
cd environments/prod
```

### 2. Initialize (First Time Only)
```bash
terraform init
```

This:
- Downloads AWS provider plugin
- Connects to S3 backend for state
- Sets up working directory

### 3. Plan Changes
```bash
terraform plan
```

Shows what Terraform will create/modify/destroy. Always review before applying.

### 4. Apply Changes
```bash
terraform apply
```

Type `yes` when prompted. Creates or modifies resources in AWS.

### 5. View Current State
```bash
terraform show
```

Displays all managed resources and their attributes.

### 6. Destroy (Caution!)
```bash
terraform destroy
```

Deletes all Terraform-managed infrastructure. **Irreversible.**

---

## Terraform State

### Remote State Location
- **Bucket:** `terraform-state-time-tracker`
- **Path:** `prod/terraform.tfstate`
- **Lock Table:** `terraform-locks` (DynamoDB)

### State File
The `.tfstate` file is **never committed to Git** and lives only in S3. It contains:
- Resource IDs and attributes
- Provider configuration
- Module state

**DO NOT:**
- Manually edit `.tfstate` files
- Commit `.tfstate` to version control
- Share credentials in `.tf` files

---

## Common Commands

### Check Terraform syntax
```bash
terraform validate
```

### Format code
```bash
terraform fmt -recursive
```

### Show specific resource
```bash
terraform show module.vpc
```

### Taint resource (force recreation)
```bash
terraform taint module.vpc.aws_vpc.main
```

### Output values
```bash
terraform output
```

---

## Environment Variables (WIP)

Current variables from old task definition (will be updated when RDS/ElastiCache are created):

```
REFRESH_TOKEN_EXPIRY=604800
DATABASE_URL=postgresql://postgres:password@localhost:5432/time_tracker
PORT=3000
DB_USER=postgres
APP_NAME=Time Tracker
NODE_ENV=dev
DB_NAME=time_tracker
EMAIL_FROM=Time Tracker
ACCESS_TOKEN_SECRET=<your-secret>
DB_PASSWORD=<your-password>
REDIS_URL=redis://localhost:6379
```

**After RDS/ElastiCache setup**, these will be updated to:
```
DATABASE_URL=postgresql://user:password@rds-endpoint:5432/time_tracker
REDIS_URL=redis://elasticache-endpoint:6379
```

---

## Next Steps (To Resume)

### Step 1: RDS (PostgreSQL)
- Create `modules/rds/` with security group, subnet group, DB instance
- Manage database credentials via AWS Secrets Manager
- Update environment variables with RDS endpoint

### Step 2: ElastiCache (Redis)
- Create `modules/elasticache/` with cluster and subnet group
- Update environment variables with ElastiCache endpoint

### Step 3: ECS Cluster
- Create `modules/ecs-cluster/` 
- Simple cluster, just a logical grouping

### Step 4: ECS Task Definition
- Create `modules/ecs-task-definition/`
- Single container (app only, no Postgres/Redis sidecars)
- Pass RDS/ElastiCache endpoints as environment variables
- CloudWatch Logs for container output

### Step 5: ECS Service
- Create `modules/ecs-service/`
- Connect to ALB target group
- 2 running tasks minimum (for redundancy across AZs)
- Auto-scaling (optional)

---

## Troubleshooting

### "State lock already acquired"
Another process is running `terraform apply`. Wait or check AWS console.

### "Invalid credentials"
```bash
aws configure
```
Re-enter AWS Access Key and Secret Key.

### "Resource already exists"
Resource was created manually outside Terraform. Either:
- **Delete manually** (via AWS console), then `terraform apply`
- **Import via:** `terraform import <resource-type> <resource-id>`

### ALB not receiving traffic
1. Check security group ingress rules: `aws ec2 describe-security-groups`
2. Check ALB health: AWS Console → EC2 → Load Balancers → target group health
3. Verify ECS tasks are registered with target group

---

## Useful Links

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Fargate Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform State Management](https://www.terraform.io/language/state)

---

## Team Notes

- **Region:** ap-south-1 (Mumbai)
- **Container port:** 3000
- **Database port:** 5432
- **Cache port:** 6379
- **ALB port:** 80 (HTTP only for now, add HTTPS/SSL later)

**First deployment:** Use `terraform apply` in `environments/prod/` after completing pending steps.

---

**Last Updated:** Sep 27, 2026  
**Status:** Work in Progress (WIP) — Networking & ALB complete, awaiting RDS/ElastiCache/ECS