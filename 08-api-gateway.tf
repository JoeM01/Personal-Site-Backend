module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "Web-App-API"
  description   = "HTTP API for personal web app."
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_domain_name = false

  routes = {
    "POST /generate" = {
      integration = {
          lambda_arn             = module.lambda_function.lambda_function_arn
          payload_format_version = "2.0"
          timeout_milliseconds   = 12000
        }
    }
}
}

resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*"
}

output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

