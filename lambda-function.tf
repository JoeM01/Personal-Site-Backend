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


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_package         = false
  local_existing_package = "./lambda_function.zip"

  environment_variables = {
    OPENAI_API_KEY = var.openai_api_key
    LANGCHAIN_TRACING_V2 = var.langchain_tracing
    LANGCHAIN_API_KEY = var.langchain_api_key
  }

}