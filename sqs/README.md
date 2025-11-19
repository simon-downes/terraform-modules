# SQS Queue Module

This module creates an SQS queue (either standard or FIFO) and optionally an associated dead-letter queue.

## Example

```terraform
module "sqs-queue" {
  source  = "github.com/simon-downes/terraform-modules//sqs?ref=sqs/1.0.0"

  # required: namespace of the queue - will be prefixed to name
  namespace = "my-app-prd"

  # required: name of the queue - will be prefixed with namespace
  name = "my-queue"

  # optional: number of seconds after delivery to a consumer before message becomes visible to other consumers again - upper limit is 12 hours.
  visibility_timeout = 30

  # optional: number of seconds a message can stay in the queue before being automatically deleted - upper limit is 14 days
  retention_timeout = 604800

  # optional: number of seconds that the delivery of all messages in the queue will be delayed - upper limit is 15 minutes
  delay = 0

  # optional: nNumber of bytes a message can contain before SQS rejects it - upper limit is 1 MiB
  max_message_size = 262144

  # optional: dlq configuration if required
  # visibility_timeout and retention_timeout are optional and default to the same as the queue if omitted
  dlq = {
    max_receive_count  = 5
    # visibility_timeout = 30
    # retention_timeout  = 604800
  }

  # optional: config for fifo queue if required
  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-fifo-queues.html
  fifo = {
    content_based_deduplication = true
    deduplication_scope         = "messageGroup"
    throughput_limit            = "perMessageGroupId"
  }

  # optional: queue policy
  attach_queue_policy = true
  queue_policy        = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "AllowOrganisationAccess",
        Effect: "Allow",
        Principal: {
          AWS: "*"
        },
        Action: [
          "sqs:SendMessage",
        ],
        Resource: "*",
        Condition: {
          StringEquals: {
            "aws:PrincipalOrgID": "o-abc123"
          }
        }
      }
    ]
  })

  # optional: additional tags to be attached to resources
  tags = {
    my_tag = "some value"
  }

}
```

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input_name) | Name of the queue. Must be lower-kebab-case. Will be prefixed with `namespace` | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input_namespace) | Namespace of the queue. Must be lower-kebab-case. Will be prefixed to `name` | `string` | n/a | yes |
| <a name="input_attach_queue_policy"></a> [attach_queue_policy](#input_attach_queue_policy) | Whether or not to attach the policy specified in `queue_policy` | `bool` | `false` | no |
| <a name="input_delay"></a> [delay](#input_delay) | Number of seconds that the delivery of all messages in the queue will be delayed - upper limit is 15 minutes | `number` | `0` | no |
| <a name="input_dlq"></a> [dlq](#input_dlq) | Also create a dead-letter queue. Timeouts will match the main queue if not specified.<br/>`max_receive_count` is the number of times a consumer can receive a message from a source queue before it is moved to a dead-letter queue.<br/>For example, if `max_receive_count` is set to a low value such as 1, one failure to receive a message would cause the message to move to the dead-letter queue.<br><br/>To ensure that your system is resilient against errors, set `max_receive_count` high enough to allow for sufficient retries. | <pre>object({<br/>    max_receive_count  = optional(number)<br/>    visibility_timeout = optional(number)<br/>    retention_timeout  = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_fifo"></a> [fifo](#input_fifo) | Create a [FIFO queue](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-fifo-queues.html) instead of a standard queue | <pre>object({<br/>    content_based_deduplication = bool<br/>    deduplication_scope         = optional(string, "queue")<br/>    throughput_limit            = optional(string, "perQueue")<br/>  })</pre> | `null` | no |
| <a name="input_max_message_size"></a> [max_message_size](#input_max_message_size) | Number of bytes a message can contain before SQS rejects it - upper limit is 1 MiB | `number` | `1048576` | no |
| <a name="input_queue_policy"></a> [queue_policy](#input_queue_policy) | Queue policy for access control. If this is specified then `attach_queue_policy` MUST be set to `true` | `string` | `""` | no |
| <a name="input_retention_timeout"></a> [retention_timeout](#input_retention_timeout) | Number of seconds a message can stay in the queue before being automatically deleted - upper limit is 14 days | `number` | `604800` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_visibility_timeout"></a> [visibility_timeout](#input_visibility_timeout) | Number of seconds after delivery to a consumer before message becomes visible to other consumers again - upper limit is 12 hours. | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | ARN of the created queue |
| <a name="output_dlq_arn"></a> [dlq_arn](#output_dlq_arn) | ARN of the created DLQ |
| <a name="output_name"></a> [name](#output_name) | Name of the created queue |
| <a name="output_url"></a> [url](#output_url) | URL of the created queue |
<!-- END_TF_DOCS -->