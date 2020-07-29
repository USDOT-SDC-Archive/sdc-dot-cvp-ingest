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

variable "vpc_id" {
  type = string
  description = "The VPC to attach the Lambdas to"
}

variable "subnet_ids" {
  type = list
  description = "The subnets to attach the Lambda to"
}

variable "data_providers" {
    type = list(object({
        ingest_bucket = string
        name = string
        project = string
        team = string
        data_lake_destination = string
    }))
}

variable "data_lake_bucket" {
    type = string
    description = "The name of the data lake S3 bucket where raw data resides"
}

locals {
    team_global_tags = {
        SourceRepo = "sdc-dot-cvp-ingest"
        Environment = var.environment
    }
}

locals {
    global_tags = merge(local.team_global_tags, {
        Project = "SDC-Platform"
        Team = "sdc-platform"
        Owner = "SDC support team"
    })
}