#
# Copyright 2023 - Emmanuel Bergerat
#

#--------------------------------------------------------------
#   Provider to Test Subscription
#--------------------------------------------------------------
provider "azurerm" {
  # Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference
  alias       = "example_test_Subscription" # Comment/Remove this alias as it may not be needed
  environment = "public"
  # partner_id  = ""

  tenant_id       = "<Put example_test_Subscription tenant_id value>"
  subscription_id = "<Put example_test_Subscription subscription_id value>"
  client_id       = "<Put example_test_Subscription client_id value>"
  client_secret   = "<Put example_test_Subscription client_secret value>"

  features {}
}
