resource "aws_iam_policy" "firehose_managed_policy" {
    description = "WYDOT Kinesis firehose policy"
    name        = "${var.environment}-dot-sdc-cvpep-wydot-kinesis-policy"
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
                "arn:aws:firehose:*:*:deliverystream/${var.environment}-dot-sdc-cvpep-wydot-*"
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
            "Resource": [
                "${aws_lambda_function.FirehoseReplicatorAlertsLambda.arn}:$LATEST",
                "${aws_lambda_function.FirehoseReplicatorTIMLambda.arn}:$LATEST",
                "${aws_lambda_function.FirehoseReplicatorBSMLambda.arn}:$LATEST"
            ]
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
    description           = "WYDOT Kinesis firehose role"
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "${var.environment}-dot-sdc-cvpep-wydot-kinesis-role"
    path                  = "/"
    tags                  = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
}

resource "aws_iam_role_policy_attachment" "firehose_attach_policy" {
    policy_arn = aws_iam_policy.firehose_managed_policy.arn
    role = aws_iam_role.firehose_role.name
}

resource "aws_iam_role_policy" "firehose_inline_policy_1" {
    name   = "oneClick_firehose_delivery_role_1530016803472"
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
            "Resource": "arn:aws:lambda:${var.aws_region}:${local.current_account_number}:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
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
                    "kms:EncryptionContext:aws:s3:arn": "${local.data_lake_bucket_arn}/cv/wydot/alert/*"
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
                "arn:aws:logs:${var.aws_region}:${local.current_account_number}:log-group:/aws/kinesisfirehose/${var.environment}-dot-sdc-cvpep-wydot-alert:log-stream:*"
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
            "Resource": "arn:aws:kinesis:${var.aws_region}:${local.current_account_number}:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:${local.current_account_number}:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = aws_iam_role.firehose_role.name
}

resource "aws_iam_role" "firehose_wydot_bsm_role" {
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
    description           = "WYDOT Kinesis firehose role"
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "${var.environment}-dot-sdc-cvpep-wydot-bsm_role"
    path                  = "/"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
}

resource "aws_iam_role_policy" "firehose_wydot_bsm_inline_policy_1" {
    name   = "${var.environment}-dot-sdc-cvpep-wydot-bsm_policy"
    policy = <<EOF
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
                "arn:aws:firehose:*:*:deliverystream/${var.environment}-dot-sdc-cvpep-wydot-bsm"
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
                "${local.data_lake_bucket_arn}/*",
                "${local.data_lake_bucket_arn}"
            ]
        }
    ]
}
    EOF
    role   = aws_iam_role.firehose_wydot_bsm_role.name
}

resource "aws_iam_role" "firehose_wydot_tim_role" {
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
    description           = "WYDOT Kinesis firehose role"
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "${var.environment}-dot-sdc-cvpep-wydot-tim_role"
    path                  = "/"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
}

resource "aws_iam_role_policy" "firehose_wydot_tim_inline_policy_1" {
    name   = "${var.environment}-dot-sdc-cvpep-wydot-tim_policy"
    policy = <<EOF
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
                "arn:aws:firehose:*:*:deliverystream/${var.environment}-dot-sdc-cvpep-wydot-tim"
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
                "${local.data_lake_bucket_arn}/*",
                "${local.data_lake_bucket_arn}"
            ]
        }
    ]
}
    EOF
    role   = aws_iam_role.firehose_wydot_tim_role.name
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_wydot_alert" {
    destination    = "extended_s3"
    name           = "${var.environment}-dot-sdc-cvpep-wydot-alert"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }

    extended_s3_configuration {
        bucket_arn         = local.data_lake_bucket_arn
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = var.data_lake_kms_key_arn
        prefix             = "cv/wydot/alert/"
        role_arn           = aws_iam_role.firehose_role.arn
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/${var.environment}-dot-sdc-cvpep-wydot-alert"
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
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_wydot_bsm" {
    destination    = "extended_s3"
    name           = "${var.environment}-dot-sdc-cvpep-wydot-bsm"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }

    extended_s3_configuration {
        bucket_arn         = local.data_lake_bucket_arn
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = var.data_lake_kms_key_arn
        prefix             = "cv/wydot/BSM/"
        role_arn           = aws_iam_role.firehose_wydot_bsm_role.arn
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/${var.environment}-dot-sdc-cvpep-wydot-bsm"
            log_stream_name = "S3Delivery"
        }

        processing_configuration {
            enabled = true

            processors {
                type = "Lambda"

                parameters {
                    parameter_name  = "LambdaArn"
                    parameter_value = "${aws_lambda_function.FirehoseReplicatorBSMLambda.arn}:$LATEST"
                }
            }
        }
    }

    server_side_encryption {
        enabled = false
    }
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_wydot_tim" {
    destination    = "extended_s3"
    name           = "${var.environment}-dot-sdc-cvpep-wydot-tim"
    tags           = {
        Environment = var.environment,
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }

    extended_s3_configuration {
        bucket_arn         = local.data_lake_bucket_arn
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = var.data_lake_kms_key_arn
        prefix             = "cv/wydot/TIM/"
        role_arn           = aws_iam_role.firehose_wydot_tim_role.arn
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/${var.environment}-dot-sdc-cvpep-wydot-tim"
            log_stream_name = "S3Delivery"
        }

        processing_configuration {
            enabled = true

            processors {
                type = "Lambda"

                parameters {
                    parameter_name  = "LambdaArn"
                    parameter_value = "${aws_lambda_function.FirehoseReplicatorTIMLambda.arn}:$LATEST"
                }
            }
        }
    }

    server_side_encryption {
        enabled = false
    }
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_alert_s3_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-alert-kinesis-firehose-delivery-to-s3-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-alert-kinesis-firehose-delivery-to-s3-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_alert.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_alert_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-alert-kinesis-firehose-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-alert-kinesis-firehose-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_alert.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_bsm_s3_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-bsm-kinesis-firehose-delivery-to-s3-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-bsm-kinesis-firehose-delivery-to-s3-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_bsm.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_bsm_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-bsm-kinesis-firehose-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-bsm-kinesis-firehose-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_bsm.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_tim_s3_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-tim-kinesis-firehose-delivery-to-s3-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-tim-kinesis-firehose-delivery-to-s3-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_tim.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm_firehose_wydot_tim_errors" {
    actions_enabled           = true
    alarm_actions             = var.cloudwatch_sns_topics
    alarm_description         = "${var.environment}-dot-sdc-cvpep-wydot-tim-kinesis-firehose-errors"
    alarm_name                = "${var.environment}-dot-sdc-cvpep-wydot-tim-kinesis-firehose-errors"
    comparison_operator       = "LessThanThreshold"
    datapoints_to_alarm       = 1
    dimensions                = {
        "DeliveryStreamName" = aws_kinesis_firehose_delivery_stream.kinesis_firehose_wydot_tim.name
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
        Project = var.data_providers[2]["project"],
        Team = var.data_providers[2]["team"]
    }
    threshold                 = 1
    treat_missing_data        = "missing"
}
