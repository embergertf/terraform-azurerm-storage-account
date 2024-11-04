#
# Copyright 2024 Emmanuel Bergerat
#

# Storage Account resources
output "name" {
  value       = azurerm_storage_account.this.name
  description = "The generated name of the Storage Account."
}
output "id" {
  value       = azurerm_storage_account.this.id
  description = "The generated ID of the Storage Account."
}
output "tags" {
  value       = azurerm_storage_account.this.tags
  description = "Storage Account tags."
}
output "primary_blob_endpoint" {
  value       = azurerm_storage_account.this.primary_blob_endpoint
  description = "The primary Blob endpoint."
  sensitive   = true
}
output "primary_connection_string" {
  value       = azurerm_storage_account.this.primary_connection_string
  description = "The Storage Account primary connection string."
  sensitive   = true
}
output "primary_access_key" {
  value       = azurerm_storage_account.this.primary_access_key
  description = "The Primary access key of the Storage Account."
  sensitive   = true
}

output "container_ids" {
  value       = [for c in azurerm_storage_container.this : c.id]
  description = "The generated IDs for the Containers."
}
output "blob_ids" {
  value       = [for b in azurerm_storage_blob.this : b.id]
  description = "The generated IDs for the Blobs."
}
output "blob_urls" {
  value       = [for b in azurerm_storage_blob.this : b.url]
  description = "The generated URLs of the Blobs."
}
output "file_share_ids" {
  value       = [for s in azurerm_storage_share.this : s.id]
  description = "The generated IDs of the File shares."
}
output "file_share_urls" {
  value       = [for s in azurerm_storage_share.this : s.url]
  description = "The generated URLs of the File shares."
}
output "random_suffix" {
  value       = module.st_name.random_suffix
  description = "Randomized piece of the storage account name when \"`add_random = true`\"."
}

/*
#
# DEBUG
#-------------------
output "name" {
  value       = module.st_name.name
  description = "Storage Account name."
}
output "location" {
  value       = module.st_name.location
  description = "Storage Account location."
}
output "random_suffix" {
  value       = module.st_name.random_suffix
  description = "Randomized piece of the Storage Account name when \"`add_random = true`\"."
}
#*/
