#
# Copyright 2024 Emmanuel Bergerat
#

# Created  on:  Oct.31st, 2024
# Created  by:  Emmanuel
# Modified on:  
# Modified by:  
# Modification: 
# Overview:
#   This module:
#   - Creates an Azure Storage Account
#   - Creates Networking rules for the Storage Account
#   - Creates Blob containers in the Storage Account


#--------------------------------------------------------------
#   Plan's modules
#--------------------------------------------------------------
# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules
module "st_name" {
  # Terraform Cloud PMR use
  source  = "app.terraform.io/embergertf/base/azurerm"
  version = "~> 4.0"

  # Naming
  name_override = var.name_override
  naming_values = var.naming_values

  region_code     = var.region_code
  subsc_code      = var.subsc_code
  env             = var.env
  base_name       = var.base_name
  additional_name = var.additional_name
  iterator        = var.iterator
  owner           = var.owner
  additional_tags = var.additional_tags

  # Random
  add_random = var.add_random
  rnd_length = var.rnd_length

  # Storage Account specific settings
  resource_type_code = "st"
  max_length         = 24   # Min 3, Max 24
  no_dashes          = true # Lowercase letters and numbers.
}

#--------------------------------------------------------------
#   Storage Account
#--------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                = lower(module.st_name.name)
  location            = module.st_name.location
  resource_group_name = var.resource_group_name

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  large_file_share_enabled        = var.large_file_share_enabled
  nfsv3_enabled                   = var.nfsv3_enabled
  local_user_enabled              = false
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false    # Disable anonymous public read access to containers and blobs
  https_traffic_only_enabled      = true     # Require secure transfer (HTTPS) to the storage account for REST API Operations
  min_tls_version                 = "TLS1_2" # Configure the minimum required version of Transport Layer Security (TLS) for a storage account and require TLS Version1.2

  blob_properties {
    delete_retention_policy {
      days                     = var.is_log_storage == true ? 365 : var.blobs_retention_policy
      permanent_delete_enabled = false
    }
    container_delete_retention_policy {
      days = var.is_log_storage == true ? 365 : var.blobs_retention_policy
    }
    versioning_enabled  = var.blobs_versioning_enabled
    change_feed_enabled = var.blobs_change_feed_enabled
  }

  share_properties {
    retention_policy {
      days = var.blobs_retention_policy
    }
  }

  queue_properties {
    hour_metrics {
      enabled               = true
      version               = "1.0"
      retention_policy_days = var.blobs_retention_policy
    }
  }

  dynamic "identity" {
    for_each = (var.assign_identity == true) || (var.persist_access_key == true) ? tolist(["SystemIdentity"]) : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = module.st_name.tags

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
# - if (persist_access_key) store Storage Account Access Key in a Key vault Secret
#---------------------------------------------------------
resource "azurerm_key_vault_secret" "this" {
  depends_on = [module.st_on_kv_ra]

  count = var.persist_access_key == true ? 1 : 0

  name         = "${azurerm_storage_account.this.name}-access-key"
  value        = azurerm_storage_account.this.primary_access_key
  key_vault_id = local.key_vault_id

  tags = module.st_name.tags
}

################################  CMK and Encryption  ################################
#-------------------------------------------------------------------------------------------------
# - if (cmk_enabled) assign "Key vault Crypto Service Encryption User" role to Storage account system assigned on Key vault
#-------------------------------------------------------------------------------------------------
module "st_on_kv_ra" {
  source  = "app.terraform.io/embergertf/role-assignment/azurerm"
  version = "~> 1.0"

  count = var.cmk_enabled == true ? 1 : 0

  principal_id         = azurerm_storage_account.this.identity.0.principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = local.key_vault_id
}

#--------------------------------------
# - if (cmk_enabled) create CMK Key for storage account
#--------------------------------------
# Data Protection: Protect data in Storage account using Customer-managed keys in associated Key-Vault or Managed HSM.
resource "azurerm_key_vault_key" "this" {
  depends_on = [azurerm_storage_account.this, module.st_on_kv_ra]

  count = var.cmk_enabled == true ? 1 : 0

  name         = format("%s-key", azurerm_storage_account.this.name)
  key_vault_id = local.key_vault_id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt", "encrypt", "sign",
    "unwrapKey", "verify", "wrapKey"
  ]

  tags = module.st_name.tags
}

#--------------------------------------------------------------
# - if (cmk_enabled) assign CMK with the key in Key vault to storage account
#--------------------------------------------------------------
resource "azurerm_storage_account_customer_managed_key" "this" {
  count = var.cmk_enabled == true ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = local.key_vault_id
  key_name           = azurerm_key_vault_key.this.0.name
  key_version        = azurerm_key_vault_key.this.0.version
}

################################  Store data in Storage Account  ################################
#------------------------------
# - Containers
#------------------------------
# PR-112 Inventory: Blob storage has an inventory capability 
resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.this.name

  # Infrastructure Protection: Block Internet access and restrict network connectivity to the Storage account via the Storage firewall and access the data objects in the Storage account via Private Endpoint which secures all traffic between VNet and the storage account over a Private Link.
  container_access_type = "private"
}

#-----------------------------------
# - Container Blobs
#-----------------------------------
resource "azurerm_storage_blob" "this" {
  depends_on = [azurerm_storage_container.this]

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
}

#--------------------------
# - Queues
#--------------------------
resource "azurerm_storage_queue" "this" {
  depends_on = [azurerm_storage_container.this]

  for_each = var.queues

  name                 = each.value["name"]
  storage_account_name = azurerm_storage_account.this.name
  metadata             = lookup(each.value, "metadata", null)
}

#-------------------------------
# - File Shares
#-------------------------------
resource "azurerm_storage_share" "this" {
  depends_on = [azurerm_storage_container.this]

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
  depends_on = [azurerm_storage_container.this]

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

  dynamic "private_link_access" {
    for_each = var.private_link_accesses != null ? var.private_link_accesses : {}
    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
    }
  }
}

