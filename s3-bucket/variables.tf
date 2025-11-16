
variable "namespace" {
  description = "Namespace of the bucket. Must be lower-kebab-case. Will be prefixed to `name`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "name" {
  description = "Name of the bucket/ Must be lower-kebab-case. Will be prefixed with `namespace`"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "kms_key" {
  description = "ARN of customer-managed KMS key to use for encryption"
  type        = string
  default     = ""
}

variable "attach_bucket_policy" {
  description = "Whether or not to attach the policy specified in `bucket_policy`"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "Bucket policy for access control. If this is specified then `attach_bucket_policy` MUST be set to `true`"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "Whether or not to enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Whether or not to block all public access"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether to delete all objects in the bucket when it's destroyed"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
