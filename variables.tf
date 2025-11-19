

variable "namespace" {
  description = "Namespace of the queue. Must be lower-kebab-case. Will be prefixed to `name`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "Namespaces must be lower-kebab-case"
  }
}

variable "name" {
  description = "Name of the queue. Must be lower-kebab-case. Will be prefixed with `namespace`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "attach_queue_policy" {
  description = "Whether or not to attach the policy specified in `queue_policy`"
  type        = bool
  default     = false
}

variable "queue_policy" {
  description = "Queue policy for access control. If this is specified then `attach_queue_policy` MUST be set to `true`"
  type        = string
  default     = ""
}

variable "visibility_timeout" {
  description = "Number of seconds after delivery to a consumer before message becomes visible to other consumers again - upper limit is 12 hours."
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout >= 0 && var.visibility_timeout <= 43200
    error_message = "The visibility_timeout value must be in the range [0..43200]."
  }
}

variable "retention_timeout" {
  description = "Number of seconds a message can stay in the queue before being automatically deleted - upper limit is 14 days"
  type        = number
  default     = 604800 # 7 days

  validation {
    condition     = var.retention_timeout >= 60 && var.retention_timeout <= 1209600
    error_message = "The retention_timeout value must be in the range [60..1209600]."
  }
}

variable "delay" {
  description = "Number of seconds that the delivery of all messages in the queue will be delayed - upper limit is 15 minutes"
  type        = number
  default     = 0

  validation {
    condition     = var.delay >= 0 && var.delay <= 900
    error_message = "The delay value must be in the range [0..900]."
  }
}

variable "max_message_size" {
  description = "Number of bytes a message can contain before SQS rejects it - upper limit is 1 MiB"
  type        = number
  default     = 1048576

  validation {
    condition     = var.max_message_size > 0 && var.max_message_size <= 1048576
    error_message = "The max_message_size value must be in the range [1..1048576]."
  }
}

variable "fifo" {
  description = "Create a [FIFO queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-fifo-queues.html) instead of a standard queue"
  type = object({
    content_based_deduplication = bool
    deduplication_scope         = optional(string, "queue")
    throughput_limit            = optional(string, "perQueue")
  })
  default = null

  validation {
    condition     = var.fifo == null || contains(["messageGroup", "queue"], var.fifo.deduplication_scope)
    error_message = "The deduplication_scope value must be either 'messageGroup' or 'queue'."
  }

  validation {
    condition     = var.fifo == null || contains(["perQueue", "perMessageGroupId"], var.fifo.throughput_limit)
    error_message = "The throughput_limit value must be either 'perMessageGroupId' or 'perQueue'."
  }
}

variable "dlq" {
  description = <<-EOT
    Also create a dead-letter queue. Timeouts will match the main queue if not specified.
    `max_receive_count` is the number of times a consumer can receive a message from a source queue before it is moved to a dead-letter queue.
    For example, if `max_receive_count` is set to a low value such as 1, one failure to receive a message would cause the message to move to the dead-letter queue.<br>
    To ensure that your system is resilient against errors, set `max_receive_count` high enough to allow for sufficient retries.
  EOT
  type = object({
    max_receive_count  = optional(number)
    visibility_timeout = optional(number)
    retention_timeout  = optional(number)
  })
  default = null

  validation {
    condition     = var.dlq == null || (var.dlq.visibility_timeout >= 0 && var.dlq.visibility_timeout <= 43200)
    error_message = "The DLQ visibility_timeout value must be in the range [0..43200]."
  }

  validation {
    condition     = var.dlq == null || (var.dlq.retention_timeout >= 60 && var.dlq.retention_timeout <= 1209600)
    error_message = "The DLQ retention_timeout value must be in the range [60..1209600]."
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
