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

  bucket_name = "static-website-${random_string.unique_id.result}"
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

  #   https = {
  #     certificate = {
  #       public_dns_zone_id = <Your Public DNS Zone ID>
  #       domains            = <Your Domains>

  #     }
  #   }
}
