output "bucket_name" {
  description = "The name of the bucket."
  value       = yandex_storage_bucket.this.id
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = yandex_storage_bucket.this.bucket_domain_name
}

output "website_endpoint" {
  description = "The website endpoint."
  value       = yandex_storage_bucket.this.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint."
  value       = yandex_storage_bucket.this.website_domain
}

output "kms_master_key_id" {
  description = "The KMS master key ID used for the server-side encryption."
  value       = try(yandex_kms_symmetric_key.this[0].id, null)
}

output "cm_certificate_id" {
  description = "Certificate ID of the generated HTTPS certificate in Yandex Cloud Certificate Manager"
  value       = try(yandex_cm_certificate.this[0].id, null)
}
