
locals {

  # map nice names for types to the actual values needed for the resource
  type_map = {
    "string" = "S",
    "number" = "N",
    "binary" = "B"
  }

  attributes = {
    for k, v in merge(
      {
        "${var.partition_key.name}" = var.partition_key.type
        "${var.sort_key.name}"      = var.sort_key.type
      },
      merge(
        [
          for gsi in var.indexes : {
            "${gsi.partition_key.name}" = gsi.partition_key.type
            "${gsi.sort_key.name}"      = gsi.sort_key.type
          }
        ]...
      )
    ) : k => v if k != ""
  }

}

resource "aws_dynamodb_table" "this" {

  name = "${var.namespace}-${var.name}"

  # hash and range keys are the old names hence the difference
  hash_key  = var.partition_key.name
  range_key = var.sort_key.name == "" ? null : var.sort_key.name

  billing_mode = "PAY_PER_REQUEST"

  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = attribute.key
      type = local.type_map[attribute.value]
    }
  }

  dynamic "global_secondary_index" {
    for_each = toset(var.indexes)
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.partition_key.name
      range_key          = global_secondary_index.value.sort_key.name
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.included_attributes
    }
  }

  // see the docblock in variables.tf for why we have an explicit map for enabled and attribute name
  ttl {
    enabled        = var.ttl.enabled
    attribute_name = var.ttl.attribute_name
  }

  stream_enabled   = var.stream_type != ""
  stream_view_type = var.stream_type

  deletion_protection_enabled = var.deletion_protection

  point_in_time_recovery {
    enabled                 = var.recovery_days > 0
    recovery_period_in_days = var.recovery_days > 0 ? var.recovery_days : 1
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key
  }

  tags = var.tags
}

resource "aws_dynamodb_resource_policy" "this" {
  count = var.attach_resource_policy ? 1 : 0

  resource_arn = aws_dynamodb_table.this.arn
  policy       = var.resource_policy
}
