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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.27.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.27.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.userpol](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sqs_queue.terraform_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | n/a | `any` | n/a | yes |
| <a name="input_business-unit"></a> [business-unit](#input\_business-unit) | Area of the MOJ responsible for the service. | `string` | `"mojdigital"` | no |
| <a name="input_delay_seconds"></a> [delay\_seconds](#input\_delay\_seconds) | The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). | `string` | `"0"` | no |
| <a name="input_encrypt_sqs_kms"></a> [encrypt\_sqs\_kms](#input\_encrypt\_sqs\_kms) | If set to true, this will create aws\_kms\_key and aws\_kms\_alias resources and add kms\_master\_key\_id in aws\_sqs\_queue resource | `bool` | `false` | no |
| <a name="input_environment-name"></a> [environment-name](#input\_environment-name) | The type of environment you're deploying to. | `any` | n/a | yes |
| <a name="input_existing_user_name"></a> [existing\_user\_name](#input\_existing\_user\_name) | if set, will add access to this queue to the existing user, otherwise a new one is created | `string` | `""` | no |
| <a name="input_fifo_queue"></a> [fifo\_queue](#input\_fifo\_queue) | FIFO means exactly-once processing. Duplicates are not introduced into the queue. | `bool` | `false` | no |
| <a name="input_infrastructure-support"></a> [infrastructure-support](#input\_infrastructure-support) | The team responsible for managing the infrastructure. Should be of the form team-email. | `any` | n/a | yes |
| <a name="input_is-production"></a> [is-production](#input\_is-production) | n/a | `string` | `"false"` | no |
| <a name="input_kms_data_key_reuse_period_seconds"></a> [kms\_data\_key\_reuse\_period\_seconds](#input\_kms\_data\_key\_reuse\_period\_seconds) | The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). | `number` | `300` | no |
| <a name="input_kms_external_access"></a> [kms\_external\_access](#input\_kms\_external\_access) | A list of external AWS principals (e.g. account ids, or IAM roles) that can access the KMS key, to enable cross-account message decryption. | `list(string)` | `[]` | no |
| <a name="input_max_message_size"></a> [max\_message\_size](#input\_max\_message\_size) | The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). | `string` | `"262144"` | no |
| <a name="input_message_retention_seconds"></a> [message\_retention\_seconds](#input\_message\_retention\_seconds) | The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). | `string` | `"345600"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `any` | n/a | yes |
| <a name="input_receive_wait_time_seconds"></a> [receive\_wait\_time\_seconds](#input\_receive\_wait\_time\_seconds) | The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). | `string` | `"0"` | no |
| <a name="input_redrive_policy"></a> [redrive\_policy](#input\_redrive\_policy) | escaped JSON string to set up the Dead Letter Queue | `string` | `""` | no |
| <a name="input_sqs_name"></a> [sqs\_name](#input\_sqs\_name) | name of the sqs queue | `any` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | The name of your development team | `any` | n/a | yes |
| <a name="input_visibility_timeout_seconds"></a> [visibility\_timeout\_seconds](#input\_visibility\_timeout\_seconds) | The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). | `string` | `"30"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | Access key id for the credentials |
| <a name="output_irsa_policy_arn"></a> [irsa\_policy\_arn](#output\_irsa\_policy\_arn) | n/a |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | Secret for the new credentials |
| <a name="output_sqs_arn"></a> [sqs\_arn](#output\_sqs\_arn) | The ARN of the SQS queue. |
| <a name="output_sqs_id"></a> [sqs\_id](#output\_sqs\_id) | The URL for the created Amazon SQS queue. |
| <a name="output_sqs_name"></a> [sqs\_name](#output\_sqs\_name) | The name of the SQS queue. |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | IAM user with access to the queue |

<!--- END_TF_DOCS --->