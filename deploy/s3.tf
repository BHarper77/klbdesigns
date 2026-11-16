resource "aws_s3_bucket" "klbdesigns" {
  bucket = "klbdesigns"
}

resource "aws_s3_bucket_website_configuration" "klbdesigns" {
  bucket = aws_s3_bucket.klbdesigns.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "klbdesigns" {
  bucket = aws_s3_bucket.klbdesigns.id
  policy = data.aws_iam_policy_document.klbdesigns.json
}

data "aws_iam_policy_document" "klbdesigns" {
  #   enable access to nested docs
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.klbdesigns.id}/*/**",
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.klbdesigns.arn]
    }
  }
  #   enable access to index document
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.klbdesigns.id}/*",
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.klbdesigns.arn]
    }
  }
}

resource "aws_s3_object" "klbdesigns" {
  for_each = fileset("../dist/", "**")
  bucket   = aws_s3_bucket.klbdesigns.id
  key      = each.value
  source   = "../dist/${each.value}"
  etag     = filemd5("../dist/${each.value}")
  #   set correct content types by extension (html is the default)
  content_type = (
    length(regexall("\\.svg$", each.value)) > 0 ? "image/svg+xml" :
    length(regexall("\\.png$", each.value)) > 0 ? "image/png" :
    length(regexall("\\.(jpe?g)$", each.value)) > 0 ? "image/jpeg" :
    length(regexall("\\.webp$", each.value)) > 0 ? "image/webp" :
    length(regexall("\\.ico$", each.value)) > 0 ? "image/x-icon" :
    length(regexall("\\.css$", each.value)) > 0 ? "text/css" :
    length(regexall("\\.m?js$", each.value)) > 0 ? "text/javascript" :
    length(regexall("\\.json$", each.value)) > 0 ? "application/json" :
    length(regexall("\\.webmanifest$", each.value)) > 0 ? "application/manifest+json" :
    length(regexall("\\.xml$", each.value)) > 0 ? "application/xml" :
    length(regexall("\\.txt$", each.value)) > 0 ? "text/plain" :
    length(regexall("\\.woff2$", each.value)) > 0 ? "font/woff2" :
    "text/html"
  )
  # hashed build assets are immutable; everything else revalidates quickly
  cache_control = startswith(each.value, "_astro/") ? "public, max-age=31536000, immutable" : "public, max-age=300"
}
