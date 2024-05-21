module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Lang-Chain-Handler"
  description   = "Function handling logic for Langchain/OpenAi integration"
  handler       = "index.lambda_handler"
  runtime       = "nodejs20.x"

    create_package      = false
  local_existing_package = "./lambda_function.zip"

  environment_variables = {
    OPENAI_API_KEY = "sk-proj-arcogGyODm7CMuDFXCbeT3BlbkFJKwF20h9lYPsRQmETvTI9"
  }

}