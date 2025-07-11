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
}

# Data source for existing Log Analytics workspace
data "azurerm_log_analytics_workspace" "workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

# Resource group for the container instance
resource "azurerm_resource_group" "aci_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Storage account for Logstash configuration files
resource "azurerm_storage_account" "logstash_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.aci_rg.name
  location                 = azurerm_resource_group.aci_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# File share for Logstash configuration
resource "azurerm_storage_share" "logstash_config" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.logstash_storage.name
  quota                = var.file_share_quota_gb
}

# Upload Logstash configuration file to the file share
resource "azurerm_storage_share_file" "logstash_conf" {
  name             = "logstash.conf"
  storage_share_id = azurerm_storage_share.logstash_config.id
  source           = "${path.module}/../../logstash-configs/output_splunk_hec/logstash_output_splunk_hec.conf"
}

# Upload patterns directory (if exists)
resource "azurerm_storage_share_directory" "patterns_dir" {
  name             = "patterns"
  storage_share_id = azurerm_storage_share.logstash_config.id
}

# Upload pattern file
resource "azurerm_storage_share_file" "avx_pattern" {
  name             = "patterns/avx.conf"
  storage_share_id = azurerm_storage_share.logstash_config.id
  source           = "${path.module}/../../logstash-configs/base_config/patterns/avx.conf"
  depends_on       = [azurerm_storage_share_directory.patterns_dir]
}

# Container group with Logstash container
resource "azurerm_container_group" "logstash" {
  name                = var.container_group_name
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = azurerm_resource_group.aci_rg.name
  ip_address_type     = "Public"
  dns_name_label      = var.dns_name_label
  os_type             = "Linux"

  container {
    name   = var.container_name
    image  = var.container_image
    cpu    = var.cpu_cores
    memory = var.memory_gb

    ports {
      port     = var.container_port
      protocol = var.container_protocol
    }

    environment_variables = var.environment_variables

    volume {
      name                 = "logstash-config"
      mount_path          = "/usr/share/logstash/pipeline"
      read_only           = false
      storage_account_name = azurerm_storage_account.logstash_storage.name
      storage_account_key  = azurerm_storage_account.logstash_storage.primary_access_key
      share_name          = azurerm_storage_share.logstash_config.name
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = data.azurerm_log_analytics_workspace.workspace.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.workspace.primary_shared_key
    }
  }

  tags = var.tags
}
