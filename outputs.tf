output "user_name" {
  description = "IAM user with access to the queue"
  value       = "${join("", aws_iam_user.user.*.name)}"
}

output "access_key_id" {
  description = "Access key id for the credentials"
  value       = "${join("", aws_iam_access_key.key.*.id)}"
}

output "secret_access_key" {
  description = "Secret for the new credentials"
  value       = "${join("", aws_iam_access_key.key.*.secret)}"
}

output "sqs_id" {
  description = "The URL for the created Amazon SQS queue."
  value       = "${aws_sqs_queue.terraform_queue.id}"
}

output "sqs_arn" {
  description = "The ARN of the SQS queue."
  value       = "${aws_sqs_queue.terraform_queue.arn}"
}

output "sqs_name" {
  description = "The name of the SQS queue."
  value       = "${aws_sqs_queue.terraform_queue.name}"
}
