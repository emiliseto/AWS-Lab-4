resource "aws_elasticache_cluster" "redis_cluster_cms" {
  cluster_id           = "redis-cluster-cms"  # Nombre del clúster
  engine               = "redis"                    # Motor: Redis
  engine_version       = "6.x"                      # Versión de Redis (puedes especificar la versión que necesites)
  node_type            = "cache.t3.micro"           # Tipo de nodo, puedes elegir según tus necesidades
  num_cache_nodes      = 1                          # Número de nodos (para un nodo único o puede ser mayor)
  parameter_group_name = "default.redis6.x"         # Grupo de parámetros (usa uno predeterminado o personaliza)
  port                 = 6379                       # Puerto para Redis
  subnet_group_name    = aws_elasticache_subnet_group.redis_cms_subnet_group.name
  security_group_ids   = [aws_security_group.redis_security_group.id]  # Security Group asociado
  tags = {
    Name = "Redis Cluster CMS"
  }
}

# Configurar el grupo de subredes para ElastiCache
resource "aws_elasticache_subnet_group" "redis_cms_subnet_group" {
  name       = "redis-cms-subnet-group"
  subnet_ids = [module.vpc_cms.private_subnet_ids[0], module.vpc_cms.private_subnet_ids[1]] 
  tags = {
    Name = "Redis CMS Subnet Group"
  }
}

# Security Group para ElastiCache
resource "aws_security_group" "redis_security_group" {
  name        = "redis_security_group"
  description = "Security Group Redis ElastiCache"
  vpc_id      = module.vpc_cms.vpc_id 
  ingress {
    from_port   = 6379
    to_port     = 6379
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
    Name = "Redis CMS Security Group "
  }
}
