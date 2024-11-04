# Storage Account module

## Overview

This Terraform module creates a Storage account in Azure.
An Azure storage account contains all the Azure Storage data objects: blobs, file shares, queues, tables, and disks.
The storage account provides a unique namespace for Azure Storage data that's accessible from anywhere in the world over HTTPS.
Data in a storage account is durable, highly available, secure, and massively scalable.

## Notes

- Changing the `account_kind` value from `Storage` to `StorageV2` will not trigger a force new on the storage account, it will only upgrade the existing storage account from `Storage` to `StorageV2` keeping the existing storage account in place.
- Blobs with a tier of `Premium` are of account kind `StorageV2`.
- `queue_properties` cannot be set when the `account_kind` is set to `BlobStorage`,
- To use `customer managed key` encryption, set variable `cmk_enabled` to `true`,
- To store storage account `access key` in `key vault` set variable `persist_access_key` to `true`.

## Example

```yaml
module "st" {
  # Terraform Cloud PMR use
  source  = "app.terraform.io/embergertf/storage-account/azurerm"
  version = "~> 1.0"

  # Naming convention (from RG module)
  naming_values = var.naming_values

  # Storage settings
  resource_group_name = module.tfc_rg.resource_group_name
  assign_identity     = true

  containers = var.test_containers
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = [module.publicip.public_ip]
    virtual_network_subnet_ids = []
    bypass                     = ["None"]
  }
}
```
