locals {
  storage_admin_service_account_name = try(var.storage_admin_service_account.name_prefix, null) != null ? "${var.storage_admin_service_account.name_prefix}-${random_string.unique_id.result}" : "storage-admin-${random_string.unique_id.result}"
}

data "yandex_iam_service_account" "existing_account" {
  count              = var.storage_admin_service_account.existing_account_id != null ? 1 : 0
  service_account_id = var.storage_admin_service_account.existing_account_id
}

resource "yandex_iam_service_account" "storage_admin" {
  count       = try(var.storage_admin_service_account.existing_account_id == null ? tobool(true) : tobool(false), tobool(false)) ? 1 : 0
  name        = coalesce(var.storage_admin_service_account.name, local.storage_admin_service_account_name)
  description = var.storage_admin_service_account.description
  folder_id   = local.folder_id
}

resource "yandex_iam_service_account_static_access_key" "storage_admin" {
  count              = try(var.storage_admin_service_account.existing_account_id == null ? tobool(true) : tobool(false), tobool(false)) ? 1 : 0
  service_account_id = yandex_iam_service_account.storage_admin[0].id
  description        = "Static access key for Object storage admin service account."
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  count     = try(var.storage_admin_service_account.existing_account_id == null ? tobool(true) : tobool(false), tobool(false)) ? 1 : 0
  folder_id = local.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_admin[0].id}"

  depends_on = [yandex_iam_service_account_static_access_key.storage_admin]
}

resource "yandex_resourcemanager_folder_iam_member" "all_access_users" {
  for_each  = var.all_access_users != null ? toset(var.all_access_users) : []
  folder_id = local.folder_id
  role      = "storage.admin"
  member    = each.value
}

resource "yandex_resourcemanager_folder_iam_member" "read_only_sa" {
  for_each  = var.read_only_sa != null ? toset(var.read_only_sa) : []
  folder_id = local.folder_id
  role      = "storage.viewer"
  member    = each.value
}

resource "yandex_resourcemanager_folder_iam_member" "write_only_sa" {
  for_each  = var.write_only_sa != null ? toset(var.write_only_sa) : []
  folder_id = local.folder_id
  role      = "storage.uploader"
  member    = each.value
}
