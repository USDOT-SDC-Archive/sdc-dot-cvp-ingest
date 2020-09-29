resource "aws_s3_bucket" "data_provider_manual_ingest_bucket" {
    count = length(var.data_providers)
    bucket = var.data_providers[count.index]["ingest_bucket"]
    acl = "private"

    tags = merge({Name = var.data_providers[count.index]["ingest_bucket"],
                  Team = var.data_providers[count.index]["team"],
                  Project = var.data_providers[count.index]["project"]}, local.team_global_tags)

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    # Allow mirror account lambda roles to put objects into this bucket and make us owner
    # Must be kept in sync with aws_iam_role.IngestLambdaRole
    policy = templatefile("s3_ingest_bucket_policy.json", {
        ingest_bucket_arn = "arn:aws:s3:::${var.data_providers[count.index]["ingest_bucket"]}"
        mirror_role_arn = "arn:aws:iam::${var.mirror_account_number}:role/${var.environment}-dot-sdc-${var.data_providers[count.index]["name"]}-manual-ingest"
    })
}
