locals {
  sse_kms_master_key_name = var.sse_kms_key_configuration.name_prefix != null ? "${var.sse_kms_key_configuration.name_prefix}-${random_string.unique_id.result}" : "key_s3-${random_string.unique_id.result}"
}

resource "yandex_kms_symmetric_key" "this" {
  count               = var.server_side_encryption_configuration.enabled && var.server_side_encryption_configuration.kms_master_key_id == null ? 1 : 0
  name                = try(coalesce(var.sse_kms_key_configuration.name, local.sse_kms_master_key_name), null)
  description         = var.sse_kms_key_configuration.description
  folder_id           = local.folder_id
  default_algorithm   = var.sse_kms_key_configuration.default_algorithm
  rotation_period     = var.sse_kms_key_configuration.rotation_period
  deletion_protection = var.sse_kms_key_configuration.deletion_protection
}
