# Definir la contraseña como una variable sensible
variable "db_password" {
  description = "La contraseña del administrador para la base de datos RDS"
  type        = string
  sensitive   = true
  default = "cms@admin@2025"
}

variable "web_domain" {
  description = "Web Dominio"
  type        = string
  sensitive   = true
  default = "www.milu1001.online"
}

variable "main_domain_name"{
  description = "Main Dominio"
  type        = string
  sensitive   = true
  default = "www.milu1001.online"
}

variable "aws_region" {
  default = "eu-west-3"
}
