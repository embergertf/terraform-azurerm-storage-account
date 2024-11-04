#
# Copyright 2024 - Emmanuel Bergerat
#

#--------------------------------------------------------------
#   Test base values
#--------------------------------------------------------------
# region_code     = "usnc"
# subsc_code      = "dev"
# env             = "local"
# base_name       = "embergertf"
# additional_name = null
# iterator        = "01"
# additional_tags = {
#   Test_by    = "Manu",
#   GitHub_org = "embergertf"
# }

naming_values = {
  region_code     = "uswe2"
  subsc_code      = "714895"
  env             = "dev"
  base_name       = "embergertf"
  additional_name = null
  iterator        = "01"
  owner           = "Emm"
  additional_tags = {
    Test_by    = "Emm",
    GitHub_org = "gopher194/embergertf",
    Purpose    = "Terraform modules development"
    Module     = "storage-account"
  }
}

add_random = null
rnd_length = null

test_containers = {
  container1 = {
    name                  = "container1"
    container_access_type = "private"
  }
  container2 = {
    name                  = "container2"
    container_access_type = "private"
  }
}
