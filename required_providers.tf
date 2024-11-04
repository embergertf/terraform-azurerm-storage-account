#
# Copyright 2024 Emmanuel Bergerat
#

# -
# - Required Terraform providers & versions
# -
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.7"
    }
  }
}
