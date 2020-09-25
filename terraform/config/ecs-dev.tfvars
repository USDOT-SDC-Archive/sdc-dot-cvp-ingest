environment = "dev"
aws_region = "us-east-1"
account_number = "505135622787"
vpc_id = "vpc-05edb6463359c7c07"
subnet_ids = ["subnet-0f6f996e1255c2e17",
              "subnet-00469310e3c8854b2"]
# tianna can you check these tags?
data_providers = [{
    ingest_bucket = "dev-dot-sdc-cvp-nyc-ingest-505135622787"
    project = "CVP"
    team = "cvp-nyc"
    name = "cvpep-nyc"
    data_lake_destination = "cv/nyc/"
},
{
    ingest_bucket = "dev-dot-sdc-cvp-thea-ingest-505135622787"
    team = "cvp-thea"
    project = "CVP"
    name = "cvpep-thea"
    data_lake_destination = "cv/thea/"
},
{
    ingest_bucket = "dev-dot-sdc-cvp-wydot-ingest-505135622787"
    project = "CVP"
    team = "cvp-wydot"
    name = "cvpep-wydot"
    data_lake_destination = "cv/wydot/"
}]
data_lake_bucket = "dev-dot-sdc-raw-submissions-505135622787-us-east-1"
data_lake_kms_key_arn = "arn:aws:kms:us-east-1:505135622787:key/a5480c3b-e32b-44f4-b9c4-4804b2ff331e"
lambda_binary_bucket = "dev-lambda-bucket-505135622787"
lambda_error_actions = [] # insert SNS topic ARN here to send emails for errors
cloudwatch_sns_topics = []
mirror_account_number    = "911061262852"