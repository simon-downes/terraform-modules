
variable "namespace" {
  description = "(Required) Namespace of the bucket - will be prefixed to name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "name" {
  description = "(Required) Name of the bucket - will be prefixed with namespace"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Names must be lower-kebab-case"
  }
}

variable "kms_key" {
  description = "(Optional) ARN of customer-managed KMS key to use for encryption"
  type        = string
  default     = ""
}

variable "attach_bucket_policy" {
  description = "(Optional) Whether or not to attach the policy specified in the bucket_policy variable"
  type        = bool
  default     = false
}

variable "bucket_policy" {
  description = "(Optional) Bucket policy for access control"
  type        = string
  default     = ""
}

variable "enable_versioning" {
  description = "(Optional) Whether to enable versioning for the bucket"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "(Optional) Whether to block all public access or not"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "(Optional) Whether to delete all objects in the bucket on destroy"
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Tags to apply to resources"
  type        = map(string)
  default     = {}
}
