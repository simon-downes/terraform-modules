
resource "aws_s3_bucket" "this" {
  bucket = "${var.namespace}-${var.name}"

  force_destroy       = var.force_destroy
  object_lock_enabled = false

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.block_public_access ? 1 : 0

  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  count = var.attach_bucket_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = replace(var.bucket_policy, "{--BUCKET-ARN--}", aws_s3_bucket.this.arn)
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
