output "url" {
  description = "URL of the created queue"
  value       = aws_sqs_queue.this.id
}

output "arn" {
  description = "ARN of the created queue"
  value       = aws_sqs_queue.this.arn
}

output "name" {
  description = "Name of the created queue"
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "ARN of the created DLQ"
  value       = local.has_dlq ? aws_sqs_queue.dlq[0].arn : "null"
}
