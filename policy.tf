data "aws_iam_policy_document" "this" {
  count = var.policy.enabled || var.policy_console.enabled ? 1 : 0

  dynamic "statement" {
    for_each = var.policy.statements != null ? var.policy.statements : []
    content {
      sid     = statement.value.sid
      effect  = statement.value.effect
      actions = statement.value.actions
      resources = [
        for v in statement.value.resources :
        can(regex("arn:aws:s3:::.*", v)) ? v : format("arn:aws:s3:::%s", v)
      ]

      dynamic "principals" {
        for_each = statement.value.principal != null ? [statement.value.principal] : []
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principal != null ? [statement.value.not_principal] : []
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.condition != null ? [statement.value.condition] : []
        content {
          test     = condition.value.type
          variable = condition.value.key
          values   = condition.value.values
        }
      }
    }
  }

  dynamic "statement" {
    for_each = range(var.policy_console.enabled ? 1 : 0)
    content {
      sid     = var.policy_console.sid
      effect  = var.policy_console.effect
      actions = ["*"]
      resources = [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]

      condition {
        test     = "StringLike"
        variable = "aws:referer"
        values   = ["https://console.yandex.cloud/folders/*/storage/buckets/${var.bucket_name}*"]
      }

      dynamic "principals" {
        for_each = range(var.policy_console.principal == null && var.policy_console.not_principal == null ? 1 : 0)
        content {
          type        = "*"
          identifiers = ["*"]
        }
      }

      dynamic "principals" {
        for_each = range(var.policy_console.principal != null ? 1 : 0)
        content {
          type        = var.policy_console.principal.type
          identifiers = var.policy_console.principal.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = range(var.policy_console.not_principal != null ? 1 : 0)
        content {
          type        = var.policy_console.not_principal.type
          identifiers = var.policy_console.not_principal.identifiers
        }
      }
    }
  }

  dynamic "statement" {
    for_each = range(var.policy.enabled && var.existing_service_account.id != null || var.policy_console.enabled && var.existing_service_account.id != null ? 1 : 0)
    content {
      sid     = "default-rule-for-storage-admin-service-account"
      effect  = "Allow"
      actions = ["*"]
      resources = [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]

      dynamic "principals" {
        for_each = range(var.existing_service_account.id != null ? 1 : 0)
        content {
          type        = "CanonicalUser"
          identifiers = [var.existing_service_account.id]
        }
      }
    }
  }
}

resource "yandex_storage_bucket_grant" "this" {
  count  = length(var.grant) > 0 ? 1 : 0
  bucket = yandex_storage_bucket.this.bucket

  dynamic "grant" {
    for_each = var.grant
    content {
      id          = grant.value.id
      type        = grant.value.type
      uri         = grant.value.uri
      permissions = grant.value.permissions
    }
  }
}

resource "yandex_storage_bucket_policy" "this" {
  count  = var.policy.enabled || var.policy_console.enabled ? 1 : 0
  bucket = yandex_storage_bucket.this.bucket
  policy = data.aws_iam_policy_document.this[0].json
}
