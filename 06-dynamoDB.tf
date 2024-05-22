module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "langchain-memory"
  hash_key  = "TimeStamp"
  range_key = "sessionId"

  attributes = [
    {
      name = "TimeStamp"
      type = "S"
    },
    {
      name = "sessionId"
      type = "S"
    },
  ]
}