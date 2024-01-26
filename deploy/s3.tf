resource "aws_s3_bucket" "klbdesigns" {
  bucket = "klbdesigns"
}

resource "aws_s3_bucket_website_configuration" "klbdesigns" {
  bucket = aws_s3_bucket.klbdesigns.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "klbdesigns" {
  bucket = aws_s3_bucket.klbdesigns.id
  policy = data.aws_iam_policy_document.klbdesigns.json
}

data "aws_iam_policy_document" "klbdesigns" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.klbdesigns.id}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_object" "klbdesigns" {
  for_each = fileset("../dist/", "**")
  bucket   = aws_s3_bucket.klbdesigns.id
  key      = each.value
  source   = "../dist/${each.value}"
  etag     = filemd5("../dist/${each.value}")
  #   set correct content types for svgs and HTML files
  content_type = length(regexall("\\.svg", each.value)) > 0 ? "image/svg+xml" : "text/html"
}
