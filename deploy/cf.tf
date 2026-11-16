resource "aws_cloudfront_origin_access_control" "klbdesigns" {
  name                              = "klbdesigns"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "klbdesigns" {
  aliases = ["klbdesigns.art"]

  origin {
    domain_name              = aws_s3_bucket.klbdesigns.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.klbdesigns.id
    origin_id                = "klbdesigns"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "klbdesigns"
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # S3 + OAC returns 403 for missing keys
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:592367451035:certificate/861a34b1-bfcb-446f-add5-edf40771e171"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = file("../functions/cloudfront.js")
}

resource "null_resource" "invalidation" {
  depends_on = [aws_cloudfront_distribution.klbdesigns, aws_s3_bucket.klbdesigns]

  triggers = {
    always_trigger = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.klbdesigns.id} --paths '/*'"
  }
}
