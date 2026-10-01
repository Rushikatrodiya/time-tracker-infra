output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the ALB"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS database endpoint"
}

output "rds_host" {
  value       = module.rds.rds_host
  description = "RDS host address"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "ecs_service_name" {
  value       = "time-tracker-service"
  description = "ECS service name"
}