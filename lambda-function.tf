module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.lambda_handler"
  runtime       = "Node.js 20.x"

  source_path = "./lambda_function.zip"

}