variable "application" {}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "mojdigital"
}

variable "team_name" {
  description = "The name of your development team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
}

variable "is-production" {
  default = "false"
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)."
  default     = "30"
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)."
  default     = "345600"
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)."
  default     = "262144"
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)."
  default     = "0"
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)."
  default     = "0"
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours)."
  default     = 300
}

variable "aws_region" {
  description = "variable into which the resource will be created"
  default     = "eu-west-2"
}

variable "existing_user_name" {
  description = "if set, will add access to this queue to the existing user, otherwise a new one is created"
  default     = ""
}

variable "redrive_policy" {
  description = "escaped JSON string to set up the Dead Letter Queue"
  default     = ""
}

variable "sqs_name" {
  description = "name of the sqs queue"
}

variable "encrypt_sqs_kms" {
  description = "If set to true, this will create aws_kms_key and aws_kms_alias resources and add kms_master_key_id in aws_sqs_queue resource"
  default     = "false"
}
