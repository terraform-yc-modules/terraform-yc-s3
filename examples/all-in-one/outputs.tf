output "log_bucket_name" {
  description = "The name of the logging bucket."
  value       = module.log_bucket.bucket_name
}

output "bucket_name" {
  description = "The name of the main bucket."
  value       = module.s3.bucket_name
}
