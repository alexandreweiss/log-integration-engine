terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
    features {}
    alias = "china"
  environment = "china"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  
}