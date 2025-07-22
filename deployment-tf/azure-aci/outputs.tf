output "container_group_name" {
  description = "Name of the created container group"
  value       = azurerm_container_group.logstash.name
}

output "container_group_fqdn" {
  description = "FQDN of the container group"
  value       = azurerm_container_group.logstash.fqdn
}

output "container_group_ip_address" {
  description = "Public IP address of the container group"
  value       = azurerm_container_group.logstash.ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.aci_rg.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.aci_rg.location
}

output "logstash_endpoint" {
  description = "Logstash endpoint URL"
  value       = "http://${azurerm_container_group.logstash.fqdn}:${var.container_port}"
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID used for logging"
  value       = data.azurerm_log_analytics_workspace.workspace.workspace_id
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the storage account for Logstash configuration"
  value       = azurerm_storage_account.logstash_storage.name
}


output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.logstash_storage.primary_access_key
  sensitive   = true
}

output "logstash_config_files" {
  description = "List of uploaded Logstash configuration files"
  value = [
    azurerm_storage_share_file.logstash_conf.name,
    azurerm_storage_share_file.avx_pattern.name
  ]
}
