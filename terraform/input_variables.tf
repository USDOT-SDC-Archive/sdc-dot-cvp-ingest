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

variable "data_lake_kms_key_arn" {
  type = string
  description = "The arn of the data lake S3 KMS Key for data-at-rest encryption"
}

variable "lambda_error_actions" {
  type = list
  description = "The list of SNS topics to send a notification to if the Lambdas throw an error"
}

variable "cloudwatch_sns_topics" {
  type = list
  description = "The SNS topics to send notifications to for CloudWatch alarms"
}

variable "ecs_account_number" {
  type = string
  description = "The account number for the 'ECS' account within the DOT network"
  default = ""
}

variable "is_quarantine_account" {
  type = bool
  description = "True if you are running apply from the old non-OT 'quarantine' account"
  default = false
}

locals {
  team_global_tags = {
      SourceRepo = "sdc-dot-cvp-ingest"
      Environment = var.environment
  }
  global_tags = merge(local.team_global_tags, {
      Project = "SDC-Platform"
      Team = "sdc-platform"
      Owner = "SDC support team"
  })
  ecs_raw_bucket_arn = "arn:aws:s3:::${var.environment}-dot-sdc-raw-submissions-${var.ecs_account_number}-us-east-1"
  data_lake_bucket_arn = "arn:aws:s3:::${var.data_lake_bucket}"
}