/*
resource "aws_acm_certificate" "certdomain" {
  //count             = var.wissvercom ? 1 : 0
  domain_name       = var.web_domain
  validation_method = "DNS"
  subject_alternative_names = ["www.${var.web_domain}"]
#   tags = {
#     Environment = var.environment
#   }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_record" {

  for_each = {
    for dvo in aws_acm_certificate.certdomain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }


  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.certdomain.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

*/