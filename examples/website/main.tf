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

  acl = "public-read"

  website = {
    error_document = "404.html"
    routing_rules = [
      {
        condition = {
          key_prefix_equals = "docs/"
        }
        redirect = {
          replace_key_prefix_with = "documents/"
        }
      }
    ]
  }
}

output "bucket_name" {
  description = "The name of the bucket."
  value       = module.s3.bucket_name
}

output "website_endpoint" {
  description = "The website endpoint."
  value       = module.s3.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint."
  value       = module.s3.website_domain
}
