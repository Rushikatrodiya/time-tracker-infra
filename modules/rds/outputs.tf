output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_host" {
  value = aws_db_instance.main.address
}

output "rds_port" {
  value = aws_db_instance.main.port
}

output "db_name" {
  value = aws_db_instance.main.db_name
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}