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

module "s3" {
  source = "../../"

  bucket_name = "www.example.com"
  acl         = "public-read"

  website = {
    index_document = "index.html"
    error_document = "error.html"
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

  https = {
    certificate = {
      public_dns_zone_id = "dnsei3sj93xxxxxxxxxx"
      domains            = ["www.example.com"]
    }
  }
}
