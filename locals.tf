#
# Copyright 2024 Emmanuel Bergerat
#

#--------------------------------------------------------------
#   Plan's Locals
#--------------------------------------------------------------
locals {
  # Prepare for other sourcing logic of the Key vault ID
  key_vault_id = var.key_vault_id

  # Define the default open/Allow network rule
  enabled_for_all_network = {
    bypass                     = ["None"]
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
  # If the default action in the variable provided is "Allow", then we will enable the storage account for all networks
  network_rules = var.network_rules.default_action == "Allow" ? local.enabled_for_all_network : var.network_rules

  blobs = {
    for blob in var.blobs : blob.name => merge(
      {
        type         = "Block"
        size         = 0
        content_type = "application/octet-stream"
        source_file  = null
        source_uri   = null
        metadata     = {}
      },
    blob)
  }
}
