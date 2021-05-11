
provider "aws" {
  version = "~> 2.45"
  region = "us-east-1"
  profile = "sdc"
}

terraform {
  required_version = "~> 0.12"

  backend "s3" {
    region = "us-east-1"
  }
}
