# Configuration Module

This module provides a quick and concise method for creating secrets in Secrets Manager and parameters in Parameter Store.

## Complete Example

```terraform
module "config" {
  source  = "github.com/simon-downes/terraform-modules//config?ref=config/1.0.0"

  # optional: map of configuration settings
  config = {

    # simple (non-secure) string value with no description
    foo = "My non-secret value"

    # non-secure string value with description
    bar = ["My non-secret value", "string", "Description"]

    # secure string value with description
    baz = [random_password.foo.result, "secure-string", "Description"]

    # secret value with description
    abc = [random_password.foo.result, "secret", "Description"]

  }

  # optional: id or arn of a customer-managed kms key used to encrypt secrets
  kms_key_id = ""

  # optional: resource policy to apply to secrets
  secrets_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowOUPrincipalAccess"
    Statement = [
      {
        Sid      = "AllowSecretAccess",
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*"
        Principal = {
        }
        Condition = {
        },
      },
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
| <a name="input_config"></a> [config](#input_config) | Map of config entries. Each value can be either:<br/>- a plain string (equivalent to [value, "string"])<br/>- or [value, type, (optional) description] where type is one of: `string`, `secure-string`, `secret` | `any` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input_namespace) | Namespace of resources. Must be lower-kebab-case. Will be prefixed to parameter and secret names | `string` | n/a | yes |
| <a name="input_kms_key"></a> [kms_key](#input_kms_key) | ARN or ID of KMS key used to encrypt secrets | `string` | `""` | no |
| <a name="input_secrets_policy"></a> [secrets_policy](#input_secrets_policy) | Resource policy to attach to secrets | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resources"></a> [resources](#output_resources) | Names and ARNs of created parameters and secrets |
<!-- END_TF_DOCS -->
