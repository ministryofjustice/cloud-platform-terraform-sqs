locals {
  default_tags = {
    # Mandatory
    business-unit = var.business-unit
    application   = var.application
    is-production = var.is-production
    owner         = var.team_name
    namespace     = var.namespace # for billing and identification purposes
    # Optional
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure-support
  }
}

data "aws_caller_identity" "current" {}

resource "random_id" "id" {
  byte_length = 6
}

resource "aws_kms_key" "kms" {
  description = "KMS key for ${var.team_name}-${var.environment-name}-${var.sqs_name}"
  count       = var.encrypt_sqs_kms ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-policy"
    Statement = [
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:TagResource",
          "kms:UntagResource"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow s3 use of the key"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow SNS use of the key"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow IAM use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "Allow cross-account use of the key"
        Effect = "Allow"
        Principal = {
          AWS = length(var.kms_external_access) >= 1 ? var.kms_external_access : ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  count         = var.encrypt_sqs_kms ? 1 : 0
  name          = "alias/${var.team_name}-${var.environment-name}-${var.sqs_name}"
  target_key_id = aws_kms_key.kms[0].key_id
}

locals {
  queue_suffix = var.fifo_queue ? "${var.team_name}-${var.environment-name}-${var.sqs_name}.fifo" : "${var.team_name}-${var.environment-name}-${var.sqs_name}"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                              = local.queue_suffix
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  kms_master_key_id                 = var.encrypt_sqs_kms ? join("", aws_kms_key.kms.*.arn) : ""
  redrive_policy                    = var.redrive_policy
  fifo_queue                        = var.fifo_queue

  tags = local.default_tags
}

# Legacy long-lived credentials
locals {
  create_user = replace(var.existing_user_name, "cp-", "") == var.existing_user_name ? 1 : 0
}

resource "aws_iam_user" "user" {
  count = local.create_user
  name  = "cp-sqs-${random_id.id.hex}"
  path  = "/system/sqs-user/${var.team_name}/"
}

resource "aws_iam_access_key" "key" {
  count = local.create_user
  user  = aws_iam_user.user[0].name
}

resource "aws_iam_user_policy" "userpol" {
  name   = aws_sqs_queue.terraform_queue.name
  policy = data.aws_iam_policy_document.policy.json
  user   = local.create_user == 1 ? join("", aws_iam_user.user.*.name) : var.existing_user_name
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      aws_sqs_queue.terraform_queue.arn,
    ]
  }
}

# Short-lived credentials (IRSA)
data "aws_iam_policy_document" "irsa" {
  version = "2012-10-17"
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.terraform_queue.arn]
  }
}

resource "aws_iam_policy" "irsa" {
  name   = "cloud-platform-sqs-${random_id.id.hex}"
  path   = "/cloud-platform/sqs/"
  policy = data.aws_iam_policy_document.irsa.json
  tags   = local.default_tags
}
