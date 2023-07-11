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

module "log_bucket" {
  source = "../../"

  bucket_name = "logging-bucket"

  lifecycle_rule = [
    {
      enabled = true
      id      = "cleanupoldlogs"
      expiration = {
        days = 365
      }
    }
  ]
}

module "s3" {
  source = "../../"

  bucket_name = "all-in-one-bucket"

  grant = [
    {
      id          = "ajeb9lk8f1xxxxxxxxxx"
      type        = "CanonicalUser"
      permissions = ["FULL_CONTROL"]
    },
    {
      type        = "Group"
      permissions = ["READ"]
      uri         = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
    }
  ]

  lifecycle_rule = [
    {
      enabled = true
      id      = "test"
      prefix  = "prefix/"
      expiration = {
        days = 30
      }
    },
    {
      enabled = true
      id      = "log"
      prefix  = "log/"
      transition = {
        days          = 30
        storage_class = "COLD"
      }
      expiration = {
        days = 90
      }
    },
    {
      enabled = true
      id      = "everything180"
      prefix  = ""
      expiration = {
        days = 180
      }
    },
    {
      enabled = true
      id      = "cleanupoldversions"
      prefix  = "config/"
      noncurrent_version_transition = {
        days          = 30
        storage_class = "COLD"
      }
      noncurrent_version_expiration = {
        days = 90
      }
    },
    {
      enabled                                = true
      id                                     = "abortmultiparts"
      prefix                                 = ""
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://storage-cloud.example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    enabled = true
  }

  logging = {
    target_bucket = module.log_bucket.bucket_name
    target_prefix = "tf-logs/"
  }

  max_size              = 1024
  default_storage_class = "COLD"

  tags = {
    some_key = "some_value"
  }
}
