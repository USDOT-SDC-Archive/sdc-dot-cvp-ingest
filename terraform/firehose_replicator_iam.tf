resource "aws_iam_role" "firehose_replicator_role" {
  name        = "${var.environment}-firehose-replicator-role"
  description = "Allows Lambda functions to push data to ECS s3 raw submissions."

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "put_ecs_oss_raw_submissions_policy" {
  name        = "${var.environment}-put-ecs-oss-raw-submissions"
  description = "Allows putting objects in the ECS raw submissions bucket."

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "St1",
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:PutObjectAcl",
              "s3:PutObjectVersionAcl"
            ],
            "Resource": "${local.mirror_raw_bucket_arn}/*"
        }
    ]
  }
  EOF
}

# Special policy for lambdas running in VPC. All lambdas will run in VPC.
resource "aws_iam_policy" "vpc_oss_access_policy" {
  name        = "${var.environment}-oss4its-ingest-lambda-vpc-policy"
  description = "Policy to allow lambdas to run in a VPC."

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAddresses",
                "ec2:DescribeClassicLinkInstances",
                "ec2:DescribeCustomerGateways",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeFlowLogs",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeMovingAddresses",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaceAttribute",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcClassicLink",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpnConnections",
                "ec2:DescribeVpnGateways",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
  }
  EOF
}

# Allow CW put/get
resource "aws_iam_policy" "lambda_oss_cloudwatch_policy" {
  name        = "${var.environment}-oss4its-ingest-lambda-cw-policy"
  description = "Permissions for CW metrics and logs."

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
  }
  EOF
}

# Attach policies to role
resource "aws_iam_role_policy_attachment" "put_ecs_oss_policy_to_replicator_role" {
  role       = aws_iam_role.firehose_replicator_role.name
  policy_arn = aws_iam_policy.put_ecs_oss_raw_submissions_policy.arn
} 
resource "aws_iam_role_policy_attachment" "cw_policy_oss_to_replicator_role" {
  role       = aws_iam_role.firehose_replicator_role.name
  policy_arn = aws_iam_policy.lambda_oss_cloudwatch_policy.arn
}
resource "aws_iam_role_policy_attachment" "vpc_policy_oss_to_replicator_role" {
  role       = aws_iam_role.firehose_replicator_role.name
  policy_arn = aws_iam_policy.vpc_oss_access_policy.arn
}
