module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name      = "langchain-memory"
  range_key = "timeStamp"
  hash_key  = "sessionId"

  attributes = [
    {
      name = "sessionId"
      type = "S"
    },
    {
      name = "timeStamp"
      type = "S"
    },
  ]

  ttl_enabled = true
  ttl_attribute_name = "timeToLive"

}