# S3 Bucket Module

This is a low-level module for creating S3 buckets with simple requirements, it specifically only handles:
- bucket creation
- encryption with optional KMS key
- bucket policy
- public access blocking
- versioning

## Bucket Policies

Bucket policies must contain a `Resource` key that cannot be a wildcard, which means that the caller must
deterministically create the policy with the correct bucket ARN, but this has the potential for consistency issues
if the bucket name isn't in a variable.

In order to mitigate and simplify this, the special token `{--BUCKET-ARN--}` can be used as a placeholder
in the policy document and the module will replace it with the actual bucket ARN.

## Complete Example

```terraform
module "s3_bucket" {
  source  = "github.com/simon-downes/terraform-modules//s3-bucket?ref=s3-bucket/1.0.0"

  # required: namespace of the bucket - will be prefixed to name
  namespace = "my-app-prd"

  # required: name of the bucket - will be prefixed with namespace
  name = "my-bucket"

  # optional: arn of a customer-managed kms key to use for encryption
  kms_key = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"

  # optional: whether to enable versioning of objects in the bucket
  enable_versioning = false

  # optional: whether to block all public access
  block_public_access = true

  # optional: whether to delete all objects in the bucket on destroy
  force_destroy = false

  # optional: bucket policy
  attach_bucket_policy = true
  bucket_policy        = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Sid: "AllowOrganisationAccess",
        Effect: "Allow",
        Principal: {
          AWS: "*"
        },
        Action: [
          "s3:GetObject",
        ],
        Resource: [

          # the bucket itself
          "{--BUCKET-ARN--}",

          # objects within the bucket
          "{--BUCKET-ARN--}/*"

        ],
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
| <a name="input_name"></a> [name](#input_name) | Name of the bucket/ Must be lower-kebab-case. Will be prefixed with `namespace` | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input_namespace) | Namespace of the bucket. Must be lower-kebab-case. Will be prefixed to `name` | `string` | n/a | yes |
| <a name="input_attach_bucket_policy"></a> [attach_bucket_policy](#input_attach_bucket_policy) | Whether or not to attach the policy specified in `bucket_policy` | `bool` | `false` | no |
| <a name="input_block_public_access"></a> [block_public_access](#input_block_public_access) | Whether or not to block all public access | `bool` | `true` | no |
| <a name="input_bucket_policy"></a> [bucket_policy](#input_bucket_policy) | Bucket policy for access control. If this is specified then `attach_bucket_policy` MUST be set to `true` | `string` | `""` | no |
| <a name="input_enable_versioning"></a> [enable_versioning](#input_enable_versioning) | Whether or not to enable versioning for the bucket | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force_destroy](#input_force_destroy) | Whether to delete all objects in the bucket when it's destroyed | `bool` | `false` | no |
| <a name="input_kms_key"></a> [kms_key](#input_kms_key) | ARN of customer-managed KMS key to use for encryption | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output_arn) | ARN of the bucket |
| <a name="output_name"></a> [name](#output_name) | Name of the bucket |
| <a name="output_regional_domain_name"></a> [regional_domain_name](#output_regional_domain_name) | The bucket region-specific domain name. |
<!-- END_TF_DOCS -->
