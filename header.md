# Storage Account Module

## Overview

This Terraform module creates a Storage account in Azure.
An Azure storage account contains all the Azure Storage data objects: blobs, file shares, queues, tables, and disks.
The storage account provides a unique namespace for Azure Storage data that's accessible from anywhere in the world over HTTPS.
Data in a storage account is durable, highly available, secure, and massively scalable.

## Notes

- Changing the `account_kind` value from `Storage` to `StorageV2` will not trigger a force new on the storage account, it will only upgrade the existing storage account from `Storage` to `StorageV2` keeping the existing storage account in place.
- Blobs with a tier of `Premium` are of account kind `StorageV2`.
- `queue_properties` cannot be set when the `account_kind` is set to `BlobStorage`,
- To use `customer managed key` encryption, set variable `cmk_enabled` to true,
- To store storage account `access key` in `key vault` set variable `persist_access_key` to `true`.

## Example

```yaml
#------------------------------------------
#  - Creating 1st storage account in RG #1
#------------------------------------------
module "wf_st1" {
  # Local use
  source = "../../terraform-azurerm-wf-storage"

  # Terraform Cloud/Enterprise use
  #source  = "app.terraform.io/msftwfdeo/wf-storage/azurerm"
  #version = "~>2.0.0"

  depends_on = [
    module.wf_rg
  ]

  # Storage Account naming
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

  # Storage Account settings
  resource_group_name = module.wf_rg.name
  key_vault_id        = module.wf_kv.id

  is_log_storage      = false
  persist_access_key  = true
  assign_identity     = true
  cmk_enabled         = true

  containers          = var.st1_containers
  blobs               = var.st1_blobs
  queues              = var.st1_queues
  file_shares         = var.st1_file_shares
  tables              = var.st1_tables

  network_rules       = local.st_network_acls
}
```
