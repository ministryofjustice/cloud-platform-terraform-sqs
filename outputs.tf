output "sqs_id" {
  description = "The URL for the created Amazon SQS queue"
  value       = aws_sqs_queue.terraform_queue.id
}

output "sqs_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.terraform_queue.arn
}

output "sqs_name" {
  description = "The name of the SQS queue"
  value       = aws_sqs_queue.terraform_queue.name
}

output "irsa_policy_arn" {
  description = "IAM role ARN for use with IRSA"
  value       = aws_iam_policy.irsa.arn
}
