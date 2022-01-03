terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

module "aws-cloudtrail" {
  source = "./modules/"

}


resource "aws_cloudwatch_log_group" "trails" {
  name = "trails"
}


module "aws-alarm" {
  source = "./modules/"
}
