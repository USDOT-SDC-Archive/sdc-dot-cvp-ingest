environment = "dev"
aws_region = "us-east-1"
account_number = "505135622787"
vpc_id = "vpc-05edb6463359c7c07"
subnet_ids = ["subnet-0f6f996e1255c2e17",
              "subnet-00469310e3c8854b2"]
data_providers = [{
   
    ingest_bucket = "dev.sdc.dot.gov.data-lake.drop-zone.oss4its"
    project = "OSS4ITS"
    team = "oss4its"
    name = "oss4its"
    data_lake_destination = "oss4its/"
}]
data_lake_bucket = "dev.sdc.dot.gov.data-lake.raw-data"
data_lake_kms_key_arn = "arn:aws:kms:us-east-1:505135622787:key/a5480c3b-e32b-44f4-b9c4-4804b2ff331e"
lambda_binary_bucket = "dev.sdc.dot.gov.data-lake.raw-data"
lambda_error_actions = [] # insert SNS topic ARN here to send emails for errors
cloudwatch_sns_topics = []
mirror_account_number = "505135622787"
