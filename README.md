<!-- BEGIN_TF_DOCS -->
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

## Documentation
<!-- markdownlint-disable MD033 -->

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.7 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_st_name"></a> [st\_name](#module\_st\_name) | app.terraform.io/embergertf/base/azurerm | ~> 4.0 |
| <a name="module_st_on_kv_ra"></a> [st\_on\_kv\_ra](#module\_st\_on\_kv\_ra) | app.terraform.io/embergertf/role-assignment/azurerm | ~> 1.0 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the `Resource Group` in which to create the storage account. | `string` | n/a | yes |
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | (Optional) Defines the Access Tier for the Storage Account.<br></br>&#8226; Possible values are: `Cool`, `Hot`. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | (Optional) Defines the Kind of Storage Account.<br></br>&#8226; Possible values are: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | (Optional) The `account_replication_type`. | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | (Optional) The `account_tier`. | `string` | `"Standard"` | no |
| <a name="input_add_random"></a> [add\_random](#input\_add\_random) | (Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end. | `bool` | `false` | no |
| <a name="input_additional_name"></a> [additional\_name](#input\_additional\_name) | (Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the "name's generated" suffix. Example: `lan1`. | `string` | `null` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | (Optional) Additional tags for the Resource Group. | `map(string)` | `null` | no |
| <a name="input_allowed_public_ip_addresses"></a> [allowed\_public\_ip\_addresses](#input\_allowed\_public\_ip\_addresses) | List of public IP addresses that are allowed to access the storage account. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnet_id_s"></a> [allowed\_subnet\_id\_s](#input\_allowed\_subnet\_id\_s) | List of subnet IDs that are allowed to access the storage account. | `list(string)` | `[]` | no |
| <a name="input_assign_identity"></a> [assign\_identity](#input\_assign\_identity) | (Optional) Set to `true`, the Storage Account will be assigned an identity. | `bool` | `false` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | (Optional) Resource "base" name. Example: `aks`. | `string` | `null` | no |
| <a name="input_blobs"></a> [blobs](#input\_blobs) | (Optional) Map of the Storage Blobs in the Containers.<br></br><ul><li>`name`: (Required) The name of the storage blob. Must be unique within the storage container the blob is located, </li><li>`storage_container_name`: (Required) The name of the storage container in which this blob should be created, </li><li>`type`: (Required) The type of the storage blob to be created. Possible values are `Append`, `Block` or `Page`, </li><li>`size`: (Optional) Used only for page blobs to specify the size in bytes of the blob to be created. Must be a multiple of 512, </li><li>`content_type`: (Optional) The content type of the `storage blob`. Cannot be defined if `source_uri` is defined, </li><li>`parallelism`: (Optional) The number of workers per CPU core to run for concurrent uploads, </li><li>`source_uri`: (Optional) The URI of an existing blob, or a file in the Azure File service, to use as the source contents for the blob to be created, </li><li>`metadata`: (Optional) A map of custom blob metadata. | <pre>map(object({<br>    name                   = string<br>    storage_container_name = string<br>    type                   = string<br>    size                   = number<br>    content_type           = string<br>    parallelism            = number<br>    source_uri             = string<br>    metadata               = map(any)<br>  }))</pre> | `{}` | no |
| <a name="input_cmk_enabled"></a> [cmk\_enabled](#input\_cmk\_enabled) | (Optional) Set `true` to enable Storage encryption with `Customer-managed key`. Variable `assign_identity` needs to be set `true` to set `cmk_enabled` true. | `bool` | `false` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | (Optional) Map of the Containers in the Storage Account.<br></br><ul><li>`name`: (Required) The name of the Container which should be created within the Storage Account. | <pre>map(object({<br>    name = string<br>  }))</pre> | `{}` | no |
| <a name="input_env"></a> [env](#input\_env) | (Optional) Environment code. Example: `test`. <br></br>&#8226; Value of `env` examples can be: `[nonprod,prod,core,int,uat,stage,dev,test]`. | `string` | `null` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | (Optional) Map of the Storage File Shares.<br></br><ul><li>`name`: (Required) The name of the share. Must be unique within the storage account where the share is located, </li><li>`quota`: (Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be greater than 0 and less than 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and less than 102400 GB (100 TB), </li><li>`enabled_protocol`: (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`, </li><li>`metadata`: (Optional) A mapping of MetaData for this File Share. | <pre>map(object({<br>    name             = string<br>    quota            = number<br>    enabled_protocol = string<br>    metadata         = map(any)<br>    access_tier      = string<br>  }))</pre> | `{}` | no |
| <a name="input_is_log_storage"></a> [is\_log\_storage](#input\_is\_log\_storage) | Set to `true`, if the `storage account` created to store `platform logs`. | `bool` | `false` | no |
| <a name="input_iterator"></a> [iterator](#input\_iterator) | (Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the "name's generated + additional\_name" concatenation. Example: `001`. | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | (Required) ID of the existing Key vault to store the Customer Managed Key for Encryption. | `string` | `null` | no |
| <a name="input_large_file_share_enabled"></a> [large\_file\_share\_enabled](#input\_large\_file\_share\_enabled) | (Optional) Set to `true`, the Storage Account will be enabled for large file shares. | `bool` | `false` | no |
| <a name="input_name_override"></a> [name\_override](#input\_name\_override) | (Optional) Full name to override all the name generation logic. Example: 'biglittletest' will generate the resource group name "'rg-biglittletest'". | `string` | `null` | no |
| <a name="input_naming_values"></a> [naming\_values](#input\_naming\_values) | (Optional) A terraform object with the naming values in 1 variable. | <pre>object({<br>    region_code     = string<br>    subsc_code      = string<br>    env             = string<br>    base_name       = string<br>    additional_name = string<br>    iterator        = string<br>    owner           = string<br>    additional_tags = map(string)<br>  })</pre> | `null` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | (Optional) Networking settings for the Storage Account:<br></br><ul><li>`default_action`: (Required) The Default Action to use when no rules match ip\_rules / virtual\_network\_subnet\_ids. Possible values are `"Allow"` and `"Deny"`,</li><li>`bypass`: (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of [`"Logging"`, `"Metrics"`, `"AzureServices"`, `"None"`],</li><li>`ip_rules`: (Optional) One or more <b>Public IP Addresses or CIDR Blocks</b> which should be able to access the Storage Account,</li><li>`virtual_network_subnet_ids`: (Optional) One or more Subnet IDs which should be able to access the Storage Account.</li></ul> | <pre>object({<br>    default_action             = string<br>    bypass                     = list(string)<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | <pre>{<br>  "bypass": [<br>    "None"<br>  ],<br>  "default_action": "Deny",<br>  "ip_rules": [],<br>  "virtual_network_subnet_ids": []<br>}</pre> | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Set to `true`, the `NFSV3` protocol will be enabled. | `bool` | `false` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | (Optional) Deployed resources owner. | `string` | `null` | no |
| <a name="input_persist_access_key"></a> [persist\_access\_key](#input\_persist\_access\_key) | (Optional) Set `true` to store storage access key in `key vault`. | `bool` | `false` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | (Optional) Map of the Storage Queues.<br></br><ul><li>`name`: (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located, </li><li>`metadata`: (Optional) A mapping of MetaData which should be assigned to this Storage Queue. | <pre>map(object({<br>    name     = string<br>    metadata = map(any)<br>  }))</pre> | `{}` | no |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | (Optional) Resource region code. Must be compatible with base module. Example: `cac`. | `string` | `null` | no |
| <a name="input_rnd_length"></a> [rnd\_length](#input\_rnd\_length) | (Optional) Set the length of the `random_number` generated. | `number` | `2` | no |
| <a name="input_subsc_code"></a> [subsc\_code](#input\_subsc\_code) | (Optional) Subscription code or abbreviation. Example: `azint`. | `string` | `null` | no |
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
| <a name="output_tags"></a> [tags](#output\_tags) | Storage Account tags. |

<!-- END_TF_DOCS -->