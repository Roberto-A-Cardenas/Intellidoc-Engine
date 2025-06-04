resource "aws_s3_bucket" "this" {
  bucket = "${var.project}-docs-${random_string.suffix.result}"
  force_destroy = true

  tags = {
    Name = "${var.project}-s3"
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.this.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_textract" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowTextractReadAccess",
        Effect    = "Allow",
        Principal = {
          Service = "textract.amazonaws.com"
        },
        Action    = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ],
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
