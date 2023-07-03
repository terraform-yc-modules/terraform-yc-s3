terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.92"
    }
  }
}

provider "aws" {
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  bucket = "demo-policy-bucket"
}

module "s3" {
  source = "../../"

  bucket = local.bucket

  policy = {
    statements = [
      {
        sid     = "rule-allow-all-for-all-except-sa"
        effect  = "Allow"
        actions = ["s3:*"]
        not_principal = {
          type        = "CanonicalUser"
          identifiers = ["serviceAccount:ajeph8f8xxxxxxxxxxxx"]
        }
        resources = [
          "${local.bucket}",
          "${local.bucket}/*"
        ]
      },
      {
        sid     = "rule-allow-upload-for-sa-from-ip"
        effect  = "Allow"
        actions = ["s3:PutObject"]
        resources = [
          "${local.bucket}",
          "${local.bucket}/*"
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
    bucket_name = local.bucket
    statements = [
      {
        sid    = "rule-allow-console-for-all"
        effect = "Allow"
        principal = {
          type        = "*"
          identifiers = ["*"]
        }
      }
    ]
  }
}

output "bucket_name" {
  description = "The name of the bucket."
  value       = module.s3.bucket_name
}

output "bucket_policy_allowed_ips" {
  description = "List of IPs from which allowed principal can access the bucket."
  value       = module.s3.bucket_policy_allowed_ips
}
