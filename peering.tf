# Crear el peering entre las VPCs

resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = module.vpc_cms.vpc_id
  peer_vpc_id   = module.vpc_cms_backup.vpc_id
  tags = {
    Name = "Backup Peering"
  }
}

/*
# Actualizar la tabla de rutas de la VPC principal
resource "aws_route" "main_to_backup_route" {
  route_table_id         = aws_vpc.main_vpc.default_route_table_id
  destination_cidr_block = aws_vpc.backup_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Actualizar la tabla de rutas de la VPC de backup
resource "aws_route" "backup_to_main_route" {
  route_table_id         = aws_vpc.backup_vpc.default_route_table_id
  destination_cidr_block = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}


# Lambda function para exportar snapshots de RDS a S3
resource "aws_lambda_function" "rds_snapshot_to_s3" {
  filename         = "lambda_snapshot_function.zip"  # Paquete con el código
  function_name    = "export_rds_snapshot_to_s3"
  role             = aws_iam_role.lambda_rds_s3_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  environment {
    variables = {
      RDS_INSTANCE_ID = aws_db_instance.rds_postgresql.id
      S3_BUCKET       = aws_s3_bucket.backup_bucket.bucket
    }
  }
  source_code_hash = filebase64sha256("lambda_snapshot_function.zip")
}

# IAM Role para que Lambda tenga permisos sobre RDS y S3
resource "aws_iam_role" "lambda_rds_s3_role" {
  name = "lambda_rds_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_rds_s3_policy" {
  name   = "lambda_rds_s3_policy"
  role   = aws_iam_role.lambda_rds_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:CreateDBSnapshot",
          "rds:DescribeDBInstances",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:rds:*:*:db:${aws_db_instance.rds_postgresql.id}",
          "arn:aws:s3:::${aws_s3_bucket.backup_bucket.bucket}/*"
        ]
      }
    ]
  })
}
*/