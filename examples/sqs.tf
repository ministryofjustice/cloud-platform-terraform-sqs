module "sqs" {
  # source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=version" # use the latest release
  source = "../"

  # Queue configuration
  sqs_name        = "example"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
