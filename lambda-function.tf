module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.lambda_handler"
  runtime       = "nodejs20.x"

    create_package      = false
  source_path = "./lambda_function.zip"

}