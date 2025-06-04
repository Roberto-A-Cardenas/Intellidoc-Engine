output "lambda_function_name" {
  value = aws_lambda_function.ocr_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.ocr_processor.arn
}

output "lambda_execution_role" {
  value = aws_iam_role.lambda_exec.name
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.ocr_processor.invoke_arn
}