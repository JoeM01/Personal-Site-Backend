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

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}



module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  timeout = 10

  create_package         = false
  local_existing_package = "./lambda_function.zip"

  environment_variables = {
    OPENAI_API_KEY = var.openai_api_key
    LANGCHAIN_TRACING_V2 = var.langchain_tracing
    LANGCHAIN_API_KEY = var.langchain_api_key
  }

}