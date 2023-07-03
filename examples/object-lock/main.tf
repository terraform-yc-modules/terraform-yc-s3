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

module "s3" {
  source = "../../"

  versioning = {
    enabled = true
  }

  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "COMPLIANCE"
        days = 10
      }
    }
  }
}

output "bucket_name" {
  description = "The name of the bucket."
  value       = module.s3.bucket_name
}
