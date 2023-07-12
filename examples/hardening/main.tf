# To always have a unique bucket name in this example
resource "random_string" "unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  bucket_name = "hardening-bucket-${random_string.unique_id.result}"
}

module "log_bucket" {
  source = "../../"

  bucket_name = "logging-bucket-${random_string.unique_id.result}"
}

module "s3" {
  source = "../../"

  bucket_name = local.bucket_name

  # In this example, we allow each user authenticated in Yandex Cloud to upload objects to the bucket from certain IP addresses.
  policy = {
    enabled = true
    statements = [
      {
        sid     = "example-rule-allow-upload-from-ip-for-all-auth-users"
        effect  = "Allow"
        actions = ["s3:PutObject"]
        resources = [
          "${local.bucket_name}",
          "${local.bucket_name}/*"
        ]
        principal = {
          type        = "CanonicalUser"
          identifiers = ["system:allAuthenticatedUsers"]
        }
        condition = {
          type   = "IpAddress"
          key    = "aws:SourceIp"
          values = ["100.101.102.103/32", "104.105.106.107/32"]
        }
      }
    ]
  }

  # Access to the bucket from the Yandex Cloud Console is enabled for everyone who has access to the Cloud Folder.
  policy_console = {
    enabled = true
  }

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      enabled = true
      id      = "cleanupoldlogs"
      expiration = {
        days = 365
      }
    },
    {
      enabled = true
      id      = "cleanupoldversions"
      noncurrent_version_transition = {
        days          = 60
        storage_class = "COLD"
      }
      noncurrent_version_expiration = {
        days = 150
      }
    }
  ]

  logging = {
    target_bucket = module.log_bucket.bucket_name
    target_prefix = "logs/"
  }

  server_side_encryption_configuration = {
    enabled = true
  }
}
