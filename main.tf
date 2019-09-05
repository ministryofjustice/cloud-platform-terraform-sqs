data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_id" "id" {
  byte_length = 6
}

resource "aws_kms_key" "kms" {
  description = "KMS key for ${var.team_name}-${var.environment-name}-${var.sqs_name}"
  policy      = "${var.kms_key_policy}"

  tags {
    business-unit          = "${var.business-unit}"
    application            = "${var.application}"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.infrastructure-support}"
  }
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.team_name}-${var.environment-name}-${var.sqs_name}"
  target_key_id = "${aws_kms_key.kms.key_id}"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                              = "${var.team_name}-${var.environment-name}-${var.sqs_name}"
  visibility_timeout_seconds        = "${var.visibility_timeout_seconds}"
  message_retention_seconds         = "${var.message_retention_seconds}"
  max_message_size                  = "${var.max_message_size}"
  delay_seconds                     = "${var.delay_seconds}"
  receive_wait_time_seconds         = "${var.receive_wait_time_seconds}"
  kms_master_key_id                 = "${aws_kms_key.kms.arn}"
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"
  redrive_policy                    = "${var.redrive_policy}"

  tags {
    business-unit          = "${var.business-unit}"
    application            = "${var.application}"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.infrastructure-support}"
  }
}

locals {
  create_user = "${replace(var.existing_user_name, "cp-", "") == var.existing_user_name ? 1 : 0}"
}

resource "aws_iam_user" "user" {
  count = "${local.create_user}"
  name  = "cp-sqs-${random_id.id.hex}"
  path  = "/system/sqs-user/${var.team_name}/"
}

resource "aws_iam_access_key" "key" {
  count = "${local.create_user}"
  user  = "${aws_iam_user.user.name}"
}

resource "aws_iam_user_policy" "userpol" {
  name   = "${aws_sqs_queue.terraform_queue.name}"
  policy = "${data.aws_iam_policy_document.policy.json}"
  user   = "${local.create_user == 1 ? join("", aws_iam_user.user.*.name) : var.existing_user_name}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "sqs:*",
    ]

    resources = [
      "${aws_sqs_queue.terraform_queue.arn}",
    ]
  }
}
