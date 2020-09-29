environment = "prod"
aws_region = "us-east-1"
account_number = "004118380849"
vpc_id = "vpc-0940031cf3186bad0"
subnet_ids = ["subnet-098cd565511d1debf", "subnet-004cda11d1e95bbf9"]
data_providers = [{
    ingest_bucket = "prod-dot-sdc-cvp-nyc-ingest-004118380849"
    mirror_bucket = "prod-dot-sdc-cvp-nyc-ingest"
    project = "CVP"
    team = "cvp-nyc"
    name = "cvpep-nyc"
    data_lake_destination = "cv/nyc/"
},
{
    ingest_bucket = "prod-dot-sdc-cvp-thea-ingest-004118380849"
    mirror_bucket = "prod-dot-sdc-cvp-thea-ingest"
    team = "cvp-thea"
    project = "CVP"
    name = "cvpep-thea"
    data_lake_destination = "cv/thea/"
},
{
    ingest_bucket = "prod-dot-sdc-cvp-wydot-ingest-004118380849"
    mirror_bucket = "prod-dot-sdc-cvp-wydot-ingest"
    project = "CVP"
    team = "cvp-wydot"
    name = "cvpep-wydot"
    data_lake_destination = "cv/wydot/"
}]
data_lake_bucket = "prod-dot-sdc-raw-submissions-004118380849-us-east-1"
data_lake_kms_key_arn = "arn:aws:kms:us-east-1:004118380849:alias/aws/s3"
lambda_binary_bucket = "prod-lambda-bucket-004118380849"
lambda_error_actions = ["arn:aws:sns:us-east-1:004118380849:prod-hadoop-ingestion-errors"] # insert SNS topic ARN here to send emails for errors
cloudwatch_sns_topics = ["arn:aws:sns:us-east-1:004118380849:prod-hadoop-ingestion-errors"]
mirror_account_number    = "911061262852"