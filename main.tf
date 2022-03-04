provider "aws" {
  region  = "eu-central-1"
  version = "~>4.0.0"
}

terraform {
  backend "s3" {
    bucket = "awsecsec2bucket01"
    key    = "state/terraform.tfstate"
    region = "eu-central-1"
  }
}