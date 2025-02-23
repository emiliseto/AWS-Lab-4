# Crear Subnet Group para la base de datos RDS 
resource "aws_db_subnet_group" "cms_rds_subnet_group" {
  name       = "cms_rds_subnet_group"
  subnet_ids = [module.vpc_cms.private_subnet_ids[0], module.vpc_cms.private_subnet_ids[1]] 
  tags = {
    Name = "cms RDS Subnet Group"
  }
}

# Crear la instancia de base de datos RDS con alta disponibilidad y backups
resource "aws_db_instance" "cms_rds" {
  allocated_storage         = 10                          # Tamaño de almacenamiento en GB
  engine                    = "postgres"                  # Motor de base de datos (postgres)
  engine_version            = "17.3"                      # Versión de PostgreSQL 
  max_allocated_storage      = 50                         # Tamaño de almacenamiento en GB
  storage_type              = "gp2"                       # Tipo de almacenamiento
  instance_class            = "db.t3.micro"               # Clase de instancia
  db_name                   = "cms_db"                    # Nombre de la base de datos
  username                  = "postgres"                  # Usuario administrador
  password                  = "admin123"                  # Contraseña de la base de datos
  db_subnet_group_name      = aws_db_subnet_group.cms_rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_postgres_security_group.id]  # Asociar el Security Group
  skip_final_snapshot       = false                       # Crear un snapshot al eliminar la base de datos
  publicly_accessible       = false
  multi_az                  = true                        # Habilitar alta disponibilidad (Multi-AZ)
  backup_retention_period   = 7                           # Retención de backups (en días)
  storage_encrypted         = false                       # Habilitar encriptación del almacenamiento
  iam_database_authentication_enabled = false             # Desactivar autenticación IAM si no se necesita
  tags = {
    Name = "CMS DB Postgres RDS"
  }
}

# Grupo de seguridad para la base de datos RDSyesssssssssssssssssssssss
resource "aws_security_group" "rds_postgres_security_group" {
  name        = "rds_postgres_security_group"
  description = "Security Group RDS PostgreSQL instance"
  vpc_id      = module.vpc_cms.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security Group PostgreSQL RDS"
  }
}

# Crear replica de lectura RDS
resource "aws_db_instance" "replica_instance" {
  identifier                    = "replica-cms-db"
  instance_class                = "db.t3.micro"
  engine                        = "postgres"
  publicly_accessible           = false
  replicate_source_db           = aws_db_instance.cms_rds.arn        # Fuente de la réplica de lectura
  multi_az                      = true                               # Habilitar alta disponibilidad (Multi-AZ)
  db_subnet_group_name          = aws_db_subnet_group.cms_rds_subnet_group.name
  vpc_security_group_ids        = [aws_security_group.rds_postgres_security_group.id]
  skip_final_snapshot           = true
  tags = {
    Name = "CMS DB RR Postgres RDS"
  }
}