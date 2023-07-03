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
