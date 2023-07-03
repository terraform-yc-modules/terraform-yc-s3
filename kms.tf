locals {
  sse_kms_master_key_name          = var.sse_kms_key_configuration.name_prefix != null ? "${var.sse_kms_key_configuration.name_prefix}-${random_string.unique_id.result}" : null
  storage_admin_service_account_id = try(yandex_iam_service_account.storage_admin[0].id, null)
}

resource "yandex_kms_symmetric_key" "this" {
  count               = try(var.server_side_encryption_configuration.enabled, tobool(false)) && try(var.server_side_encryption_configuration.kms_master_key_id == null ? tobool(true) : tobool(false), tobool(false)) ? 1 : 0
  name                = try(coalesce(var.sse_kms_key_configuration.name, local.sse_kms_master_key_name), null)
  description         = var.sse_kms_key_configuration.description
  folder_id           = local.folder_id
  default_algorithm   = var.sse_kms_key_configuration.default_algorithm
  rotation_period     = var.sse_kms_key_configuration.rotation_period
  deletion_protection = var.sse_kms_key_configuration.deletion_protection
}

resource "yandex_resourcemanager_folder_iam_member" "kms_storage_admin_sa" {
  count     = try(var.server_side_encryption_configuration.enabled, tobool(false)) && try(var.storage_admin_service_account.existing_account_id == null ? tobool(true) : tobool(false), tobool(false)) ? 1 : 0
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${local.storage_admin_service_account_id}"
}

resource "yandex_resourcemanager_folder_iam_member" "kms_all_access_users" {
  for_each  = try(var.server_side_encryption_configuration.enabled, tobool(false)) ? toset(var.all_access_users) : []
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = each.value
}

resource "yandex_resourcemanager_folder_iam_member" "kms_read_only_sa" {
  for_each  = try(var.server_side_encryption_configuration.enabled, tobool(false)) ? toset(var.read_only_sa) : []
  folder_id = local.folder_id
  role      = "kms.keys.decrypter"
  member    = each.value
}

resource "yandex_resourcemanager_folder_iam_member" "kms_write_only_sa" {
  for_each  = try(var.server_side_encryption_configuration.enabled, tobool(false)) ? toset(var.write_only_sa) : []
  folder_id = local.folder_id
  role      = "kms.keys.encrypter"
  member    = each.value
}
