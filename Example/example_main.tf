#
# Copyright 2024 - Emmanuel Bergerat
#

#--------------------------------------------------------------
#   Test Resource Group module Main
#--------------------------------------------------------------
module "tfc_rg" {
  # Terraform Cloud use
  source  = "app.terraform.io/embergertf/resourcegroup/azurerm"
  version = "~> 2.1"

  # Name override
  # name_override = var.name_override

  # Naming convention
  naming_values = var.naming_values
  # region_code     = var.region_code
  # subsc_code      = var.subsc_code
  # env             = var.env
  # base_name       = var.base_name
  # additional_name = var.additional_name
  # iterator        = var.iterator
  # owner           = var.owner

  # # Random
  # add_random = var.add_random
  # rnd_length = var.rnd_length

  additional_tags = var.rg_additional_tags
}

module "publicip" {
  source  = "app.terraform.io/embergertf/publicip/http"
  version = "~> 1.0"
}

module "st_acct_module_localtest" {
  # Local use
  source = "../../terraform-azurerm-storage-account"

  # Naming convention
  naming_values = module.tfc_rg.naming_values

  # Storage settings
  resource_group_name = module.tfc_rg.resource_group_name
  assign_identity     = true

  # Blob settings
  blobs_versioning_enabled  = false
  blobs_retention_policy    = 1
  blobs_change_feed_enabled = true

  containers = var.test_containers

  # Security settings
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = [module.publicip.public_ip]
    virtual_network_subnet_ids = []
    bypass                     = ["None"]
  }
  private_link_accesses = var.test_private_link_accesses

  additional_tags = var.st_additional_tags
}
#*/
