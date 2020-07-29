variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "account_number" {
  type = string
}

variable "lambda_binary_bucket" {
  type = string
  description = "The bucket that has the Lambda binary"
}

variable "data_lake_bucket" {
    type = string
    description = "The name of the data lake S3 bucket where raw data resides"
}

variable "vpc_id" {
  type = string
  description = "The VPC to attach the Lambdas to"
}

variable "subnet_ids" {
  type = list
  description = "The subnets to attach the Lambda to"
}

variable "data_provider" {
    type = object({
        ingest_bucket = string
        name = string
        project = string
        team = string
        data_lake_destination = string
    })
}

variable "team_global_tags" {
    type = object({
        SourceRepo = string
        Environment = string
    })
}