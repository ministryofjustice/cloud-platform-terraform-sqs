# cloud-platform-terraform-sqs

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-sqs/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-sqs/releases)

This Terraform module will create an AWS SQS queue and also provide the IAM credentials to access the queue. This module currently only supports standard queues, and not FINO queues.

## Usage

```hcl
module "example_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=1.0"

  environment-name       = "example-env"
  team_name              = "cloud-platform"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  application            = "exampleapp"
}

```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| visibility_timeout_seconds | The visibility timeout for the queue | integer | `30` | no |
| message_retention_seconds | The number of seconds Amazon SQS retains a message| integer | `345600` | no |
| max_message_size | Max message size in bytes | integer | `262144` | no |
| delay_seconds | Seconds that message will be delayed for | integer | `0` | no |
| receive_wait_time_seconds | Seconds for which a ReceiveMessage call will wait for a message to arrive | integer | `0` | no |
| kms_master_key_id | The ID of an AWS-managed customer master key | string | - | no |
| kms_data_key_reuse_period_seconds | Seconds for which Amazon SQS can reuse a data key | integer | `0` | no |


### Tags

Some of the inputs are tags. All infrastructure resources need to be tagged according to the [MOJ techincal guidence](https://ministryofjustice.github.io/technical-guidance/standards/documenting-infrastructure-owners/#documenting-owners-of-infrastructure). The tags are stored as variables that you will need to fill out as part of your module.

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application |  | string | - | yes |
| business-unit | Area of the MOJ responsible for the service | string | `mojdigital` | yes |
| environment-name |  | string | - | yes |
| infrastructure-support | The team responsible for managing the infrastructure. Should be of the form team-email | string | - | yes |
| is-production |  | string | `false` | yes |
| team_name |  | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| access_key_id | Access key id for the credentials. |
| secret_access_key | Secret for the new credentials. |
| sqs_id | The URL for the created Amazon SQS queue. |
| sqs_arn | The ARN of the SQS queue. |

## Reading Material

- https://docs.aws.amazon.com/sqs/
