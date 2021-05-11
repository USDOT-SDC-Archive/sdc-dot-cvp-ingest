data "aws_s3_bucket_object" "lambda_zip" {
   bucket = var.lambda_binary_bucket
  key = "sdc-dot-${var.data_providers[0]["project"]}-ingest/data_processor.zip"
}

resource "aws_lambda_function" "IngestLambda" {
    count = length(var.data_providers)
    s3_bucket = data.aws_s3_bucket_object.lambda_zip.bucket
    s3_key =  data.aws_s3_bucket_object.lambda_zip.key
    s3_object_version = data.aws_s3_bucket_object.lambda_zip.version_id
    function_name = "${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-ingest"
    role = aws_iam_role.IngestLambdaRole[count.index].arn
    handler = "data_processor.lambda_handler"
    runtime = "python3.7"
    timeout = 900 # apparently some of these files get LARGE and can take a while to copy over
    tags = merge({Name = var.data_providers[count.index]["ingest_bucket"],
                  Team = var.data_providers[count.index]["team"],
                  Project = var.data_providers[count.index]["project"]}, local.team_global_tags)
    environment {
        variables = {
            TARGET_DATA_BUCKET = var.data_lake_bucket
            BUCKET_PATH_MAPPING = jsonencode(map(var.data_providers[count.index]["ingest_bucket"], var.data_providers[count.index]["data_lake_destination"]))
        }
    }
    vpc_config {
        security_group_ids = [aws_security_group.lambda_http_egress.id]
        subnet_ids = var.subnet_ids
    }
depends_on = [aws_iam_role.IngestLambdaRole,aws_iam_role_policy_attachment.CloudWatchLogsAttachment]
}

resource "aws_cloudwatch_metric_alarm" "IngestLambdaErrors" {
  count = length(var.data_providers)
  alarm_name = "${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest-errors"
  alarm_description = "Monitor errors for the ${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest function"

  namespace = "AWS/Lambda"
  dimensions = {
    FunctionName = "${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest"
  }
  comparison_operator = "GreaterThanThreshold"
  threshold = "0"
  evaluation_periods = "1"
  metric_name = "Errors"
  period = "60"
  statistic = "Average"
  
  alarm_actions = var.lambda_error_actions
  tags = merge({Name = var.data_providers[count.index]["name"],
              Team = var.data_providers[count.index]["team"],
              Project = var.data_providers[count.index]["project"]}, local.team_global_tags)
}

# Must also be kept in sync with https://github.com/usdot-jpo-sdc-projects/sdc-dot-waze-pipeline/blob/master/terraform/raw_submissions_s3_bucket.tf#L78
resource "aws_iam_role" "IngestLambdaRole" {
  count = length(var.data_providers)
  name = "${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest"
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
    count = length(var.data_providers)
    name = "${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs"
      ],
      "Resource": [
        "*"
      ]
    },
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
          "arn:aws:logs:${var.aws_region}:${var.account_number}:log-group:/aws/lambda/${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.data_provider_manual_ingest_bucket[count.index].bucket}/*", "arn:aws:s3:::${aws_s3_bucket.data_provider_manual_ingest_bucket[count.index].bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": ["arn:aws:s3:::${var.data_lake_bucket}/*", "arn:aws:s3:::${var.data_lake_bucket}"]
    },
    {
      "Sid": "AllowPushToMirrorRawSubmission",
      "Effect": "Allow",
      "Action": [
       "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": "${local.mirror_raw_bucket_arn}/*"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "CloudWatchLogsAttachment" {
    count = length(var.data_providers)
    role = aws_iam_role.IngestLambdaRole[count.index].name
    policy_arn = aws_iam_policy.LambdaPermissions[count.index].arn
}

resource "aws_lambda_permission" "AllowLambdaTriggerFromUpload" {
    count = length(var.data_providers)
    statement_id  = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.IngestLambda[count.index].arn
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.data_provider_manual_ingest_bucket[count.index].arn
}

resource "aws_s3_bucket_notification" "BucketNotification" {
    count = length(var.data_providers)
    bucket = aws_s3_bucket.data_provider_manual_ingest_bucket[count.index].id

    lambda_function {
        lambda_function_arn = aws_lambda_function.IngestLambda[count.index].arn
        events = ["s3:ObjectCreated:*"]
    }

    depends_on = [aws_lambda_permission.AllowLambdaTriggerFromUpload]
}
