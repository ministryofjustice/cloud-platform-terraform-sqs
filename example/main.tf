# terraform {
#   backend "s3" {}
# }

provider "aws" {
  region = "eu-west-1"
}

/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "example_sqs" {
  # source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=1.0"
  source = "../../cloud-platform-terraform-sqs"

  environment-name       = "test"
  team_name              = "cp"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  application            = "exampleapp"
  aws_region             = "eu-west-2"
}

resource "kubernetes_secret" "example_sqs" {
  metadata {
    name      = "example-sqs"
    namespace = "example-team"
  }

  data {
    access_key_id     = "${module.example_sqs.access_key_id}"
    secret_access_key = "${module.example_sqs.secret_access_key}"
    sqs_id            = "${module.example_sqs.sqs_id}"
    sqs_arn           = "${module.example_sqs.sqs_arn}"
  }
}
