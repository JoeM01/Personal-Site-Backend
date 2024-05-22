variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
}

variable "langchain_tracing" {
  description = "Langchain tracing"
  type        = string
  sensitive   = true
}

variable "langchain_api_key" {
  description = "Langchain API Key"
  type        = string
  sensitive   = true
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_dynamodb_policy"
  description = "Policy for Lambda to access DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ],
        Resource = module.dynamodb_table.dynamodb_table_arn
      }
    ]
  })
}


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  timeout = 10

  attach_policy = true
  policy        = aws_iam_policy.lambda_policy.arn

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket

  environment_variables = {
    OPENAI_API_KEY       = var.openai_api_key
    LANGCHAIN_TRACING_V2 = var.langchain_tracing
    LANGCHAIN_API_KEY    = var.langchain_api_key
  }

  depends_on = [aws_s3_object.lambda_package]
}