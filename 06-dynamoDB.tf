module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = "langchain-memory"
  hash_key = "sessionId"

  attributes = [
    {
      name = "sessionId"
      type = "N"
    },
    {
      name = "role"
      type = "S"
    },
    {
      name = "message"
      type = "S"
    }
  ]
}