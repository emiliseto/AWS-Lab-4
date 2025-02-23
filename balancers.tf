/*
resource "aws_acm_certificate" "imported_certificate" {
  private_key       = file("${path.module}/private-key.key")
  certificate_body  = file("${path.module}/certificate.crt")
 # certificate_chain = file("${path.module}/request.csr")
  tags = {
    Name = "ImportedCertificate"
  }
}
*/

/*
resource "aws_lb_listener" "external_https_listener" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"  
  certificate_arn   = aws_acm_certificate.imported_certificate.arn  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_target_group.arn
  }
}
*/

# Balanceador de carga Externo (Public ALB)
resource "aws_lb" "external_lb" {
  name               = "external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_alb_security_group.id]
  subnets            = module.vpc_cms.public_subnet_ids[*]
  enable_deletion_protection = false
    tags = {
       Name = "CMS Balanceador Externo"
    }
}
 
resource "aws_lb_target_group" "external_target_group" {
  name     = "external-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_cms.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
    tags = {
       Name = "CMS External Target Group"
    }
}
 
resource "aws_lb_listener" "external_http_listener" {
  load_balancer_arn = aws_lb.external_lb.arn
  port              = "80"
  protocol          = "HTTP"
   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_target_group.arn
  }
    tags = {
       Name = "CMS Extermal Http Listener"
    }
}

# Balanceador de carga Interno (Internal ALB)
resource "aws_lb" "internal_lb" {
  name               = "intern-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_security_group.id]
  subnets            = module.vpc_cms.private_subnet_ids[*]
  enable_deletion_protection = false
  tags = {
       Name = "CMS Balanceador Interno"
    }
}
 
resource "aws_lb_target_group" "internal_target_group" {
  name     = "internal-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_cms.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
       Name = "CMS Internal Target Group"
    }
}
 
resource "aws_lb_listener" "internal_http_listener" {
  load_balancer_arn = aws_lb.internal_lb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_target_group.arn
  }
  tags = {
       Name = "CMS Internal Http Listener"
    }
}

# Grupo de seguridad para ALB externo
resource "aws_security_group" "external_alb_security_group" {
  name        = "external_alb_security_group"
  vpc_id      = module.vpc_cms.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
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
       Name = "Security Group Balanceador Externo"
    }
}

# Grupo de seguridad para ALB interno
resource "aws_security_group" "internal_alb_security_group" {
  name        = "internal_alb_security_group"
  vpc_id      = module.vpc_cms.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]  # Tráfico solo interno en la VPC
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
       Name = "Security Group Balanceador Interno"
    }
}

resource "aws_launch_template" "cms_lt" {
  name_prefix   = "cms-lt-"
  image_id      = "ami-07dc1ccdcec3b4eab"  
  instance_type = "t2.micro"
  user_data     = base64encode(data.template_file.user_data.rendered)
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.Security_Group_cms.id]
    }
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_instance_profile.name
  }
  tags = {
       Name = "CMS Launch Template"
    }
}

# Grupo de Autoescalado 
resource "aws_autoscaling_group" "cms_autoescalado" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = module.vpc_cms.private_subnet_ids[*]
  launch_template {
    id      = aws_launch_template.cms_lt.id
  }
  target_group_arns = [
    aws_lb_target_group.external_target_group.arn,   # Externo
    aws_lb_target_group.internal_target_group.arn    # Interno
  ]
  health_check_type         = "EC2"
  health_check_grace_period = 300
    tag {
    key                 = "Name"
    value               = "cms EC2 Instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "CMS Grupo Autoescalado"
    propagate_at_launch = false  
  }
}