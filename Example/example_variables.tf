#
# Copyright 2023 - Emmanuel Bergerat
#


# -
# - Storage account variables
# -
variable "name_override" { default = null }
variable "region_code" { default = null }
variable "subsc_code" { default = null }
variable "env" { default = null }
variable "base_name" { default = null }
variable "additional_name" { default = null }
variable "iterator" { default = null }
variable "owner" { default = null }
variable "add_random" { default = null }
variable "rnd_length" { default = null }
variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

# -
# - Test network ACLs
# -
variable "ca_ip_prefixes" { default = [] }
variable "in_ip_prefixes" { default = [] }
variable "us_ip_prefixes" { default = [] }

# -
# - Storage account variables
# -
variable "st1_containers" { default = {} }
variable "st1_blobs" { default = {} }
variable "st1_queues" { default = {} }
variable "st1_file_shares" { default = {} }
variable "st1_tables" { default = {} }
variable "st1_is_log_storage" { default = null }
variable "st1_assign_identity" { default = null }
