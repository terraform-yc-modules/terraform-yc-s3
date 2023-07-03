# To always have a unique bucket name in this example
resource "random_string" "unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

module "log_bucket" {
  source = "../../"

  bucket_name = "logging-bucket-${random_string.unique_id.result}"

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

  bucket_name = "all-in-one-bucket-${random_string.unique_id.result}"

  grant = [
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
