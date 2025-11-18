
variable "namespace" {
  description = "Namespace of the table. Must be lower-kebab-case. Will be prefixed to `name`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "Namespaces must be lower-kebab-case"
  }
}

variable "name" {
  description = "Name of the table. Must be lower-kebab-case. Will be prefixed with `namespace`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "partition_key" {
  description = "Name and type of the attribute used as the partition key"
  type = object({
    name = string
    type = string
  })

  validation {
    condition     = var.partition_key.name != ""
    error_message = "Partition key attribute name is required"
  }

  validation {
    condition     = can(local.type_map[var.partition_key.type])
    error_message = "Allowed values for type are only one of: ${join(", ", keys(local.type_map))}."
  }
}

variable "sort_key" {
  description = "Name and type of the attribute used as the sort key"
  type = object({
    name = optional(string, "")
    type = optional(string, "")
  })

  default = {}

  validation {
    condition     = var.sort_key.type == "" || can(local.type_map[var.sort_key.type])
    error_message = "Allowed values for type are only one of: ${join(", ", keys(local.type_map))}."
  }
}

/*

*/
variable "ttl" {
  description = <<-EOT
    TTL attribute configuration.
    It can take up to one hour for the change to fully process. Any additional UpdateTimeToLive calls for the same table during this
    one hour duration will result in a [ValidationException ERROR](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateTimeToLive.html).
    **NOTE:** _DISABLING_ the ttl attribute must be done by:
    -  changing the value of the `enabled` to `false`, leaving the `attribute_name` key unchanged
    - apply the changes
    - come back later in the future to remove the whole `ttl` variable
  EOT
  type = object({
    enabled        = bool
    attribute_name = optional(string, "")
  })
  default = {
    enabled = false
  }
}

variable "indexes" {
  description = <<-EOT
    List of objects defining GSIs for the table.
    Object structure:
      - name
      - partition_key: map with name and type of partition key attribute
      - sort_key: map with name and type of sort key attribute
      - projection_type: must be one of: ALL, INCLUDE, KEYS_ONLY
      - included_attributes: list of attribute names to include in the projection - only valid when projection_type is INCLUDE
  EOT
  type = list(object({
    name = string
    partition_key = object({
      name = string
      type = string
    })
    sort_key = optional(object({
      name = optional(string, "")
      type = optional(string, "")
    }), {})
    projection_type     = string
    included_attributes = optional(list(string), [])
  }))

  default = []

  validation {
    condition = alltrue([
      for idx in var.indexes : (

        # partition_key.type must be valid
        can(local.type_map[idx.partition_key.type])

        &&

        # sort_key: either not used / empty, or fully valid
        (
          idx.sort_key == null ?
          true :
          (
            # case 1: explicitly "no sort key"
            (idx.sort_key.name == "" && idx.sort_key.type == "")
            ||
            # case 2: sort key present: name non-empty and type valid
            (idx.sort_key.name != "" && can(local.type_map[idx.sort_key.type]))
          )
        )

        &&

        # projection_type must be ALL, INCLUDE, or KEYS_ONLY
        contains(["ALL", "INCLUDE", "KEYS_ONLY"], idx.projection_type)

        &&

        # included_attributes must be non-empty if projection_type == INCLUDE
        (
          idx.projection_type != "INCLUDE" || length(idx.included_attributes) > 0
        )
      )
    ])

    error_message = <<-EOT
      Each index must satisfy:
        - partition_key.type must be one of: ${join(", ", keys(local.type_map))}.
        - sort_key must either be omitted/empty, or have a non-empty name and type in: ${join(", ", keys(local.type_map))}.
        - projection_type must be one of: `ALL`, `INCLUDE`, `KEYS_ONLY`
        - included_attributes must be non-empty when projection_type is `INCLUDE`
    EOT
  }

}

# See README for why this variable exists
variable "attach_resource_policy" {
  description = "Whether or not to attach the resource policy specified in `resource_policy`"
  type        = bool
  default     = false
}

variable "resource_policy" {
  description = "Resource policy for the table. If this is specified then `attach_resource_policy` MUST be set to `true`"
  type        = string
  default     = ""
}

variable "kms_key" {
  description = <<-EOT
    ARN of the customer-managed KMS key to use for encryption. If not specified the AWS-managed key will be used.
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#server_side_encryption
    and https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html for more details.
  EOT
  type        = string
  default     = ""
}

variable "stream_type" {
  description = "Turn on streaming with the specified view type: `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES`"
  type        = string
  default     = ""
  validation {
    condition     = contains(["", "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_type)
    error_message = "Allowed values for stream_type are only one of KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

variable "deletion_protection" {
  description = "Use this override to UNSET delete protection to allow deliberate destruction"
  type        = bool
  default     = true
}

variable "recovery_days" {
  description = "Number of days of point-in-time recovery"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
