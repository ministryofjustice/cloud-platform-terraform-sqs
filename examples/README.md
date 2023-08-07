# Example AWS SQS configuration

The configuration in this directory creates an example AWS SQS queue.

The output will be in a kubernetes `Secret`, which includes the values of `sqs_id`, and `sqs_arn`.

If the `existing_user_name` variable is set, a policy will be added to grant access to the queue, otherwise a new user will be created, with its `access_key_id` and `secret_access_key` added to the output.

There is a [character limit for policy size](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html#reference_iam-quotas-entity-length) per IAM user. You might face the `Maximum policy size of 2048 bytes exceeded `error, when passing the IAM user to `existing_user_name` to the new added queues if the limit exceeded. In such case, dont set the `existing_user_name` for the newly added sqs queues. This will create new/seperate IAM user with a seperate set of credentials added to the output.


## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you want to destroy these resources created.
