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

module "log_bucket" {
  source = "../../"
}

module "s3" {
  source = "../../"

  logging = {
    target_bucket = module.log_bucket.bucket_name
    target_prefix = "logs/"
  }
}

output "log_bucket_name" {
  description = "The name of the logging bucket."
  value       = module.log_bucket.bucket_name
}

output "bucket_name" {
  description = "The name of the main bucket."
  value       = module.s3.bucket_name
}
