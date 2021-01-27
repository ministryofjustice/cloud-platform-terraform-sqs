output "sqs_arn" {
  description = "ARN for the queue created"
  value       = module.sqs.sqs_arn
}

output "sqs_name" {
  description = "Name for the queue created"
  value       = module.sqs.sqs_name
}

