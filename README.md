# Simon's Terraform Modules

A collection of _opinionated_ Terraform modules designed for simplicity.

## Naming Conventions

Most resource names are lower-kebab-case - this is enforced by variable validation.

**Noteable Exceptions:**
- Parameters and Secrets created via the [config](config/) module - the keys are used as-is

### Namespaces

Every resource has a namespace. The exact construction is left to implementers but my personal goto is:
`{service}-{environment}-{region}`:
- `service` - the name of the service/application/component the resources belong to
- `environment` - a short (3 or 4 character) key representing the environment the resource is deployed to
- `region` - for resources created outside of the "home region" I often include a short region code

Having a well structured namespace as part of a resource name greatly helps with removing ambiguity;
particularly in the AWS console and in requests or screenshots that have minimal context
(no account number, region, environment, etc).

Just having "`foo` is broken" doens't help much when you have many `foo`s across various accounts/environments/regions.
