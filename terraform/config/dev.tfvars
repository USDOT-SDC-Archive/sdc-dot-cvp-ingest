environment = "dev"
aws_region = "us-east-1"
account_number = "911061262852"
vpc_id = "vpc-40a23b3b"
subnet_ids = ["subnet-1d181f40", "subnet-b29f87d6"]
# tianna can you check these tags?
data_providers = [{
    ingest_bucket = "dev-dot-sdc-cvp-nyc-ingest"
    project = "cvp"
    team = "cvp-nyc"
    name = "cvpep-nyc"
    data_lake_destination = "cv/nyc/"
}/*,
{
    ingest_bucket = "dev-dot-sdc-cvp-thea-ingest"
    team = "cvp-thea"
    project = "cvp"
    name = "cvpep-thea"
    data_lake_destination = "cv/thea/"
},
{
    ingest_bucket = "dev-dot-sdc-cvp-wydot-ingest"
    project = "cvp"
    team = "cvp-wydot"
    name = "cvpep-wydot"
    data_lake_destination = "cv/wydot/"
},
{
# NOTE: these values will change ATRI lower environment resources away from "test-" to "dev-".
# It appears things were misnamed from the beginning according to Darren
    ingest_bucket = "dev-dot-sdc-btsffa-atri-ingest"
    project = "fmi"
    team = "fmi-atri"
    name = "btsffa-atri"
    data_lake_destination = "btsffa/atri/"
}*/]
data_lake_bucket = "dev-dot-sdc-raw-submissions-911061262852-us-east-1"
lambda_binary_bucket = "dev-dot-sdc-regional-lambda-bucket-911061262852-us-east-1"