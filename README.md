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
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) |
| [aws_iam_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |
| [aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application | n/a | `any` | n/a | yes |
| aws\_region | variable into which the resource will be created | `string` | `"eu-west-2"` | no |
| business-unit | Area of the MOJ responsible for the service. | `string` | `"mojdigital"` | no |
| delay\_seconds | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). | `string` | `"0"` | no |
| encrypt\_sqs\_kms | If set to true, this will create aws\_kms\_key and aws\_kms\_alias resources and add kms\_master\_key\_id in aws\_sqs\_queue resource | `bool` | `false` | no |
| environment-name | The type of environment you're deploying to. | `any` | n/a | yes |
| existing\_user\_name | if set, will add access to this queue to the existing user, otherwise a new one is created | `string` | `""` | no |
| fifo\_queue | FIFO means exactly-once processing. Duplicates are not introduced into the queue. | `bool` | `false` | no |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form team-email. | `any` | n/a | yes |
| is-production | n/a | `string` | `"false"` | no |
| kms\_data\_key\_reuse\_period\_seconds | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). | `number` | `300` | no |
| kms\_external\_access | A list of external AWS principals (e.g. account ids, or IAM roles) that can access the KMS key, to enable cross-account message decryption. | `list(string)` | n/a | no |
| max\_message\_size | The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). | `string` | `"262144"` | no |
| message\_retention\_seconds | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). | `string` | `"345600"` | no |
| namespace | n/a | `any` | n/a | yes |
| receive\_wait\_time\_seconds | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). | `string` | `"0"` | no |
| redrive\_policy | escaped JSON string to set up the Dead Letter Queue | `string` | `""` | no |
| sqs\_name | name of the sqs queue | `any` | n/a | yes |
| team\_name | The name of your development team | `any` | n/a | yes |
| visibility\_timeout\_seconds | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). | `string` | `"30"` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_key\_id | Access key id for the credentials |
| secret\_access\_key | Secret for the new credentials |
| sqs\_arn | The ARN of the SQS queue. |
| sqs\_id | The URL for the created Amazon SQS queue. |
| sqs\_name | The name of the SQS queue. |
| user\_name | IAM user with access to the queue |

<!--- END_TF_DOCS --->