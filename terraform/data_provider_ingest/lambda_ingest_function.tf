

locals {
  lambda_name = "${var.environment}-dot-sdc-${var.data_provider['name']}-manual-ingest"
}

resource "aws_lambda_function" "ingest_lambda" {
  s3_bucket = var.lambda_binary_bucket
  s3_key = "sdc-dot-cvp-ingest/ingest_lambda.zip"
  function_name = locals.lambda_name
  role = aws_iam_role.ingest_lambda_lambda_role.arn
  handler = "data_processor.lambda_handler"
  source_code_hash = base64sha256(timestamp()) # Bust cache of deployment... we want a fresh deployment everytime Terraform runs for now...
  runtime = "python3.7"
  timeout = 900 # apparently some of these files get LARGE and can take a while to copy over
  tags = var.global_tags
  environment {
    TARGET_DATA_BUCKET = var.data_lake_bucket
    BUCKET_PATH_MAPPING = jsonencode(map(var.data_provider['ingest_bucket'], var.data_provider['data_lake_destination']))
  }
  vpc_config {
    security_group_ids = var.vpc_id
    subnet_ids = var.subnet_ids
  }
}

resource "aws_iam_role" "ingest_lambda_lambda_role" {
    name = locals.lambda_name
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_number}:root",
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_policy" "LambdaPermissions" {
    name = locals.lambda_name
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:CreateLogGroup",
      "Resource": "arn:aws:logs:${var.aws_region}:${var.account_number}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:${var.aws_region}:${var.account_number}:log-group:/aws/lambda/${locals.lambda_name}:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.data_provider_manual_ingest_bucket.name}/*", "arn:aws:s3:::${aws_s3_bucket.data_provider_manual_ingest_bucket.name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
      ],
      "Resource": ["arn:aws:s3:::${var.data_lake_bucket}/*", "arn:aws:s3:::${var.data_lake_bucket}"]
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "CloudWatchLogsAttachment" {
    role = aws_iam_role.LambdaRole.name
    policy_arn = aws_iam_policy.LambdaPermissions.arn
}
