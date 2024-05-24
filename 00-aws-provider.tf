terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "resume-site-terra-backend"
    key    = "terraform-state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_region" "default" {
  name = "us-east-1"
}
