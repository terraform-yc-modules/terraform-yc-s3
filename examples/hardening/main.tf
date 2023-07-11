terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.92"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}

provider "aws" {
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  bucket_name = "hardening-bucket"
}

module "log_bucket" {
  source = "../../"

  bucket_name = "logging-bucket"
}

module "s3" {
  source = "../../"

  bucket_name = local.bucket_name

  # In this example, we allow access to the bucket to everyone except "serviceAccount:ajeph8f8xxxxxxxxxxxx".
  # "serviceAccount:ajeph8f8xxxxxxxxxxxx" is allowed to upload objects to the bucket from certain IP addresses.
  # Also access from the Yandex Cloud Console is disabled for "serviceAccount:ajeph8f8xxxxxxxxxxxx".
  policy = {
    enabled = true
    statements = [
      {
        sid     = "example-rule-allow-all-for-all-except-sa"
        effect  = "Allow"
        actions = ["s3:*"]
        not_principal = {
          type        = "CanonicalUser"
          identifiers = ["serviceAccount:ajeph8f8xxxxxxxxxxxx"]
        }
        resources = [
          "${local.bucket_name}",
          "${local.bucket_name}/*"
        ]
      },
      {
        sid     = "example-rule-allow-upload-from-ip-for-sa"
        effect  = "Allow"
        actions = ["s3:PutObject"]
        resources = [
          "${local.bucket_name}",
          "${local.bucket_name}/*"
        ]
        principal = {
          type        = "CanonicalUser"
          identifiers = ["serviceAccount:ajeph8f8xxxxxxxxxxxx"]
        }
        condition = {
          type   = "IpAddress"
          key    = "aws:SourceIp"
          values = ["100.101.102.103/32", "104.105.106.107/32"]
        }
      }
    ]
  }

  policy_console = {
    enabled = true
    not_principal = {
      type        = "CanonicalUser"
      identifiers = ["serviceAccount:ajeph8f8xxxxxxxxxxxx"]
    }
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
