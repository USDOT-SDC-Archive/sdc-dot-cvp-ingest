
data "aws_s3_bucket_object" "replicator_zip" {
  bucket = var.lambda_binary_bucket
  key    = "sdc-dot-cvp-ingest/firehose_replicator.zip"
}

# NOTE: currently firehoses are going to a mishmash of test/dev raw buckets - we can try dev
# and see if it works
# locals {
#   mismatch_env = var.ingestion_filter_bucket_mismatch ? "test" : var.environment
# }
# # Raw Submission bucket.
# data "aws_s3_bucket" "raw_submissions_bucket" {
#   bucket = "${local.mismatch_env}-dot-sdc-raw-submissions-${local.account_number}-us-east-1"
# }

# This lambda is intended to replicate 1-way, so do not put this in the ECS cloud
resource "aws_lambda_function" "FirehoseReplicatorLambda" {
  count = var.is_quarantine_account ? 1 : 0
  description       = "Replicates files from quarantine firehose into the ECS raw submissions bucket"
  s3_bucket         = data.aws_s3_bucket_object.replicator_zip.bucket
  s3_key            = data.aws_s3_bucket_object.replicator_zip.key
  s3_object_version = data.aws_s3_bucket_object.replicator_zip.version_id
  function_name     = "${var.environment}-dot-cvp-ingest-firehose-replicator"
  role              = aws_iam_role.firehose_replicator_role.arn
  handler           = "firehose_replicator.lambda_handler"
  runtime           = "python3.7"
  timeout           = 60
  memory_size       = 128
  tags              = local.global_tags
  environment {
    variables = {
      ECS_BUCKET_NAME  = local.ecs_raw_bucket_name
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_http_egress.id]
    subnet_ids         = var.subnet_ids
  }
}