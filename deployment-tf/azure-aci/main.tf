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

# Generate random suffix for unique naming
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# Storage account for Logstash configuration files
resource "azurerm_storage_account" "logstash_storage" {
  name                     = "${var.storage_account_name}${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.aci_rg.name
  location                 = azurerm_resource_group.aci_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

# File share for Logstash patterns
resource "azurerm_storage_share" "patterns" {
  name                 = "patterns"
  storage_account_name = azurerm_storage_account.logstash_storage.name
  quota                = var.file_share_quota_gb
}

# File share for Logstash pipeline
resource "azurerm_storage_share" "pipeline" {
  name                 = "pipeline"
  storage_account_name = azurerm_storage_account.logstash_storage.name
  quota                = var.file_share_quota_gb
}

# Upload Logstash configuration file to the pipeline share
resource "azurerm_storage_share_file" "logstash_conf" {
  name             = "logstash.conf"
  storage_share_id = azurerm_storage_share.pipeline.id
  source           = "${path.module}/../../logstash-configs/output_azure_log_ingestion_api/logstash_output_azure_lia.conf"
}

# Upload pattern file to the patterns share
resource "azurerm_storage_share_file" "avx_pattern" {
  name             = "avx.conf"
  storage_share_id = azurerm_storage_share.patterns.id
  source           = "${path.module}/../../logstash-configs/base_config/patterns/avx.conf"
}

# Container group with Logstash container
resource "azurerm_container_group" "logstash" {
  name                = var.container_group_name
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = azurerm_resource_group.aci_rg.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.dns_name_label}-${random_integer.suffix.result}"
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

    environment_variables = merge(var.environment_variables, var.logstash_config_variables, {
      "azure_dcr_microseg_id"  = azurerm_monitor_data_collection_rule.aviatrix_microseg.immutable_id
      "azure_dcr_suricata_id"  = azurerm_monitor_data_collection_rule.aviatrix_suricata.immutable_id
    })

    volume {
      name                 = "logstash-patterns"
      mount_path          = "/usr/share/logstash/patterns"
      read_only           = false
      storage_account_name = azurerm_storage_account.logstash_storage.name
      storage_account_key  = azurerm_storage_account.logstash_storage.primary_access_key
      share_name          = azurerm_storage_share.patterns.name
    }

    volume {
      name                 = "logstash-pipeline"
      mount_path          = "/usr/share/logstash/pipeline"
      read_only           = false
      storage_account_name = azurerm_storage_account.logstash_storage.name
      storage_account_key  = azurerm_storage_account.logstash_storage.primary_access_key
      share_name          = azurerm_storage_share.pipeline.name
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = data.azurerm_log_analytics_workspace.workspace.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.workspace.primary_shared_key
    }
  }

  tags = var.tags
  depends_on = [ azurerm_storage_share_file.avx_pattern, azurerm_storage_share_file.logstash_conf ]
}