terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider

provider "aws" {

  access_key = ""
  secret_key = ""
  region     = var.region
}

# create an s3 bucket

terraform {
  backend "s3" {
    bucket = "sayankbucket"
    key = "sayankkibucket/terraform.tfstate"
    region = "us-west-1"
    access_key = ""
   secret_key = ""

  }
  
}

