package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSQSCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	sqsArn := terraform.Output(t, terraformOptions, "sqs_arn")
	sqsName := terraform.Output(t, terraformOptions, "sqs_name")

	assert.Equal(t, "arn:aws:sqs:eu-west-2:000000000000:cloud-platform-development-unit-test", sqsArn)
	assert.Equal(t, "cloud-platform-development-unit-test", sqsName)

}
