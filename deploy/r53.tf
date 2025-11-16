resource "aws_route53_zone" "klbdesigns" {
  name = "klbdesigns.art"
}

resource "aws_route53_record" "klbdesigns_ipv4" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "klbdesigns.art"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.klbdesigns.domain_name
    zone_id                = aws_cloudfront_distribution.klbdesigns.hosted_zone_id
  }
}

resource "aws_route53_record" "klbdesigns_ipv6" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "klbdesigns.art"
  type    = "AAAA"

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.klbdesigns.domain_name
    zone_id                = aws_cloudfront_distribution.klbdesigns.hosted_zone_id
  }
}

resource "aws_route53_record" "klbdesigns_ns" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.klbdesigns.zone_id
  name            = "klbdesigns.art"
  type            = "NS"
  ttl             = 172800

  records = [
    "ns-951.awsdns-54.net.",
    "ns-174.awsdns-21.com.",
    "ns-1558.awsdns-02.co.uk.",
    "ns-1496.awsdns-59.org.",
  ]
}

resource "aws_route53_record" "klbdesigns_soa" {
  allow_overwrite = true
  zone_id         = aws_route53_zone.klbdesigns.zone_id
  name            = "klbdesigns.art"
  type            = "SOA"
  ttl             = 900

  records = [
    "ns-951.awsdns-54.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}
