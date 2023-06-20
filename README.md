<!-- BEGIN_TF_DOCS -->
# Storage Module

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

This module implements the Azure Wells Fargo Design Decisions known as of Mar. 14th, 2022.
The SED work in progress may incur refactoring of this module later to match updated Design Decisions.

## Security Controls

- PR-030, PR-031 Conventions: Name resources accordingly
- PR-036, PR-037, PR-038 Data Protection: Azure Storage encryption is enabled for all storage accounts by default. Data in Azure Storage is encrypted and decrypted transparently using AES encryption and is FIPS 140-2 compliant. By requiring secure transfer for the storage account, all requests to the storage account must be made over HTTPS. Any requests made over HTTP are rejected.
- PR-038, PR-150, PR-040 Encryption in transit: Blob storage supports TLS 1.2 and provides encryption for data in Transit
- PR-033, PR-034 Data Protection: Protect data in Storage account using Customer-managed keys in associated Key-Vault or Managed HSM.
- PR-051, PR-052, PR-054 Infrastructure Protection: Block Internet access and restrict network connectivity to the Storage account via the Storage firewall and access the data objects in the Storage account via Private Endpoint which secures all traffic between VNet and the storage account over a Private Link.
- PR-112 Inventory: Blob storage has an inventory capability

## Security Decisions

- ID 4206 RAID 4206: SEC-26: Azure Blob Storage Will Use Microsoft-Managed Keys in MVP 1.0: Terraform code has the capability to use both Microsoft Managed Key (MMK) and Customer Managed Key (CMK)
- ID 4207 RAID 4207: SEC-27: Azure Blob Storage Will Use Immutable Storage Policies for Platform Logs: Terraform does not support immutable storage account as of now
- ID 4208 SEC-28: Azure Blob Storage Security Settings: Error in terraform code for while using Azure Active Directory (Azure AD) to authorize access to blob data and Disallowing Shared Key authorization - use Azure AD for authorization, SAS where required
- ID 4209 SEC-29: Azure Blob Storage Data Protection Settings: available in storage module
- ID 4210 SEC-30: Azure Blob Storage Logging/Monitoring: will be enabled using Terraform Diagnostic Logs module
- ID 4242 RAID 4242: SEC-34: Azure Storage Accounts Will Use Private Endpoints: will be enabled using Terraform Private Endpoints module

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

## Documentation
<!-- markdownlint-disable MD033 -->

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_wf_rbac"></a> [wf\_rbac](#module\_wf\_rbac) | app.terraform.io/msftwfdeo/wf-role-assignment/azurerm | ~>1.0.1 |
| <a name="module_wf_st_name"></a> [wf\_st\_name](#module\_wf\_st\_name) | app.terraform.io/msftwfdeo/wf-module/azurerm | ~>1.0.2 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_au"></a> [au](#input\_au) | (Required) Wells Fargo Accounting Unit (AU) code. Example: `0233985`. <br></br>&#8226; Value of `au` must be of numeric characters. | `string` | n/a | yes |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | (Required) Application/Infrastructure "base" name. Example: `aks` | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | (Required) Wells Fargo environment code. Example: `test`. <br></br>&#8226; Value of `env` must be one of: `[nonprod,prod,core,int,uat,stage,dev,test]`. | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | (Required) ID of the existing Key vault to store the Customer Managed Key for Encryption. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | (Required) Wells Fargo technology owner group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the `Resource Group` in which to create the storage account. | `string` | n/a | yes |
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | (Optional) Defines the Access Tier for the Storage Account.<br></br>&#8226; Possible values are: `Cool`, `Hot`. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | (Optional) Defines the Kind of Storage Account.<br></br>&#8226; Possible values are: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. | `string` | `"StorageV2"` | no |
| <a name="input_add_random"></a> [add\_random](#input\_add\_random) | (Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end. | `bool` | `false` | no |
| <a name="input_additional_name"></a> [additional\_name](#input\_additional\_name) | (Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the "name's generated" suffix. Example: `lan1`. | `string` | `null` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | (Optional) Additional tags for the storage account. | `map(string)` | `null` | no |
| <a name="input_assign_identity"></a> [assign\_identity](#input\_assign\_identity) | (Optional) Set to `true`, the Storage Account will be assigned an identity. | `bool` | `false` | no |
| <a name="input_blobs"></a> [blobs](#input\_blobs) | (Optional) Map of the Storage Blobs in the Containers.<br></br><ul><li>`name`: (Required) The name of the storage blob. Must be unique within the storage container the blob is located, </li><li>`storage_container_name`: (Required) The name of the storage container in which this blob should be created, </li><li>`type`: (Required) The type of the storage blob to be created. Possible values are `Append`, `Block` or `Page`, </li><li>`size`: (Optional) Used only for page blobs to specify the size in bytes of the blob to be created. Must be a multiple of 512, </li><li>`content_type`: (Optional) The content type of the `storage blob`. Cannot be defined if `source_uri` is defined, </li><li>`parallelism`: (Optional) The number of workers per CPU core to run for concurrent uploads, </li><li>`source_uri`: (Optional) The URI of an existing blob, or a file in the Azure File service, to use as the source contents for the blob to be created, </li><li>`metadata`: (Optional) A map of custom blob metadata. | <pre>map(object({<br>    name                   = string<br>    storage_container_name = string<br>    type                   = string<br>    size                   = number<br>    content_type           = string<br>    parallelism            = number<br>    source_uri             = string<br>    metadata               = map(any)<br>  }))</pre> | `{}` | no |
| <a name="input_cmk_enabled"></a> [cmk\_enabled](#input\_cmk\_enabled) | (Optional) Set `true` to enable Storage encryption with `Customer-managed key`. Variable `assign_identity` needs to be set `true` to set `cmk_enabled` true. | `bool` | `false` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | (Optional) Map of the Containers in the Storage Account.<br></br><ul><li>`name`: (Required) The name of the Container which should be created within the Storage Account. | <pre>map(object({<br>    name = string<br>  }))</pre> | `{}` | no |
| <a name="input_country"></a> [country](#input\_country) | (Optional) Wells Fargo country code. Example: `us`. | `string` | `"us"` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | (Optional) Map of the Storage File Shares.<br></br><ul><li>`name`: (Required) The name of the share. Must be unique within the storage account where the share is located, </li><li>`quota`: (Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be greater than 0 and less than 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and less than 102400 GB (100 TB), </li><li>`enabled_protocol`: (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`, </li><li>`metadata`: (Optional) A mapping of MetaData for this File Share. | <pre>map(object({<br>    name             = string<br>    quota            = number<br>    enabled_protocol = string<br>    metadata         = map(any)<br>  }))</pre> | `{}` | no |
| <a name="input_is_log_storage"></a> [is\_log\_storage](#input\_is\_log\_storage) | Set to `true`, if the `storage account` created to store `platform logs`. | `bool` | `false` | no |
| <a name="input_iterator"></a> [iterator](#input\_iterator) | (Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the "name's generated + additional\_name" concatenation. Example: `001`. | `string` | `null` | no |
| <a name="input_large_file_share_enabled"></a> [large\_file\_share\_enabled](#input\_large\_file\_share\_enabled) | (Optional) Set to `true`, the Storage Account will be enabled for large file shares. | `bool` | `false` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | (Optional) Networking settings for the Storage Account:<br></br><ul><li>`default_action`: (Required) The Default Action to use when no rules match ip\_rules / virtual\_network\_subnet\_ids. Possible values are `"Allow"` and `"Deny"`,</li><li>`bypass`: (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of [`"Logging"`, `"Metrics"`, `"AzureServices"`, `"None"`],</li><li>`ip_rules`: (Optional) One or more <b>Public IP Addresses or CIDR Blocks</b> which should be able to access the Storage Account,</li><li>`virtual_network_subnet_ids`: (Optional) One or more Subnet IDs which should be able to access the Storage Account.</li></ul> | <pre>object({<br>    default_action             = string<br>    bypass                     = list(string)<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | <pre>{<br>  "bypass": [<br>    "None"<br>  ],<br>  "default_action": "Deny",<br>  "ip_rules": [],<br>  "virtual_network_subnet_ids": []<br>}</pre> | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Set to `true`, the `NFSV3` protocol will be enabled. | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | (Optional) Wells Fargo organization code. Example: `wf`. | `string` | `"wf"` | no |
| <a name="input_persist_access_key"></a> [persist\_access\_key](#input\_persist\_access\_key) | (Optional) Set `true` to store storage access key in `key vault`. | `bool` | `false` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | (Optional) Map of the Storage Queues.<br></br><ul><li>`name`: (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located, </li><li>`metadata`: (Optional) A mapping of MetaData which should be assigned to this Storage Queue. | <pre>map(object({<br>    name     = string<br>    metadata = map(any)<br>  }))</pre> | `{}` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | (Optional) Wells Fargo region code.<br></br>&#8226; Value of `region_code` must be one of: `[ncus,scus]`. | `string` | `"ncus"` | no |
| <a name="input_rnd_length"></a> [rnd\_length](#input\_rnd\_length) | (Optional) Set the length of the `random_number` generated. | `number` | `2` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) `sku` is the combination of the `account_tier` and the `account_replication_type`. For example: for an `account_tier = Standard` and an `account_replication_type = LRS`, the value should be `Standard_LRS`. | `string` | `"Standard_GRS"` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | (Optional) Map of the Storage Tables.<br></br><ul><li>`name`: (Required) The name of the storage table. Must be unique within the storage account the table is located. | <pre>map(object({<br>    name = string<br>  }))</pre> | `{}` | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_customer_managed_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_blob.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_ids"></a> [blob\_ids](#output\_blob\_ids) | The generated IDs for the Blobs. |
| <a name="output_blob_urls"></a> [blob\_urls](#output\_blob\_urls) | The generated URLs of the Blobs. |
| <a name="output_container_ids"></a> [container\_ids](#output\_container\_ids) | The generated IDs for the Containers. |
| <a name="output_file_share_ids"></a> [file\_share\_ids](#output\_file\_share\_ids) | The generated IDs of the File shares. |
| <a name="output_file_share_urls"></a> [file\_share\_urls](#output\_file\_share\_urls) | The generated URLs of the File shares. |
| <a name="output_id"></a> [id](#output\_id) | The generated ID of the Storage Account. |
| <a name="output_name"></a> [name](#output\_name) | The generated name of the Storage Account. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The Primary access key of the Storage Account. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary Blob endpoint. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The Storage Account primary connection string. |
| <a name="output_random_suffix"></a> [random\_suffix](#output\_random\_suffix) | Randomized piece of the storage account name when "`add_random = true`". |

<!-- END_TF_DOCS -->