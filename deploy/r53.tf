resource "aws_route53_zone" "klbdesigns" {
  name = "klbdesigns.art"
}

resource "aws_route53_record" "klbdesigns-ipv4" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "klbdesigns.art"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.klbdesigns.domain_name
    zone_id                = aws_cloudfront_distribution.klbdesigns.hosted_zone_id
  }
}

resource "aws_route53_record" "klbdesigns-ipv6" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "klbdesigns.art"
  type    = "AAAA"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.klbdesigns.domain_name
    zone_id                = aws_cloudfront_distribution.klbdesigns.hosted_zone_id
  }
}
