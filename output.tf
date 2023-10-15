# Output value definitions

############################################### [S3|Lambda] Outputs

output "function_login_url" {
  description = "URL of the Login Lambda function."

  value = aws_lambda_function_url.login_url.function_url
}

output "function_login_invoke_arn" {
  description = "Arn of the Login Lambda function."

  value = aws_lambda_function.login_demo.invoke_arn
}

output "function_login_name" {
  description = "Name of the Login Lambda function."

  value = aws_lambda_function.login_demo.function_name
}


###############################################
