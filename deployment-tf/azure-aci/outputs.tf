output "container_group_name" {
  description = "Name of the created container group"
  value       = azurerm_container_group.logstash.name
}

output "container_group_fqdn" {
  description = "FQDN of the container group"
  value       = azurerm_container_group.logstash.fqdn
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.aci_rg.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.aci_rg.location
}

output "storage_account_name" {
  description = "Name of the storage account for Logstash configuration"
  value       = azurerm_storage_account.logstash_storage.name
}

output "logstash_config_files" {
  description = "List of uploaded Logstash configuration files"
  value = [
    azurerm_storage_share_file.logstash_conf.name,
    azurerm_storage_share_file.avx_pattern.name
  ]
}
