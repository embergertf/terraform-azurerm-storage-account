#
# Copyright 2023 - Emmanuel Bergerat
#

# Locals
locals {
  ip_prefixes_to_allow = concat(var.ca_ip_prefixes, var.in_ip_prefixes, var.us_ip_prefixes)

  kv_network_acls = {
    default_action             = "Deny"                     # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
    ip_rules                   = local.ip_prefixes_to_allow # (Optional) One or more Public IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
    virtual_network_subnet_ids = null                       # (Optional) One or more Subnet ID's which should be able to access this Key Vault.
    bypass                     = "AzureServices"            # (Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None.
  }
  st_network_acls = {
    default_action             = "Deny"                     # (Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny.
    ip_rules                   = local.ip_prefixes_to_allow # (Optional) One or more Public IP Addresses, or CIDR Blocks which should be able to access the Storage Account.
    virtual_network_subnet_ids = null                       # (Optional) One or more Subnet ID's which should be able to access this Storage Account.
    bypass                     = ["None"]                   # (Required) Specifies which traffic can bypass the network rules. Valid options are any combination of Logging, Metrics, AzureServices, or None.
  }
}
#*/