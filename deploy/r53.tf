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

resource "aws_route53_record" "klbdesigns_dmarc" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "_dmarc.klbdesigns.art"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=quarantine; pct=90; rua=mailto:bradyharper11@googlemail.com"
  ]
}

resource "aws_route53_record" "klbdesigns_resend" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "resend._domainkey.klbdesigns.art"
  type    = "TXT"
  ttl     = 300

  records = [
    "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9J3pAXJwW4boDfNE5m/yNqNn3dZ+fEssu23I72pY81yrXiymvBqTiSqDc4ngctIwKTeQVH0jHsFqqTga+UdtmeXq8gu21XsWZwiwQlIws5OKrS5zp9cM66+xVj6R2uHImvrzKJyGW+xtyikxXm3g4DSOsiCG7PW/1l4rx+z2wuQIDAQAB"
  ]
}

resource "aws_route53_record" "klbdesigns_send_mx" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "send.klbdesigns.art"
  type    = "MX"
  ttl     = 300

  records = [
    "10 feedback-smtp.us-east-1.amazonses.com"
  ]
}

resource "aws_route53_record" "klbdesigns_send_txt" {
  zone_id = aws_route53_zone.klbdesigns.zone_id
  name    = "send.klbdesigns.art"
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:amazonses.com ~all"
  ]
}
