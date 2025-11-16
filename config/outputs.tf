
output "resources" {
  description = "Names and ARNs of created parameters and secrets"
  value = merge(
    { for k, v in local.strings : k => {
      name = aws_ssm_parameter.strings[k].name
      arn  = aws_ssm_parameter.strings[k].arn
    } },
    { for k, v in local.secure_strings : k => {
      name = aws_ssm_parameter.secure_strings[k].name
      arn  = aws_ssm_parameter.secure_strings[k].arn
    } },
    { for k, v in local.manual_secure_strings : k => {
      name = aws_ssm_parameter.manual_secure_strings[k].name
      arn  = aws_ssm_parameter.manual_secure_strings[k].arn
    } },
    { for k, v in local.secrets : k => {
      name = aws_secretsmanager_secret.secrets[k].name
      arn  = aws_secretsmanager_secret.secrets[k].arn
    } },
  )
}
