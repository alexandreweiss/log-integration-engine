variable "location" {
  description = "Azure region for deployment."
  type        = string
}

locals {
  is_china = can(regex("china", lower(var.location)))
}

module "china_deployment" {
  source   = "./module"
  count    = local.is_china ? 1 : 0
  providers = {
    azurerm = azurerm.china
  }
  // ...pass required variables here...
}

module "global_deployment" {
  source   = "./module"
  count    = local.is_china ? 0 : 1
  providers = {
    azurerm = azurerm
  }
  // ...pass required variables here...
}
