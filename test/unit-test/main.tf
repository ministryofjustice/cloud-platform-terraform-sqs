terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = "eu-west-2"
}

module "sqs" {
  source = "../.."

  sqs_name               = "unit-test"
  team_name              = "cloud-platform"
  environment-name       = "development"
  is-production          = "false"
  business-unit          = "mojdigital"
  application            = "cloud-platform-terraform-sqs"
  infrastructure-support = "platform@digtal.justice.gov.uk"
  namespace              = "cloud-platform"
}

