resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_textract" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
}

resource "aws_iam_policy" "lambda_s3" {
  name        = "${var.project}-lambda-s3-policy"
  description = "Allow Lambda to access S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

data "archive_file" "lambda_output" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda/ocr_processor.py"
  output_path = "${path.module}/../../../lambda/lambda.zip"
}

resource "aws_lambda_function" "ocr_processor" {
  function_name    = "intellidoc-ocr"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "ocr_processor.lambda_handler"
  runtime          = "python3.11"
  filename         = data.archive_file.lambda_output.output_path
  source_code_hash = data.archive_file.lambda_output.output_base64sha256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      LOG_LEVEL   = "INFO"
    }
  }
}