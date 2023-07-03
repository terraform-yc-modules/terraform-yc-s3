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

  server_side_encryption_configuration = {
    enabled = true
  }

  sse_kms_key_configuration = {
    name_prefix = "demo-key"
  }
}

output "bucket_name" {
  description = "The name of the bucket."
  value       = module.s3.bucket_name
}
