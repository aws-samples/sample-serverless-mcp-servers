terraform {
  # 1.11+ is required for ephemeral resources and write-only arguments,
  # used to keep the JWT signature secret out of plan and state files.
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.72"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.9"
    }
  }
}

provider "aws" {
}
