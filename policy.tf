data "aws_iam_policy_document" "this" {
  count = var.policy != null || var.policy_console != null ? 1 : 0

  policy_id = try(var.policy.id, null)
  version   = try(var.policy.version, null)

  dynamic "statement" {
    for_each = try(var.policy.statements, [])
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
    for_each = try(var.policy_console.statements, [])
    content {
      sid     = statement.value.sid
      effect  = statement.value.effect
      actions = ["*"]
      resources = [
        "arn:aws:s3:::${var.policy_console.bucket_name}/*",
        "arn:aws:s3:::${var.policy_console.bucket_name}"
      ]

      condition {
        test     = "StringLike"
        variable = "aws:referer"
        values   = ["https://console.cloud.yandex.*/folders/*/storage/buckets/${var.policy_console.bucket_name}*"]
      }

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
    }
  }
}
