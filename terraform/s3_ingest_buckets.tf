resource "aws_s3_bucket" "data_provider_manual_ingest_bucket" {
    count = length(var.data_providers)
    bucket = var.data_providers[count.index]["ingest_bucket"]

    acl = "private"

    tags = merge({Name = var.data_providers[count.index]["name"],
                  Team = var.data_providers[count.index]["team"],
                  Project = var.data_providers[count.index]["project"]}, local.team_global_tags)

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}
