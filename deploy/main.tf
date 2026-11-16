terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.26.0"
    }
  }
  backend "s3" {
    bucket = "bharper77-terraform"
    key    = "klbdesigns.tfstate"
    region = "eu-west-1"
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
