resource "aws_iam_role" "klbdesigns_invoke_lambda" {
  name               = "klbdesigns-invoke-lambda"
  assume_role_policy = data.aws_iam_policy_document.klbdesigns_invoke_lambda.json
}

data "aws_iam_policy_document" "klbdesigns_invoke_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}
