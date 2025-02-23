terraform {
  required_providers {
    aws =  {
      source = "hashicorp/aws"
      version = "5.86.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "milu-terraform-state-backend"
    key = "terraform.state"
    region = "eu-west-3"
    dynamodb_table = "terraform_state"
  }
}

module "vpc_cms" {
  source = "./vpc_module"
  vpc_cidr_block       = "10.0.0.0/16"
  vpc_name             = "VPC_CMS"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["eu-west-3a", "eu-west-3b"]
}

module "vpc_cms_backup" {
  source = "./vpc_module"
  vpc_cidr_block       = "172.16.0.0/16"
  vpc_name             = "VPC_CMS_Backup"
  public_subnet_cidrs  = []
  private_subnet_cidrs = []
  availability_zones   = []
}

/*
# Secrets Manager - Almacenar credenciales
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "rds-postgres-credentials"
  description = "Credenciales de acceso a la base de datos PostgreSQL en RDS"
}

# Definir los valores del secreto (usuario y contraseña)
resource "aws_secretsmanager_secret_version" "db_credentials_value" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
  username = "cms_admin"
  password = "cms@admin@2025"
})
}
*/

resource "aws_security_group" "Security_Group_cms" {
  name        = "allow_http_https"
  description = "Allow HTTP & HTTPS inbound traffic"
  vpc_id      = module.vpc_cms.vpc_id

  # Reglas de ingreso (inbound)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTP desde cualquier dirección IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir tráfico HTTPS desde cualquier dirección IP
  }

  # Regla de salida (egress) por defecto (permitir todo el tráfico saliente)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # "-1" permite todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]  # Permitir todo el tráfico saliente
  }

  tags = {
    Name = "Security Group cms"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh.tpl")
  vars =  {
    db_host = aws_db_instance.cms_rds.endpoint
    db_username = aws_db_instance.cms_rds.username
    db_password = aws_db_instance.cms_rds.password
    db_name = aws_db_instance.cms_rds.db_name
    cache_host = aws_elasticache_cluster.redis_cluster_cms.cache_nodes[0].address
    efs_cms = aws_efs_file_system.efs_cms.dns_name
  }
}

/*
resource "aws_instance" "cms_ec2" {
  ami           = "ami-07dc1ccdcec3b4eab"  
  instance_type = "t2.micro"
  subnet_id     = module.vpc_cms.public_subnet_ids[0]
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  security_groups      = [aws_security_group.Security_Group_cms.id]
  associate_public_ip_address =  true
  user_data = data.template_file.user_data.rendered
  tags = { 
    Name = "CMS EC2 INSTANCE"
  }
}
*/