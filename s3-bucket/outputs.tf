
output "name" {
  value       = aws_s3_bucket.this.id
  sensitive   = false
  description = "Name of the bucket"
}

output "arn" {
  value       = aws_s3_bucket.this.arn
  sensitive   = false
  description = "ARN of the bucket"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  sensitive   = false
  description = "The bucket region-specific domain name."
}
