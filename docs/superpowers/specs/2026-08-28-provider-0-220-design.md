# Provider 0.220 Compatibility Design

## Goal

Update the S3 module for the current Yandex provider line while keeping existing
module inputs compatible and avoiding new Terraform tests in this change.

## Scope

- Keep the existing `acl`, `grant`, and `policy` module inputs.
- Replace deprecated inline bucket `grant` and `policy` arguments with the
  provider's dedicated resources.
- Keep `acl` on `yandex_storage_bucket`: the provider still supports it and a
  safe migration of a predefined ACL to grant resources is not one-to-one.
- Add optional inputs for `disabled_statickey_auth` and current lifecycle-rule
  capabilities: `filter`, `newer_noncurrent_versions`, and
  `INTELLIGENT_TIERING` validation.
- Narrow the Yandex provider constraint to the tested 0.220-compatible range.
- Update examples and generated module documentation.

## Compatibility and State

Existing callers keep the same input shapes. The `policy` and `grant` values
move internally from `yandex_storage_bucket.this` to dedicated resources. This
changes Terraform resource addresses, so consumers with existing state must
review the upgrade plan before applying; the module will document that update
plans must not recreate a bucket.

The update does not change defaults, enable static-key blocking by default, or
alter existing lifecycle rules.

## Implementation

`main.tf` will remove deprecated inline grant/policy handling and introduce one
`yandex_storage_bucket_grant` resource containing the configured grant blocks.
The provider does not support multiple grant resources for one bucket. `policy.tf`
will create `yandex_storage_bucket_policy` when the assembled IAM policy document
is enabled. `variables.tf` will extend only the affected object types and add a
nullable `disabled_statickey_auth` input.

The documentation and examples will demonstrate a lifecycle filter and
`INTELLIGENT_TIERING`, and will explain the policy/grant state migration risk.

## Verification

Run `terraform fmt -check -recursive`, `terraform init -backend=false -upgrade`,
and `terraform validate` with provider 0.220. Terraform tests are explicitly
out of scope for this request.
