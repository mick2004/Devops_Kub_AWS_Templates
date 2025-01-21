terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }

    required_version = ">= 1.2.0"
}

provider "aws" {
  # Configuration options
  region = "us-west-2"
}