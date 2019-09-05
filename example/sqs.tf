module "example_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.3"

  environment-name       = "test"
  team_name              = "cp"
  infrastructure-support = "example-team@digtal.justice.gov.uk"
  application            = "exampleapp"
  sqs_name               = "examplesqsname"

  # existing_user_name     = "${module.another_sqs_instance.user_name}"

  providers = {
    aws = "aws.london"
  }

  /*
  *  SQS SSE enabled with AWS Key Management Service (KMS), using default policy. 
  *  Using the example below, follow the guidance (https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) to create your own policy.
  *  

  kms_key_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "key-policy",
    "Statement": [
      {
        "Sid": "Enable Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
EOF
*/

}

resource "kubernetes_secret" "example_sqs" {
  metadata {
    name      = "example-sqs"
    namespace = "example-team"
  }

  data {
    access_key_id     = "${module.example_sqs.access_key_id}"
    secret_access_key = "${module.example_sqs.secret_access_key}"

    # the above will not be set if existing_user_name is defined
    sqs_id   = "${module.example_sqs.sqs_id}"
    sqs_arn  = "${module.example_sqs.sqs_arn}"
    sqs_name = "${module.example_sqs.sqs_name}"
  }
}
