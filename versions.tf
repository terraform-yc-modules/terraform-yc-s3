terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.9"
    }

    random = {
      source  = "hashicorp/random"
      version = "> 3.5"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "> 5.1"
    }
  }
}
