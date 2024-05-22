resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-deployment-bucket-for-langchain"
}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "./lambda_function.zip"

}