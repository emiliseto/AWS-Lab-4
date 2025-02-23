# Crear Rol de IAM para SSM
resource "aws_iam_role" "ssm_role" {
    name = "ssm_role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }]
    })
}

# Adjuntar Políticas de SSM a la IAM Role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
    role       = aws_iam_role.ssm_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Crear Perfil de Instancia para EC2
resource "aws_iam_instance_profile" "ssm_instance_profile" {
    name = "ssm_instance_ec2_profile"
    role = aws_iam_role.ssm_role.name
}

# Política del bucket para permitir acceso público
resource "aws_s3_bucket_policy" "s3_bucket_cms_policy" {
  bucket = aws_s3_bucket.s3_bucket_cms.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.s3_bucket_cms.bucket}/*"
      }
    ]
  })
}
