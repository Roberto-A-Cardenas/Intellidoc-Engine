variable "project" {
  type        = string
  description = "Project name prefix"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to Lambda ZIP file"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for Lambda VPC config"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for Lambda"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket Lambda will access"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the Lambda to use"
}
