// This policy is to be dropped into raw submissions bucket policy (waze-pipeline)
// allow the ARN of the role attached to lambda:
// arn:aws:iam::911061262852:role/dev-firehose-replicator-role
var policy = {
  "Sid": "Stmt3",
  "Action": [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:PutObjectVersionAcl"
  ],
  "Effect": "Allow",
  "Resource": "arn:aws:s3:::dev-dot-sdc-raw-submissions-505135622787-us-east-1/*",
  "Principal": {
    "AWS": [
      "arn:aws:iam::911061262852:role/dev-firehose-replicator-role"
    ]
  }
}
// s3:GetBucketAcl	s3:GetObjectAcl and s3:GetObjectVersionAcl