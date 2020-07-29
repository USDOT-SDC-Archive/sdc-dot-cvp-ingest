resource "aws_security_group" "lambda_http_egress" {
  name = "${var.environment}-manual-ingest-lambda-security-group"
  description = "Allow network access from a Lambda"
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    to_port = 9999
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}