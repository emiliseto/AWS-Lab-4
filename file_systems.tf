# Crear el sistema de archivos EFS
resource "aws_efs_file_system" "efs_cms" {
  creation_token = "efs-cms"       # Un identificador único para la creación del EFS
  performance_mode = "generalPurpose"    # Modo de rendimiento 
  throughput_mode  = "bursting"          # Modo de rendimiento en términos de rendimiento de lectura/escritura
  encrypted = true                       # Habilitar encriptación
 # kms_key_id = "alias/aws/efs"           # Clave KMS para la encriptación 
  tags = {
    Name = "EFS cms"
  }
}

# Crear el Security Group para EFS
resource "aws_security_group" "efs_security_group" {
  name        = "efs_security_group"
  description = "Security group EFS"
  vpc_id      = module.vpc_cms.vpc_id
  ingress {
    from_port   = 2049
    to_port     = 2049
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
    Name = "Security Group EFS"
  }
}

# Crear Puntos de Montage para EFS
resource "aws_efs_mount_target" "efs_mount_target" {
  count              = length(module.vpc_cms.private_subnet_ids)
  file_system_id     = aws_efs_file_system.efs_cms.id
  subnet_id          = element(module.vpc_cms.private_subnet_ids, count.index)  
  security_groups    = [aws_security_group.efs_security_group.id]                   
}

resource "aws_s3_bucket" "s3_bucket_cms" {
  bucket = "s3-bucket-cms"  
  tags = {
    Name = "S3 Bucket cms"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.s3_bucket_cms.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

/*
# Subir un archivo al bucket de S3
resource "aws_s3_object" "s3_bucket_cms_object" {
  bucket = aws_s3_bucket.website_bucket.bucket     # El bucket donde se sube el archivo
  key    = "index.html"                            # La ubicación del archivo en el bucket
  source = "index.html"                            # Ruta del archivo local
}
*/