variable "public_dns_zone_id" {
  description = "Yandex Cloud DNS public zone ID"
  type        = string
  validation {
    condition     = var.public_dns_zone_id != null
    error_message = "Please set the variable \"public_dns_zone_id\" to run this example."
  }
  default = null
}

variable "domains" {
  description = "List of domains in HTTPS certificate"
  type        = list(string)
  validation {
    condition     = length(var.domains) != 0
    error_message = "Please set the variable \"domains\" to run this example."
  }
  default = []
}
