resource "aws_security_group" "lambda_http_egress" {
  name = "${var.environment}-ingest-lambda-security-group"
  description = "Allow network access from a Lambda"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
