# resource "aws_iam_role" "klbdesigns_invoke_lambda" {
#   name               = "klbdesigns-invoke-lambda"
#   assume_role_policy = data.aws_iam_policy_document.klbdesigns_invoke_lambda.json
# }

# resource "aws_iam_role_policy" "klbdesigns_invoke_lambda" {
#   name   = "klbdesigns-invoke-lambda"
#   role   = aws_iam_role.klbdesigns_invoke_lambda.id
#   policy = data.aws_iam_policy_document.klbdesigns_invoke_lambda.json
# }

# data "aws_iam_policy_document" "klbdesigns_invoke_lambda" {
#   statement {
#     actions   = ["lambda:InvokeFunctionUrl"]
#     resources = [aws_lambda_function.email_service.id]
#   }
# }
