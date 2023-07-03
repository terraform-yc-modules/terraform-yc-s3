data "yandex_client_config" "client" {}

locals {
  folder_id = coalesce(var.folder_id, data.yandex_client_config.client.folder_id)

  routing_rules_dict = {
    condition                       = "Condition"
    redirect                        = "Redirect"
    key_prefix_equals               = "KeyPrefixEquals"
    http_error_code_returned_equals = "HttpErrorCodeReturnedEquals"
    protocol                        = "Protocol"
    host_name                       = "HostName"
    replace_key_prefix_with         = "ReplaceKeyPrefixWith"
    replace_key_with                = "ReplaceKeyWith"
    http_redirect_code              = "HttpRedirectCode"
  }

  routing_rules = try(var.website.routing_rules != null ? jsonencode([
    for rule in var.website.routing_rules : {
      for key, value in rule : lookup(local.routing_rules_dict, key, null) => {
        for k, v in value : lookup(local.routing_rules_dict, k, null) => v if v != null
      } if value != null && value != {}
    }
  ]) : null, null)
}

resource "yandex_storage_bucket" "this" {
  bucket        = var.bucket
  bucket_prefix = var.bucket_prefix

  access_key = try(yandex_iam_service_account_static_access_key.storage_admin[0].access_key, var.storage_admin_service_account.existing_account_access_key, null)
  secret_key = try(yandex_iam_service_account_static_access_key.storage_admin[0].secret_key, var.storage_admin_service_account.existing_account_secret_key, null)

  force_destroy = var.force_destroy
  acl           = var.acl

  dynamic "grant" {
    for_each = var.grant
    content {
      id          = grant.value.id
      type        = grant.value.type
      uri         = grant.value.uri
      permissions = grant.value.permissions
    }
  }

  policy = try(data.aws_iam_policy_document.this[0].json, null)

  dynamic "cors_rule" {
    for_each = var.cors_rule
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  dynamic "website" {
    for_each = var.website != null ? [true] : []
    content {
      index_document           = var.website.redirect_all_requests_to == null ? var.website.index_document : null
      error_document           = var.website.redirect_all_requests_to == null ? var.website.error_document : null
      routing_rules            = var.website.redirect_all_requests_to == null ? local.routing_rules : null
      redirect_all_requests_to = var.website.redirect_all_requests_to
    }
  }

  dynamic "versioning" {
    for_each = var.versioning != null ? [true] : []
    content {
      enabled = var.versioning.enabled
    }
  }

  dynamic "object_lock_configuration" {
    for_each = var.object_lock_configuration != null ? [true] : []
    content {
      object_lock_enabled = var.object_lock_configuration.object_lock_enabled

      dynamic "rule" {
        for_each = var.object_lock_configuration.rule != null ? [var.object_lock_configuration.rule.default_retention] : []
        content {
          default_retention {
            mode  = rule.value.mode
            days  = rule.value.days
            years = rule.value.years
          }
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging != null ? [true] : []
    content {
      target_bucket = var.logging.target_bucket
      target_prefix = var.logging.target_prefix
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule
    content {
      enabled                                = lifecycle_rule.value.enabled
      id                                     = lifecycle_rule.value.id
      prefix                                 = lifecycle_rule.value.prefix
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      dynamic "expiration" {
        for_each = lifecycle_rule.value.expiration != null ? [true] : []
        content {
          date                         = lifecycle_rule.value.expiration.date
          days                         = lifecycle_rule.value.expiration.days
          expired_object_delete_marker = lifecycle_rule.value.expiration.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration != null ? [true] : []
        content {
          days = lifecycle_rule.value.noncurrent_version_expiration.days
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.transition != null ? [true] : []
        content {
          date          = lifecycle_rule.value.transition.date
          days          = lifecycle_rule.value.transition.days
          storage_class = lifecycle_rule.value.transition.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transition != null ? [true] : []
        content {
          days          = lifecycle_rule.value.noncurrent_version_transition.days
          storage_class = lifecycle_rule.value.noncurrent_version_transition.storage_class
        }
      }
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = try(var.server_side_encryption_configuration.enabled, tobool(false)) ? [true] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = var.server_side_encryption_configuration.kms_master_key_id == null ? yandex_kms_symmetric_key.this[0].id : var.server_side_encryption_configuration.kms_master_key_id
          sse_algorithm     = var.server_side_encryption_configuration.sse_algorithm
        }
      }
    }
  }

  tags = var.tags

  # Extended parameters of the bucket which use extended API and requires IAM token to be set in provider block.
  folder_id             = var.folder_id
  max_size              = var.max_size
  default_storage_class = var.default_storage_class

  dynamic "anonymous_access_flags" {
    for_each = var.anonymous_access_flags != null ? [true] : []
    content {
      list        = var.anonymous_access_flags.list
      read        = var.anonymous_access_flags.read
      config_read = var.anonymous_access_flags.config_read
    }
  }

  dynamic "https" {
    for_each = var.https != null ? [true] : []
    content {
      certificate_id = var.https.certificate_id
    }
  }

  lifecycle {
    precondition {
      condition     = ((var.versioning == null || var.versioning != null) && var.object_lock_configuration == null) || (tobool(try(var.versioning.enabled, null)) == tobool(true) && var.object_lock_configuration != null)
      error_message = "Bucket versioning must be enabled for object lock."
    }

    precondition {
      condition     = !(var.folder_id != null && try(data.yandex_iam_service_account.existing_account[0].folder_id != var.folder_id ? tobool(true) : tobool(false), tobool(false)))
      error_message = "The specified existing storage admin service account does not exist in the specified folder."
    }
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin
  ]
}
