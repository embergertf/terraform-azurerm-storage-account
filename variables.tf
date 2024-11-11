#
# Copyright 2024 Emmanuel Bergerat
#

# ############################   Dependencies   ############################
# / Resource Group for the Storage Account
variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the `Resource Group` in which to create the storage account."
}
variable "key_vault_id" {
  type        = string
  description = "(Required) ID of the existing Key vault to store the Customer Managed Key for Encryption."
  default     = null
}

# ############################   Required Variables   ############################

# None

# ############################   Optional Variables   ############################
# / Naming
variable "name_override" {
  type        = string
  description = "(Optional) Full name to override all the name generation logic. Example: 'biglittletest' will generate the resource group name \"'rg-biglittletest'\"."
  default     = null
}
variable "naming_values" {
  type = object({
    region_code     = string
    subsc_code      = string
    env             = string
    base_name       = string
    additional_name = string
    iterator        = string
    owner           = string
    additional_tags = map(string)
  })
  description = "(Optional) A terraform object with the naming values in 1 variable."
  default     = null
}
variable "region_code" {
  type        = string
  description = "(Optional) Resource region code. Must be compatible with base module. Example: `cac`."
  default     = null
}
variable "subsc_code" {
  type        = string
  description = "(Optional) Subscription code or abbreviation. Example: `azint`."
  default     = null
}
variable "env" {
  type        = string
  description = "(Optional) Environment code. Example: `test`. <br></br>&#8226; Value of `env` examples can be: `[nonprod,prod,core,int,uat,stage,dev,test]`."
  default     = null
}
variable "base_name" {
  type        = string
  description = "(Optional) Resource \"base\" name. Example: `aks`."
  default     = null
}
variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated\" suffix. Example: `lan1`."
  default     = null
}
variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated + additional_name\" concatenation. Example: `001`."
  default     = null
}
variable "owner" {
  type        = string
  description = "(Optional) Deployed resources owner."
  default     = null
}
variable "additional_tags" {
  description = "(Optional) Additional tags for the Storage Acount."
  type        = map(string)
  default     = null
}
variable "add_random" {
  type        = bool
  description = "(Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end."
  default     = false
}
variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the `random_number` generated."
  default     = 2
}

# / Storage Account
variable "account_tier" {
  type        = string
  description = "(Optional) The `account_tier`."
  default     = "Standard"
}
variable "account_replication_type" {
  type        = string
  description = "(Optional) The `account_replication_type`."
  default     = "LRS"
}
variable "account_kind" {
  type        = string
  description = "(Optional) Defines the Kind of Storage Account.<br></br>&#8226; Possible values are: `BlobStorage`, `BlockBlobStorage`, `FileStorage`, `Storage` and `StorageV2`."
  default     = "StorageV2"
}
variable "access_tier" {
  type        = string
  description = "(Optional) Defines the Access Tier for the Storage Account.<br></br>&#8226; Possible values are: `Cool`, `Hot`."
  default     = "Hot"
}
variable "assign_identity" {
  type        = bool
  description = "(Optional) Set to `true`, the Storage Account will be assigned an identity."
  default     = false
}
variable "large_file_share_enabled" {
  type        = bool
  description = "(Optional) Set to `true`, the Storage Account will be enabled for large file shares."
  default     = false
}
variable "nfsv3_enabled" {
  type        = bool
  description = "Set to `true`, the `NFSV3` protocol will be enabled."
  default     = false
}
variable "is_log_storage" {
  type        = bool
  description = "Set to `true`, if the `storage account` created to store `platform logs`."
  default     = false
}
variable "private_link_accesses" {
  description = "(Optional) Map of Private Link accesses to create."
  type = map(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = string
  }))
  default = {}
}

# / Storage Account Security
variable "network_rules" {
  description = "(Optional) Networking settings for the Storage Account:<br></br><ul><li>`default_action`: (Required) The Default Action to use when no rules match ip_rules / virtual_network_subnet_ids. Possible values are `\"Allow\"` and `\"Deny\"`,</li><li>`bypass`: (Optional) Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of [`\"Logging\"`, `\"Metrics\"`, `\"AzureServices\"`, `\"None\"`],</li><li>`ip_rules`: (Optional) One or more <b>Public IP Addresses or CIDR Blocks</b> which should be able to access the Storage Account,</li><li>`virtual_network_subnet_ids`: (Optional) One or more Subnet IDs which should be able to access the Storage Account.</li></ul>"
  type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = ["None"]
  }
}
variable "allowed_public_ip_addresses" {
  type        = list(string)
  description = "List of public IP addresses that are allowed to access the storage account."
  default     = []
}
variable "allowed_subnet_id_s" {
  type        = list(string)
  description = "List of subnet IDs that are allowed to access the storage account."
  default     = []
}
variable "cmk_enabled" {
  type        = bool
  description = "(Optional) Set `true` to enable Storage encryption with `Customer-managed key`. Variable `assign_identity` needs to be set `true` to set `cmk_enabled` true. "
  default     = false
}
variable "persist_access_key" {
  type        = bool
  description = "(Optional) Set `true` to store storage access key in `key vault`."
  default     = false
}

# / Resources within the Storage Account
variable "containers" {
  description = "(Optional) Map of the Containers in the Storage Account.<br></br><ul><li>`name`: (Required) The name of the Container which should be created within the Storage Account."
  type = map(object({
    name = string
  }))
  default = {}
}
variable "blobs_retention_policy" {
  description = "(Optional) The retention policy for the blobs within the Storage Account.<br></br><ul><li>`days`: (Required) The number of days that the blob should be retained within [1..365].</li></ul>"
  type        = number
  default     = 7
}
variable "blobs_versioning_enabled" {
  description = "(Optional) Is versioning enabled for the blobs within the Storage Account."
  type        = bool
  default     = false
}
variable "blobs_change_feed_enabled" {
  description = "(Optional) Is blob change feed enabled for the blobs within the Storage Account."
  type        = bool
  default     = false
}
variable "blobs" {
  description = "(Optional) Map of the Storage Blobs in the Containers.<br></br><ul><li>`name`: (Required) The name of the storage blob. Must be unique within the storage container the blob is located, </li><li>`storage_container_name`: (Required) The name of the storage container in which this blob should be created, </li><li>`type`: (Required) The type of the storage blob to be created. Possible values are `Append`, `Block` or `Page`, </li><li>`size`: (Optional) Used only for page blobs to specify the size in bytes of the blob to be created. Must be a multiple of 512, </li><li>`content_type`: (Optional) The content type of the `storage blob`. Cannot be defined if `source_uri` is defined, </li><li>`parallelism`: (Optional) The number of workers per CPU core to run for concurrent uploads, </li><li>`source_uri`: (Optional) The URI of an existing blob, or a file in the Azure File service, to use as the source contents for the blob to be created, </li><li>`metadata`: (Optional) A map of custom blob metadata."
  type = map(object({
    name                   = string
    storage_container_name = string
    type                   = string
    size                   = number
    content_type           = string
    parallelism            = number
    source_uri             = string
    metadata               = map(any)
  }))
  default = {}

  # "Storage Blob Data *" role assigned required to see blobs in Portal
}
variable "queues" {
  description = "(Optional) Map of the Storage Queues.<br></br><ul><li>`name`: (Required) The name of the Queue which should be created within the Storage Account. Must be unique within the storage account the queue is located, </li><li>`metadata`: (Optional) A mapping of MetaData which should be assigned to this Storage Queue."
  type = map(object({
    name     = string
    metadata = map(any)
  }))
  default = {}
}
variable "file_shares" {
  description = "(Optional) Map of the Storage File Shares.<br></br><ul><li>`name`: (Required) The name of the share. Must be unique within the storage account where the share is located, </li><li>`quota`: (Optional) The maximum size of the share, in gigabytes. For Standard storage accounts, this must be greater than 0 and less than 5120 GB (5 TB). For Premium FileStorage storage accounts, this must be greater than 100 GB and less than 102400 GB (100 TB), </li><li>`enabled_protocol`: (Optional) The protocol used for the share. Possible values are `SMB` and `NFS`, </li><li>`metadata`: (Optional) A mapping of MetaData for this File Share."
  type = map(object({
    name             = string
    quota            = number
    enabled_protocol = string
    metadata         = map(any)
    access_tier      = string
  }))
  default = {}
}
variable "tables" {
  description = "(Optional) Map of the Storage Tables.<br></br><ul><li>`name`: (Required) The name of the storage table. Must be unique within the storage account the table is located."
  type = map(object({
    name = string
  }))
  default = {}
}
