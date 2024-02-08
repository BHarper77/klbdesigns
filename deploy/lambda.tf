locals {
  lambda_zip  = "lambda_package.zip"
  lambda_name = "klbdesigns-email-service"
}

resource "aws_lambda_function" "email_service" {
  filename         = local.lambda_zip
  function_name    = local.lambda_name
  role             = aws_iam_role.email_service.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.email_service.output_base64sha256
  runtime          = "nodejs20.x"

  environment {
    variables = {
      API_KEY = var.resend_api_key
    }
  }
}

resource "aws_iam_role" "email_service" {
  name               = local.lambda_name
  assume_role_policy = data.aws_iam_policy_document.email_service.json
}

data "aws_iam_policy_document" "email_service" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "email_service" {
  type        = "zip"
  source_file = "../lambda/index.js"
  output_path = local.lambda_zip
}

resource "aws_lambda_function_url" "email_service" {
  function_name      = aws_lambda_function.email_service.function_name
  authorization_type = "AWS_IAM"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["POST"]
  }
}
