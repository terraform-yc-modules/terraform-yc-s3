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

output "bucket_policy_allowed_ips" {
  description = "List of IPs from which allowed principal can access the bucket."
  value = flatten([
    for k, statements in try(jsondecode(data.aws_iam_policy_document.this[0].json), []) : [
      for statement in statements : {
        "allowed_principal" = try(statement.Principal, null)
        "denied_principal"  = try(statement.NotPrincipal, null)
        "IP"                = statement.Condition.IpAddress["aws:SourceIp"]
      } if statement.Effect == "Allow" && try(statement.Condition.IpAddress["aws:SourceIp"], null) != null
    ] if k == "Statement"
  ])
}

output "storage_admin_service_account_id" {
  description = "Service account ID of the Object storage admin."
  value       = try(yandex_iam_service_account.storage_admin[0].id, null)
}
