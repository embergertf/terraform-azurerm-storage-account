#
# Copyright 2023 - Emmanuel Bergerat
#

#-
#- RG values
#-
env             = "test"
base_name       = "stmodule"
owner           = "test@manu.dev"
additional_name = 37
iterator        = 037
additional_tags = {
  Test_by = "Manu"
}
region_code = "cac"

# -
# - Storage account
# -
st1_is_log_storage  = false
st1_assign_identity = false

us_ip_prefixes = ["35.142.168.71"]

st1_containers = {
  container1 = {
    name                  = "container1"
    container_access_type = "private"
  }
  container2 = {
    name                  = "container2"
    container_access_type = "private"
  }
}
st1_blobs = {
  # Requires a "Storage Blob Data *" role assigned to see blobs in Portal
  blob1 = {
    name                   = "blob1incontainer1"
    storage_container_name = "container1"
    type                   = "Block"
    size                   = 1024
    content_type           = null
    source_uri             = null
    metadata               = {}
    parallelism            = 8
  }
  blob2 = {
    name                   = "blob2incontainer1"
    storage_container_name = "container1"
    type                   = "Block"
    size                   = 1024
    content_type           = null
    source_uri             = null
    metadata               = {}
    parallelism            = 8
  }
  blob3 = {
    name                   = "blob3incontainer2"
    storage_container_name = "container2"
    type                   = "Block"
    size                   = 1024
    content_type           = null
    source_uri             = null
    metadata               = {}
    parallelism            = 8
  }
}
st1_queues = {
  queue1 = {
    name     = "queue1"
    metadata = {}
  }
}
st1_file_shares = {
  share1 = {
    name             = "share1"
    quota            = "16"
    metadata         = {}
    enabled_protocol = null
    access_tier      = "Cool"
  }
}
st1_tables = {
  table1 = {
    name = "table1"
  }
}
