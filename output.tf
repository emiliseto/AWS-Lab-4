/*
output "instance_public_ip" {
    description = "IP PUBLICAS EC2"
    value = {for i ,instance in aws_instance.milu_EC2_Docker:i => milu_EC2_Docker.public_ip
    }
}

output "instance_id_ec2" {
    description = "EC2 instance ID"
    value = {for i ,instance in aws_instance.milu_EC2_Docker:i => milu_EC2_Docker.id
    }
}
*/
/*
output "rds_endpoint" {
  description = "El endpoint de la base de datos RDS"
  value       = aws_db_instance.milu_rds.endpoint
}

output "rds_username" {
  description = "El nombre de usuario para la base de datos RDS"
  value       = aws_db_instance.milu_rds.username
  sensitive = true
}

output "rds_password" {
  description = "La contraseña para la base de datos RDS"
  value       = aws_db_instance.milu_rds.password
  sensitive = true
}*/