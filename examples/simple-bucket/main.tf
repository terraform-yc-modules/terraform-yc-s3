# To always have a unique bucket name in this example
resource "random_string" "unique_id" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

module "s3" {
  source = "../../"

  bucket_name = "simple-bucket-${random_string.unique_id.result}"
  versioning = {
    enabled = true
  }
}
