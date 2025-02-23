resource "aws_cloudfront_distribution" "www_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    // Sobre balanceador URL!
    domain_name=aws_lb.external_lb.dns_name 
    # Sobre S3 bucket's URL!
    #domain_name = aws_s3_bucket.s3_bucket_cms.bucket_domain_name
    origin_id = var.web_domain
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id = var.web_domain
    min_ttl          = 0
    default_ttl      = 86400
    max_ttl          = 31536000
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      } 
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true       // Usa el certificado por defecto de CloudFront (HTTP solo)
   # acm_certificate_arn = aws_acm_certificate.certdomain.arn
   # ssl_support_method  = "sni-only"
  }
 tags = {
    Name = "CMS Cloud Front Distribution"
  }
}
 
