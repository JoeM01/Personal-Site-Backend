resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-deployment-bucket"
}



resource "null_resource" "package_lambda_function" {
  provisioner "local-exec" {
    command     = "./package-lambda.sh"
    interpreter = ["bash", "-c"]
  }

}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "lambda_function.zip"

  depends_on = [ null_resource.package_lambda_function ]
}