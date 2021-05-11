data "aws_s3_bucket_object" "replicator_zip" {
  bucket = var.lambda_binary_bucket
  key    = "sdc-dot-${var.data_providers[0]["project"]}-ingest/firehose_replicator.zip"
}

# These lambdas are identical except that they take input from different streams,
# and accordingly drop them into different ECS destinations
resource "aws_lambda_function" "FirehoseReplicatorAlertsLambda" {
  description       = "Replicates alert files from this account into the mirrored raw submissions bucket"
  s3_bucket         = data.aws_s3_bucket_object.replicator_zip.bucket
  s3_key            = data.aws_s3_bucket_object.replicator_zip.key
  s3_object_version = data.aws_s3_bucket_object.replicator_zip.version_id
  function_name     = "${var.environment}-dot-oss4its-ingest-firehose-replicator-alerts"
  role              = aws_iam_role.firehose_replicator_role.arn
  handler           = "firehose_replicator.lambda_handler"
  runtime           = "python3.7"
  timeout           = 60
  memory_size       = 128
  tags              = local.global_tags
  environment {
    variables = {
      ECS_BUCKET_NAME  = local.mirror_raw_bucket_name,
      ECS_OBJECT_PREFIX = "cv/oss4its/alert"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_http_egress.id]
    subnet_ids         = var.subnet_ids
  }
}
