#
# Copyright 2023 - Emmanuel Bergerat
#

#--------------------------------------------------------------
# - Resource Group
#--------------------------------------------------------------
module "rg" {
  # Terraform Cloud
  source  = "app.terraform.io/embergertf/resourcegroup/azurerm"
  version = "~>1.3.3"

  # Resource Group naming
  region_code     = var.region_code
  subsc_code      = var.subsc_code
  env             = var.env
  base_name       = var.base_name
  additional_name = var.additional_name
  iterator        = var.iterator

  owner      = var.owner
  add_random = true
  rnd_length = 3
}

/*
#----------------------------------------
# - Key vault
#----------------------------------------
module "kv" {
  # Terraform Cloud/Enterprise use
  source  = "app.terraform.io/msftwfdeo/wf-keyvault/azurerm"
  version = "~>2.0.0"

  depends_on = [
    module.rg
  ]

  # Key Vault naming
  region_code     = var.region_code
  env             = var.env
  base_name       = var.base_name
  additional_name = var.additional_name

  au      = var.au
  country = var.country
  org     = var.org
  owner   = var.owner

  add_random = true
  rnd_length = 2

  # Delete during WF intake process
  iterator = var.iterator

  # Key Vault variables
  resource_group_name             = module.rg.name
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  network_acls                    = local.kv_network_acls

  # Secrets
  secrets = {
    "validation" = "Validated!"
  }
}
#*/

#------------------------------------------
#  - Creating Storage account
#------------------------------------------
module "st" {
  # Local use
  source = "../../terraform-azurerm-storage-account"

  # Terraform Cloud/Enterprise use
  #source  = "app.terraform.io/embergertf/storage-account/azurerm"
  #version = "~>1.0.0"

  depends_on = [
    module.rg
  ]

  # Storage Account naming
  region_code     = var.region_code
  subsc_code      = var.subsc_code
  env             = var.env
  base_name       = var.base_name
  additional_name = var.additional_name
  iterator        = var.iterator

  owner      = var.owner
  add_random = true
  rnd_length = 3

  additional_tags = var.additional_tags

  # Storage Account settings
  resource_group_name = module.rg.name
  # key_vault_id        = module.kv.id

  is_log_storage     = false
  persist_access_key = true
  assign_identity    = true
  cmk_enabled        = true

  containers  = var.st1_containers
  blobs       = var.st1_blobs
  queues      = var.st1_queues
  file_shares = var.st1_file_shares
  tables      = var.st1_tables

  network_rules = local.st_network_acls
}
#*/