#
# Copyright 2024 Emmanuel Bergerat
#

# ############################   #{MODULEDISPLAYNAME}#   ############################



# ############################   Debug                ############################
output "name" {
  value       = module.st_acct_module_localtest.name
  description = "#{MODULEDISPLAYNAME}# name."
}
output "location" {
  value       = module.st_acct_module_localtest.location
  description = "#{MODULEDISPLAYNAME}# location."
}
output "random_suffix" {
  value       = module.st_acct_module_localtest.random_suffix
  description = "Randomized piece of the #{MODULEDISPLAYNAME}# name when \"`add_random = true`\"."
}
output "rg_tags" {
  value       = module.tfc_rg.tags
  description = "Resource Group tags."
}
output "st_acct_tags" {
  value       = module.st_acct_module_localtest.tags
  description = "Storage Account tags."
}
#*/
