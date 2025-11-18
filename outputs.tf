
output "arn" {
  description = "ARN of the created table"
  value       = aws_dynamodb_table.this.arn
}

output "name" {
  description = "Name of the created table"
  value       = aws_dynamodb_table.this.name
}

output "stream_arn" {
  description = "ARN of the created stream, if applicable"
  value       = aws_dynamodb_table.this.stream_arn
}

