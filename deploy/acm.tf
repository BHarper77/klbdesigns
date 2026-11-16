resource "aws_acm_certificate" "klbdesigns" {
  provider                  = aws.us_east_1
  domain_name               = "klbdesigns.art"
  subject_alternative_names = ["www.klbdesigns.art"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.klbdesigns.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.klbdesigns.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "klbdesigns" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.klbdesigns.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
