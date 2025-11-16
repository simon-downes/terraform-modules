
locals {

  strings = {
    for k, v in var.config : k => {
      name        = "/${var.namespace}/${k}"
      value       = tostring(try(v[0], v))
      description = tostring(try(v[2], ""))
    } if try(v[1], "string") == "string"
  }

  secure_strings = {
    for k, v in var.config : k => {
      name        = "/${var.namespace}/${k}"
      value       = tostring(try(v[0], v))
      description = tostring(try(v[2], ""))
    } if try(v[1], "") == "secure-string" && v[0] != null
  }

  manual_secure_strings = {
    for k, v in var.config : k => {
      name        = "/${var.namespace}/${k}"
      value       = "TO_BE_SET_MANUALLY"
      description = tostring(try(v[2], ""))
    } if try(v[1], "") == "secure-string" && v[0] == null
  }

  secrets = {
    for k, v in var.config : k => {
      name        = "${var.namespace}/${k}"
      value       = tostring(try(v[0], v))
      description = tostring(try(v[2], ""))
    } if try(v[1], "") == "secret"
  }

}

resource "aws_ssm_parameter" "strings" {
  for_each = local.strings

  type           = "String"
  name           = each.value.name
  description    = each.value.description
  insecure_value = each.value.value

  tags = var.tags
}

resource "aws_ssm_parameter" "secure_strings" {
  for_each = local.secure_strings

  type        = "SecureString"
  name        = each.value.name
  description = each.value.description
  value       = each.value.value

  tags = var.tags

}

resource "aws_ssm_parameter" "manual_secure_strings" {
  for_each = local.manual_secure_strings

  type        = "SecureString"
  name        = each.value.name
  description = each.value.description
  value       = each.value.value

  tags = var.tags

  # these values will be set manually so we should ignore future changes to them
  lifecycle {
    ignore_changes = [
      value
    ]
  }

}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secrets

  name        = each.value.name
  description = each.value.description
  kms_key_id  = var.kms_key_id
  policy      = var.secrets_policy

  # set the recovery window to 0 so that we can immediately recreate a secret with the same name
  # if not 0 then trying to apply a plan that recreates the resource will fail
  recovery_window_in_days = 0

  tags = var.tags
}

# create a new secret version for each secret
resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = local.secrets

  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = coalesce(each.value.value, "TO_BE_SET_MANUALLY")
}
