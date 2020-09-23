
data "aws_s3_bucket_object" "replicator_zip" {
  bucket = var.lambda_binary_bucket
  key    = "sdc-dot-cvp-ingest/firehose_replicator.zip"
}

# This lambda is intended to replicate 1-way, so do not put this in the ECS cloud
# These lambdas are identical except that they take input from different streams,
# and accordingly drop them into different ECS destinations
resource "aws_lambda_function" "FirehoseReplicatorAlertsLambda" {
  count = var.is_quarantine_account ? 1 : 0
  description       = "Replicates alert files from quarantine firehose into the ECS raw submissions bucket"
  s3_bucket         = data.aws_s3_bucket_object.replicator_zip.bucket
  s3_key            = data.aws_s3_bucket_object.replicator_zip.key
  s3_object_version = data.aws_s3_bucket_object.replicator_zip.version_id
  function_name     = "${var.environment}-dot-cvp-ingest-firehose-replicator-alerts"
  role              = aws_iam_role.firehose_replicator_role.arn
  handler           = "firehose_replicator.lambda_handler"
  runtime           = "python3.7"
  timeout           = 60
  memory_size       = 128
  tags              = local.global_tags
  environment {
    variables = {
      ECS_BUCKET_NAME  = local.ecs_raw_bucket_name,
      ECS_OBJECT_PREFIX = "cv/wydot/alert"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_http_egress.id]
    subnet_ids         = var.subnet_ids
  }
}

resource "aws_lambda_function" "FirehoseReplicatorTIMLambda" {
  count = var.is_quarantine_account ? 1 : 0
  description       = "Replicates TIM (Traveller Information Message) files from quarantine firehose into the ECS raw submissions bucket"
  s3_bucket         = data.aws_s3_bucket_object.replicator_zip.bucket
  s3_key            = data.aws_s3_bucket_object.replicator_zip.key
  s3_object_version = data.aws_s3_bucket_object.replicator_zip.version_id
  function_name     = "${var.environment}-dot-cvp-ingest-firehose-replicator-tim"
  role              = aws_iam_role.firehose_replicator_role.arn
  handler           = "firehose_replicator.lambda_handler"
  runtime           = "python3.7"
  timeout           = 60
  memory_size       = 128
  tags              = local.global_tags
  environment {
    variables = {
      ECS_BUCKET_NAME  = local.ecs_raw_bucket_name,
      ECS_OBJECT_PREFIX = "cv/wydot/TIM"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_http_egress.id]
    subnet_ids         = var.subnet_ids
  }
}

resource "aws_lambda_function" "FirehoseReplicatorBSMLambda" {
  count = var.is_quarantine_account ? 1 : 0
  description       = "Replicates BSM (Basic Safety Message) files from quarantine firehose into the ECS raw submissions bucket"
  s3_bucket         = data.aws_s3_bucket_object.replicator_zip.bucket
  s3_key            = data.aws_s3_bucket_object.replicator_zip.key
  s3_object_version = data.aws_s3_bucket_object.replicator_zip.version_id
  function_name     = "${var.environment}-dot-cvp-ingest-firehose-replicator-bsm"
  role              = aws_iam_role.firehose_replicator_role.arn
  handler           = "firehose_replicator.lambda_handler"
  runtime           = "python3.7"
  timeout           = 60
  memory_size       = 128
  tags              = local.global_tags
  environment {
    variables = {
      ECS_BUCKET_NAME  = local.ecs_raw_bucket_name,
      ECS_OBJECT_PREFIX = "cv/wydot/BSM"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_http_egress.id]
    subnet_ids         = var.subnet_ids
  }
}