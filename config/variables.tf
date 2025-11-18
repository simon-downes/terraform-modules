
variable "namespace" {
  description = "Namespace of resources. Must be lower-kebab-case. Will be prefixed to parameter and secret names"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "config" {
  description = <<-EOT
    Map of config entries. Each value can be either:
    - a plain string (equivalent to [value, "string"])
    - or [value, type, (optional) description] where type is one of: `string`, `secure-string`, `secret`
  EOT

  # we use "any" here so that callers can specify either a single value or a tuple of [value, type, description]
  type = any

  validation {
    condition = alltrue([
      for k, v in var.config : (

        # Option 1: plain string, e.g. foo = "My non-secret value"
        can(regex(".*", v))

        ||

        # Option 2: list form, e.g. ["value", "string", "Description"]
        (
          can(tolist(v)) &&
          length(tolist(v)) >= 2 &&
          length(tolist(v)) <= 3 &&

          # value must be convertible to string
          can(tostring(tolist(v)[0])) &&

          # type must be one of allowed values
          contains(["string", "secure-string", "secret"], v[1])
        )
      )
    ])

    error_message = <<-EOT
      Each config entry must be either:
        - a plain string, or
        - a list [value, type, (optional) description]
          where type is one of "string", "secure-string", or "secret".
    EOT
  }
}

variable "kms_key" {
  description = "ARN or ID of KMS key used to encrypt secrets"
  type        = string
  default     = ""
}

variable "secrets_policy" {
  description = "Resource policy to attach to secrets"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
