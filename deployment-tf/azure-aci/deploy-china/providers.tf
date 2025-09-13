provider "azurerm" {
  features {}
  alias       = "china"
  environment = "china"
}

provider "azuread" {
  alias       = "china"
  environment = "china"
}
