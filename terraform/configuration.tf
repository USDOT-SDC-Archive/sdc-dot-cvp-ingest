provider "aws" {
  version = "~> 2.0"
  profile = "sdc"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    key = "sdc-dot-cvp-ingest/terraform/terraform.tfstate"
    region = "us-east-1"
  }
}