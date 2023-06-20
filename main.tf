#
# Copyright 2023 - Emmanuel Bergerat
#

# Created  on: Feb. 24th 2023
# Created  by: Emmanuel
# Modified on: 
# Modified by: 
# Overview:
#   This module:
#   - Creates storage account and associated resources,

#-------------------------------
# - Dependencies data resources
#-------------------------------
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}
data "azurerm_key_vault" "this" {
  count = (var.cmk_enabled == true || var.persist_access_key == true) ? 1 : 0

  resource_group_name = split("/", var.key_vault_id)[4]
  name                = split("/", var.key_vault_id)[8]
}

#-----------------------------------------------------------
# - Create the Storage Account name with Base module
#-----------------------------------------------------------
module "st_name" {
  # Terraform Cloud PMR use
  source  = "app.terraform.io/embergertf/base/azurerm"
  version = "~>3.0.0"

  name_override = var.name_override

  region_code     = var.region_code
  subsc_code      = var.subsc_code
  env             = var.env
  base_name       = var.base_name
  additional_name = var.additional_name
  iterator        = var.iterator
  owner           = var.owner

  # Storage Account specific settings
  resource_type_code = "st"
  max_length         = 24
  no_dashes          = true
  add_random         = var.add_random
  rnd_length         = var.rnd_length
}

#-----------------------
# - Generate the locals
#-----------------------
locals {
  # Networking rule Allowing all Public access
  enabled_for_all_network = {
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = ["None"]
  }
  # Set the network rule to use
  network_rules = var.network_rules.default_action == "Allow" ? local.enabled_for_all_network : var.network_rules

  blobs = {
    for b in var.blobs : b.name => merge({
      type         = "Block"
      size         = 0
      content_type = "application/octet-stream"
      source_file  = null
      source_uri   = null
      metadata     = {}
    }, b)
  }

  tags = merge(
    data.azurerm_resource_group.this.tags,
    module.st_name.tags,
    var.additional_tags
  )
}

#-------------------
# - Storage Account
#-------------------
resource "azurerm_storage_account" "this" {
  name                = lower(module.st_name.name)
  resource_group_name = data.azurerm_resource_group.this.name
  location            = module.st_name.location

  account_tier             = var.account_kind == "FileStorage" ? "Premium" : split("_", var.sku)[0]
  account_replication_type = var.account_kind == "FileStorage" ? "LRS" : split("_", var.sku)[1]
  account_kind             = var.account_kind
  access_tier              = var.access_tier
  large_file_share_enabled = var.large_file_share_enabled
  nfsv3_enabled            = var.nfsv3_enabled

  allow_nested_items_to_be_public = false    #Disable anonymous public read access to containers and blobs
  enable_https_traffic_only       = true     #Require secure transfer (HTTPS) to the storage account for REST API Operations
  min_tls_version                 = "TLS1_2" #Configure the minimum required version of Transport Layer Security (TLS) for a storage account and require TLS Version1.2

  blob_properties {
    delete_retention_policy {
      days = var.is_log_storage == true ? 365 : 7
    }
    container_delete_retention_policy {
      days = var.is_log_storage == true ? 365 : 7
    }
    versioning_enabled  = true
    change_feed_enabled = true
  }

  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      # CMK is enabled later by azurerm_storage_account_customer_managed_key but the state of the storage account seen by TF here is not updated
      # This ignore_change fixes it.
      # Other solution: `terraform apply -refresh-only` (but not possible with TFC/TFE)
      customer_managed_key,
    ]
  }
}

#---------------------------------------------------------
# - Store Storage Account Access Key to Key Vault Secrets
#---------------------------------------------------------
# PR-033, PR-034 Data Protection: Protect data in Storage account using Customer-managed keys in associated Key-Vault or Managed HSM.
resource "azurerm_key_vault_secret" "this" {
  count = var.persist_access_key == true ? 1 : 0

  name         = "${azurerm_storage_account.this.name}-access-key"
  value        = azurerm_storage_account.this.primary_access_key
  key_vault_id = data.azurerm_key_vault.this.0.id

  depends_on = [module.st_id_rbac]
}


################################  CMK and Encryption  ################################
#-------------------------------------------------------------------------------------------------
# - Assigning Key Vault Crypto Service Encryption User to system assigned identity using role-assignment module
#-------------------------------------------------------------------------------------------------
module "st_id_rbac" {
  # Terraform Cloud/Enterprise use
  source  = "app.terraform.io/embergertf/role-assignment/azurerm"
  version = "~>1.0.0"

  count = var.cmk_enabled == true ? 1 : 0

  scope                = data.azurerm_key_vault.this.0.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.this.identity.0.principal_id
  description          = "Assigning the `Key Vault Crypto Service Encryption User` role to the service identity to allow its access to the key vault keys."
}

#--------------------------------------
# - Create CMK Key for storage account
#--------------------------------------
resource "azurerm_key_vault_key" "this" {
  count = var.cmk_enabled == true ? 1 : 0

  name         = format("%s-key", azurerm_storage_account.this.name)
  key_vault_id = data.azurerm_key_vault.this.0.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt", "encrypt", "sign",
    "unwrapKey", "verify", "wrapKey"
  ]

  depends_on = [azurerm_storage_account.this, module.st_id_rbac]
}

#--------------------------------------------------------------
# - Assigning CMK with the key in Key vault to storage account
#--------------------------------------------------------------
resource "azurerm_storage_account_customer_managed_key" "this" {
  count = var.cmk_enabled == true ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = data.azurerm_key_vault.this.0.id
  key_name           = azurerm_key_vault_key.this.0.name
  key_version        = azurerm_key_vault_key.this.0.version
}

################################  Store data in Storage Account  ################################
#------------------------------
# - Containers
#------------------------------
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                 = lower(each.value["name"])
  storage_account_name = azurerm_storage_account.this.name

  container_access_type = "private"
}

#-----------------------------------
# - Container Blobs
#-----------------------------------
resource "azurerm_storage_blob" "this" {
  for_each = local.blobs

  name                   = each.value["name"]
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = each.value["storage_container_name"]
  type                   = each.value["type"]
  size                   = lookup(each.value, "size", null)
  content_type           = lookup(each.value, "content_type", null)
  source_uri             = lookup(each.value, "source_uri", null)
  metadata               = lookup(each.value, "metadata", null)
  parallelism            = lookup(each.value, "parallelism", 8)

  depends_on = [
    azurerm_storage_container.this
  ]
}

#--------------------------
# - Queues
#--------------------------
resource "azurerm_storage_queue" "this" {
  for_each = var.queues

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.this.name
  metadata             = lookup(each.value, "metadata", null)
}

#-------------------------------
# - File Shares
#-------------------------------
resource "azurerm_storage_share" "this" {
  for_each = var.file_shares

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.this.name
  quota                = coalesce(lookup(each.value, "quota"), 110)
  enabled_protocol     = lookup(each.value, "enabled_protocol", "SMB")
  metadata             = lookup(each.value, "metadata", null)
  access_tier          = lookup(each.value, "access_tier", "TransactionOptimized") #default = TransactionOptimized. Other= Hot, Cool
}

#--------------------------
# - Tables
#--------------------------
resource "azurerm_storage_table" "this" {
  for_each = var.tables

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.this.name
}


################################  Lock Storage Account Networking  ################################
#------------------------------------
# - Storage Account Networking rules
#------------------------------------
resource "azurerm_storage_account_network_rules" "this" {
  # Prevents locking the Storage Account before all resources are created
  depends_on = [
    azurerm_storage_table.this,
    azurerm_storage_share.this,
    azurerm_storage_queue.this,
    azurerm_storage_blob.this,
    azurerm_storage_container.this
  ]

  storage_account_id         = azurerm_storage_account.this.id
  default_action             = local.network_rules.default_action
  ip_rules                   = local.network_rules.ip_rules
  virtual_network_subnet_ids = local.network_rules.virtual_network_subnet_ids
  bypass                     = local.network_rules.bypass
}
