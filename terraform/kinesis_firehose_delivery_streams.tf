resource "aws_iam_policy" "firehose_managed_policy" {
    count = length(var.data_providers)
    description = "${var.data_providers[count.index]["project"]} Kinesis firehose policy"
    name        = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-kinesis-policy"
    path        = "/"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:firehose:*:*:deliverystream/${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "firehose:DescribeDeliveryStream",
                "firehose:ListDeliveryStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Stmt3",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${aws_lambda_function.FirehoseReplicatorAlertsLambda.arn}:$LATEST"
        },
        {
            "Sid": "Stmt4",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${local.data_lake_bucket_arn}/*",
                "${local.data_lake_bucket_arn}"
            ]
        }
    ]
}
    EOF
}

resource "aws_iam_role" "firehose_role" {
    count = length(var.data_providers)
    assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOF
    description           = "${var.data_providers[count.index]["project"]} Kinesis firehose role"
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-kinesis-role"
    path                  = "/"
    tags                  = {
        Environment = var.environment,
        Project = var.data_providers[count.index]["project"],
        Team = var.data_providers[count.index]["team"]
    }
}

resource "aws_iam_role_policy_attachment" "firehose_attach_policy" {
    policy_arn = aws_iam_policy.firehose_managed_policy[0].arn
    role = aws_iam_role.firehose_role[0].name
}

resource "aws_iam_role_policy" "firehose_inline_policy_1" {
    name   = "oneClick_firehose_delivery_role_1530016803472"
    count = length(var.data_providers)
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "glue:GetTableVersions"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${local.data_lake_bucket_arn}",
                "${local.data_lake_bucket_arn}/*",
                "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%",
                "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "arn:aws:lambda:${var.aws_region}:${var.account_number}:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "${var.data_lake_kms_key_arn}"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.${var.aws_region}.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "${local.data_lake_bucket_arn}/${var.data_providers[count.index]["project"]}/alert/*"
                }
            }
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${var.account_number}:log-group:/aws/kinesisfirehose/${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-alert:log-stream:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords"
            ],
            "Resource": "arn:aws:kinesis:${var.aws_region}:${var.account_number}:stream/%FIREHOSE_STREAM_NAME%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:region:accountid:key/%SSE_KEY_ARN%"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "kinesis.%REGION_NAME%.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:${var.account_number}:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = aws_iam_role.firehose_role[0].name
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_OSS4ITS_alert" {
    count = length(var.data_providers)
    destination    = "extended_s3"
    name           = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-alert"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[count.index]["project"],
        Team = var.data_providers[count.index]["team"]
    }

    extended_s3_configuration {
        bucket_arn         = local.data_lake_bucket_arn
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = var.data_lake_kms_key_arn
        prefix             = var.data_providers[count.index]["project"]
        role_arn           = aws_iam_role.firehose_role[0].arn
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-${var.data_providers[count.index]["project"]}-alert"
            log_stream_name = "S3Delivery"
        }

        processing_configuration {
            enabled = true

            processors {
                type = "Lambda"

                parameters {
                    parameter_name  = "LambdaArn"
                    parameter_value = "${aws_lambda_function.FirehoseReplicatorAlertsLambda.arn}:$LATEST"
                }
            }
        }
    }

    server_side_encryption {
        enabled = false
    }
depends_on = [aws_iam_role.firehose_role]
}
resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_alert_s3_errors" {
    count = length(var.data_providers)
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-${var.data_providers[count.index]["project"]}-alert-kinesis-firehose-delivery-to-s3-errors"
    alarm_name                = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-${var.data_providers[count.index]["project"]}-alert-kinesis-firehose-delivery-to-s3-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = "aws_kinesis_firehose_delivery_stream.kinesis_firehose_OSS4ITS_alert.name"
    }
    evaluation_periods        = 1
    insufficient_data_actions = []
    metric_name               = "DeliveryToS3.Success"
    namespace                 = "AWS/Firehose"
    ok_actions                = []
    period                    = 300
    statistic                 = "Average"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[count.index]["project"],
        Team = var.data_providers[count.index]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_OSS4ITS_alert_errors" {

    count = length(var.data_providers)
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-alert-kinesis-firehose-errors"
    alarm_name                = "${var.environment}-dot-sdc-${var.data_providers[count.index]["project"]}-alert-kinesis-firehose-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = "aws_kinesis_firehose_delivery_stream.kinesis_firehose_OSS4ITS_alert.name"
    }
    evaluation_periods        = 1
    insufficient_data_actions = []
    metric_name               = "DescribeDeliveryStream.Requests"
    namespace                 = "AWS/Firehose"
    ok_actions                = []
    period                    = 300
    statistic                 = "Average"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[count.index]["project"],
        Team = var.data_providers[count.index]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}
