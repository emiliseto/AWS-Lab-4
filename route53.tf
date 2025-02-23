
/*
resource "aws_route53_record" "wwwroute53www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${var.web_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "wwwroute53" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.web_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
*/