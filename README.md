# cloud-platform-terraform-sqs

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-sqs/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-sqs/releases)

This Terraform module will create an AWS SQS queue and also provide the IAM credentials to access the queue. This module currently only supports standard queues, and not FINO queues.

## Usage

```hcl
module "example_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=version"

  environment-name       = "example-env"
  team_name              = "cloud-platform"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  application            = "exampleapp"
  sqs_name               = "examplesqsname"

  # Set encrypt_sqs_kms = "true", to enable SSE for SQS using KMS key.
  encrypt_sqs_kms = "false"

  # existing_user_name     = module.another_sqs_instance.user_name
  
  # NB: If you want multiple queues to share an IAM user, you must create one queue first,
  # letting it create the IAM user. Then, in a separate PR, you can create all the other
  # queues. Otherwise terraform cannot resolve the cyclic dependency of creating multiple
  # queues but one IAM user, because it cannot work out which queue will successfully
  # create the user, and which queues will reuse that user.

  providers = {
    aws = aws.london
  }
}

```
## Access policy

SNS topics must be allowed access to either read or write, depending on application design, via an IAM policy (not to be confused with the policy defined along with the user if `existing_user_name` is not set).

Due to [some glitch](https://github.com/hashicorp/terraform/issues/4354) in the AWS API, TF cannot create the queue policy in a single step, so a separate resource type has been defined. To use, add in the same /resources/:

```
resource "aws_sqs_queue_policy" "example_sqs_policy" {
  queue_url = "${module.example_sqs.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.example_sqs.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.example_sqs.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.example_sns.topic_arn}"
                }
              }
        }
      ]
  }
  EOF
}
```

Note the reference to an SNS topic, which needs to be defined in the same namespace.

## Redrive policy

Messages that cannot be parsed are copied to a "dead letter" queue the ARN of which can be specified inline:

```
redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.example_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF
```

## Tags

Some of the inputs are tags. All infrastructure resources need to be tagged according to the [MOJ techincal guidance](https://ministryofjustice.github.io/technical-guidance/documentation/standards/documenting-infrastructure-owners.html#documenting-owners-of-infrastructure). The tags are stored as variables that you will need to fill out as part of your module.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application |  | string | - | yes |
| business-unit | Area of the MOJ responsible for the service | string | `mojdigital` | yes |
| environment-name |  | string | - | yes |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form team-email | string | - | yes |
| is-production |  | string | `false` | yes |
| team_name |  | string | - | yes |
| sqs_name |  | string | - | yes |

## Reading Material

- https://docs.aws.amazon.com/sqs/

<!--- BEGIN_TF_DOCS --->

<!--- END_TF_DOCS --->