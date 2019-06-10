# Example AWS SQS configuration

The configuration in this directory creates an example AWS SQS queue.

The output will be in a kubernetes `Secret`, which includes the values of `sqs_id`, and `sqs_arn`.

If the `existing_user_name` variable is set, a policy will be added to grant access to the queue, otherwise a new user will be created, with its `access_key_id` and `secret_access_key` added to the output.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you want to destroy these resources created.