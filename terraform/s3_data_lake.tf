resource "aws_s3_bucket" "data_lake_bucket" {
    bucket = var.data_lake_bucket
    acl = "private"

    tags = merge({Name = var.data_lake_bucket}, local.global_tags)
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}