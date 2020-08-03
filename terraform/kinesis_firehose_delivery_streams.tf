resource "aws_iam_policy" "firehose_managed_policy" {
    description = "policy for the WYDOT kinesis role."
    name        = "test-dot-sdc-cvpep-wydot-kinesis-policy"
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
                "arn:aws:firehose:*:*:deliverystream/test-dot-sdc-cvpep-wydot-*"
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
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1/*",
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/*",
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1"
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
    description           = "Allows WYDOT Kinesis firehose to access the necessary services."
    force_detach_policies = false
    max_session_duration  = 3600
    name                  = "test-dot-sdc-cvpep-wydot-kinesis-role"
    path                  = "/"
    tags                  = {}
}

resource "aws_iam_role_policy_attachment" "firehose_attach_policy" {
    policy_arn = "arn:aws:iam::911061262852:policy/test-dot-sdc-cvpep-wydot-kinesis-policy"
    role       = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_iam_role_policy" "firehose_inline_policy_1" {
    name   = "oneClick_firehose_delivery_role_1530015053646"
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
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/*",
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
            "Resource": "arn:aws:lambda:us-east-1:911061262852:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/cv/wydot/alert/*"
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
                "arn:aws:logs:us-east-1:911061262852:log-group:/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-alert:log-stream:*"
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
            "Resource": "arn:aws:kinesis:us-east-1:911061262852:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:911061262852:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_iam_role_policy" "firehose_inline_policy_2" {
    name   = "oneClick_test-dot-sdc-cvpep-wydot-bsm_role_1532456714351"
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
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1/*",
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
            "Resource": "arn:aws:lambda:us-east-1:911061262852:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1/cv/wydot/BSM/*"
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
                "arn:aws:logs:us-east-1:911061262852:log-group:/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-bsm:log-stream:*"
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
            "Resource": "arn:aws:kinesis:us-east-1:911061262852:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:911061262852:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_iam_role_policy" "firehose_inline_policy_3" {
    name   = "oneClick_test-dot-sdc-cvpep-wydot-kinesis-role_1532456482681"
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
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/*",
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
            "Resource": "arn:aws:lambda:us-east-1:911061262852:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/cv/wydot/tim/*"
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
                "arn:aws:logs:us-east-1:911061262852:log-group:/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-tim:log-stream:*"
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
            "Resource": "arn:aws:kinesis:us-east-1:911061262852:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:911061262852:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_iam_role_policy" "firehose_inline_policy_4" {
    name   = "oneClick_test-dot-sdc-cvpep-wydot-kinesis-role_1532456535630"
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
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1/*",
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
            "Resource": "arn:aws:lambda:us-east-1:911061262852:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1/cv/wydot/TIM/*"
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
                "arn:aws:logs:us-east-1:911061262852:log-group:/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-tim:log-stream:*"
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
            "Resource": "arn:aws:kinesis:us-east-1:911061262852:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:911061262852:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_iam_role_policy" "firehose_inline_policy_5" {
    name   = "oneClick_usdot-its-cvpilot-wydot-tim-dev_role_1532456380365"
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
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1",
                "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/*",
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
            "Resource": "arn:aws:lambda:us-east-1:911061262852:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": [
                "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
            ],
            "Condition": {
                "StringEquals": {
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                },
                "StringLike": {
                    "kms:EncryptionContext:aws:s3:arn": "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1/cv/wydot/tim/*"
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
                "arn:aws:logs:us-east-1:911061262852:log-group:/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-tim:log-stream:*"
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
            "Resource": "arn:aws:kinesis:us-east-1:911061262852:stream/%FIREHOSE_STREAM_NAME%"
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
                    "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:911061262852:stream/%FIREHOSE_STREAM_NAME%"
                }
            }
        }
    ]
}
    EOF
    role   = "test-dot-sdc-cvpep-wydot-kinesis-role"
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_wydot_alert" {
    arn            = "arn:aws:firehose:us-east-1:911061262852:deliverystream/test-dot-sdc-cvpep-wydot-alert"
    destination    = "extended_s3"
    destination_id = "destinationId-000000000001"
    name           = "test-dot-sdc-cvpep-wydot-alert"
    tags           = {
        "Environment" = "Dev"
        "Project"     = "SDC-Platform"
        "Team"        = "sdc-platform"
    }
    version_id     = "2"

    extended_s3_configuration {
        bucket_arn         = "arn:aws:s3:::dev-dot-sdc-raw-submissions-911061262852-us-east-1"
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
        prefix             = "cv/wydot/alert/"
        role_arn           = "arn:aws:iam::911061262852:role/test-dot-sdc-cvpep-wydot-kinesis-role"
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-alert"
            log_stream_name = "S3Delivery"
        }

        processing_configuration {
            enabled = false
        }
    }

    server_side_encryption {
        enabled = false
    }
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_wydot_bsm" {
    arn            = "arn:aws:firehose:us-east-1:911061262852:deliverystream/test-dot-sdc-cvpep-wydot-bsm"
    destination    = "extended_s3"
    destination_id = "destinationId-000000000001"
    name           = "test-dot-sdc-cvpep-wydot-bsm"
    tags           = {
        "Environment" = "Dev"
        "Project"     = "SDC-Platform"
        "Team"        = "sdc-platform"
    }
    version_id     = "5"

    extended_s3_configuration {
        bucket_arn         = "arn:aws:s3:::test-dot-sdc-raw-submissions-911061262852-us-east-1"
        buffer_interval    = 60
        buffer_size        = 5
        compression_format = "GZIP"
        kms_key_arn        = "arn:aws:kms:us-east-1:911061262852:key/ad203c13-d93c-4981-b49c-8c0910c4f878"
        prefix             = "cv/wydot/BSM/"
        role_arn           = "arn:aws:iam::911061262852:role/test-dot-sdc-cvpep-wydot-kinesis-role"
        s3_backup_mode     = "Disabled"

        cloudwatch_logging_options {
            enabled         = true
            log_group_name  = "/aws/kinesisfirehose/test-dot-sdc-cvpep-wydot-bsm"
            log_stream_name = "S3Delivery"
        }

        processing_configuration {
            enabled = false
        }
    }

    server_side_encryption {
        enabled = false
    }
}
