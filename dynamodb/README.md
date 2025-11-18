# DynamoDB Table Module

**Supports:**
- GSIs
- Streams
- TTL
- Resource Policy
- Point-in-Time Recovery
- Customer-managed KMS key

**Doesn't Support:**
- Provisioned Capacity
- LSIs
- Standard-IA Storage Class

## Useful Reading
- [DynamoDB Core Concepts](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html)
- [TTL](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
- [GSI vs LSI](https://aws.amazon.com/awstv/watch/211cb42d6eb/)
- [Best Practices for Using Sort Keys](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-sort-keys.html)
- [On-Demand Capacity Mode](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/on-demand-capacity-mode.html)

## Complete Example

```terraform


module "my_table" {
  source  = "github.com/simon-downes/terraform-modules//dynamodb?ref=dynamodb/1.0.0"

  # required: namespace of the table - will be prefixed to name
  namespace = "my-app-prd"

  # required: name of the table - will be prefixed with namespace
  name = "my-table"

  # required: partition (hash) key: type must be string, number or binary
  partition_key = {
    name = "id"
    type = "string"
  }

  # optional: sort (range) key
  sort_key = {
    name = "created_at"
    type = "string"
  }

  # optional: enable & set the TTL attribute
  time_to_live = {
    enabled        = true
    attribute_name = "expiresAt"
  }

  # list of objects defining global secondary indexes to create
  indexes = [
    {
      # required
      name = "foo-index"

      # required
      partition_key = {
        name = "user_id"
        type = "string"
      }

      optional
      sort_key = {
        name = "created_at"
        type = "string"
      }

      required: must be one of ALL, INCLUDE, KEYS_ONLY
      projection_type = "INCLUDE"

      optional: list of attributes named to include when projection_type is INCLUDE
      include_attributes = ["foo", "bar"]
    },
  ]

  # optional: whether or not to enable deletion protection, defaults to true
  # if enabled must be disabled before resource can be destroyed
  deletion_protection = false

  # number of days for point-in-time recovery, set to 0 (default) to disable
  recovery_days = 0

  # optional: stream type to create, set to "" (default) for no streaming
  # must be one of KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES
  stream_type = ""

  # optional: arn of a customer-managed kms key to use for encryption
  kms_key = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  # optional: resource policy
  attach_resource_policy = true
  resource_policy        = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "AllowOrganisationAccess",
        Effect: "Allow",
        Principal: {
          AWS: "*"
        },
        Action: [
          "dynamodb:Query",
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
| <a name="input_name"></a> [name](#input_name) | Name of the table. Must be lower-kebab-case. Will be prefixed with `namespace` | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input_namespace) | Namespace of the table. Must be lower-kebab-case. Will be prefixed to `name` | `string` | n/a | yes |
| <a name="input_partition_key"></a> [partition_key](#input_partition_key) | Name and type of the attribute used as the partition key | <pre>object({<br/>    name = string<br/>    type = string<br/>  })</pre> | n/a | yes |
| <a name="input_attach_resource_policy"></a> [attach_resource_policy](#input_attach_resource_policy) | Whether or not to attach the resource policy specified in `resource_policy` | `bool` | `false` | no |
| <a name="input_deletion_protection"></a> [deletion_protection](#input_deletion_protection) | Use this override to UNSET delete protection to allow deliberate destruction | `bool` | `true` | no |
| <a name="input_indexes"></a> [indexes](#input_indexes) | List of objects defining GSIs for the table.<br/>Object structure:<br/>  - name<br/>  - partition_key: map with name and type of partition key attribute<br/>  - sort_key: map with name and type of sort key attribute<br/>  - projection_type: must be one of: ALL, INCLUDE, KEYS_ONLY<br/>  - included_attributes: list of attribute names to include in the projection - only valid when projection_type is INCLUDE | <pre>list(object({<br/>    name = string<br/>    partition_key = object({<br/>      name = string<br/>      type = string<br/>    })<br/>    sort_key = optional(object({<br/>      name = optional(string, "")<br/>      type = optional(string, "")<br/>    }), {})<br/>    projection_type     = string<br/>    included_attributes = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_key"></a> [kms_key](#input_kms_key) | ARN of the customer-managed KMS key to use for encryption. If not specified the AWS-managed key will be used.<br/>See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#server_side_encryption<br/>and https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html for more details. | `string` | `""` | no |
| <a name="input_recovery_days"></a> [recovery_days](#input_recovery_days) | Number of days of point-in-time recovery | `number` | `0` | no |
| <a name="input_resource_policy"></a> [resource_policy](#input_resource_policy) | Resource policy for the table. If this is specified then `attach_resource_policy` MUST be set to `true` | `string` | `""` | no |
| <a name="input_sort_key"></a> [sort_key](#input_sort_key) | Name and type of the attribute used as the sort key | <pre>object({<br/>    name = optional(string, "")<br/>    type = optional(string, "")<br/>  })</pre> | `{}` | no |
| <a name="input_stream_type"></a> [stream_type](#input_stream_type) | Turn on streaming with the specified view type: `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES` | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_ttl"></a> [ttl](#input_ttl) | TTL attribute configuration.<br/>It can take up to one hour for the change to fully process. Any additional UpdateTimeToLive calls for the same table during this<br/>one hour duration will result in a [ValidationException ERROR](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html).<br/>**NOTE:** _DISABLING_ the ttl attribute must be done by:<br/>-  changing the value of the `enabled` to `false`, leaving the `attribute_name` key unchanged<br/>- apply the changes<br/>- come back later in the future to remove the whole `ttl` variable | <pre>object({<br/>    enabled        = bool<br/>    attribute_name = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | ARN of the created table |
| <a name="output_name"></a> [name](#output_name) | Name of the created table |
| <a name="output_stream_arn"></a> [stream_arn](#output_stream_arn) | ARN of the created stream, if applicable |
<!-- END_TF_DOCS -->
