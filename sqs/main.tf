
locals {

  is_fifo = var.fifo != null
  has_dlq = var.dlq != null

  # FIFo queues MUST end with .fifo
  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-queue-message-identifiers.html
  suffix = local.is_fifo ? ".fifo" : ""

  queue_name     = "${var.namespace}-${var.name}${local.suffix}"
  dlq_queue_name = "${var.namespace}-${var.name}-dlq${local.suffix}"

}


resource "aws_sqs_queue" "this" {
  name                       = local.queue_name
  delay_seconds              = var.delay
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.retention_timeout

  fifo_queue                  = local.is_fifo
  content_based_deduplication = local.is_fifo ? var.fifo.content_based_deduplication : null
  deduplication_scope         = local.is_fifo ? var.fifo.deduplication_scope : null
  fifo_throughput_limit       = local.is_fifo ? var.fifo.throughput_limit : null

  tags = var.tags
}

resource "aws_sqs_queue_policy" "this" {
  count = var.attach_queue_policy ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = var.queue_policy
}

resource "aws_sqs_queue" "dlq" {
  count = local.has_dlq ? 1 : 0

  name                       = local.dlq_queue_name
  visibility_timeout_seconds = var.dlq.visibility_timeout == null ? var.visibility_timeout : var.dlq.visibility_timeout
  message_retention_seconds  = var.dlq.retention_timeout == null ? var.retention_timeout : var.dlq.retention_timeout

  fifo_queue                  = local.is_fifo
  content_based_deduplication = local.is_fifo ? var.fifo.content_based_deduplication : null
  deduplication_scope         = local.is_fifo ? var.fifo.deduplication_scope : null
  fifo_throughput_limit       = local.is_fifo ? var.fifo.throughput_limit : null

  tags = var.tags
}

# Redrive policies for dead-letter queues

resource "aws_sqs_queue_redrive_policy" "this-redrive-policy" {
  count = local.has_dlq ? 1 : 0

  queue_url = aws_sqs_queue.this.url

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.dlq.max_receive_count
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "this-redrive-allow-policy" {
  count = local.has_dlq ? 1 : 0

  queue_url = aws_sqs_queue.dlq[0].url

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}
