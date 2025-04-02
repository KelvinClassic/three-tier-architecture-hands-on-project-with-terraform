terraform {
  cloud {
    organization = "kelassic-organization-name"
    workspaces {
      name = "three-tier-architecture-hands-on-project-with-terraform"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}