module "deployment" {
  source = "../module"
  providers = {
    azurerm = azurerm.public
    azuread = azuread.public
  }

  # Azure ACI Logstash Deployment Configuration - Sample File
  # Copy this file to terraform.tfvars and update with your actual values

  # Resource Configuration
  resource_group_name = var.resource_group_name
  location            = var.location

  # Container Configuration
  container_name  = var.container_name
  container_image = var.container_image
  cpu_cores       = var.cpu_cores
  memory_gb       = var.memory_gb
  container_port  = var.container_port

  # Storage Configuration
  storage_account_name = var.storage_account_name

  # Log Analytics Configuration
  log_analytics_workspace_name      = var.log_analytics_workspace_name
  log_analytics_resource_group_name = var.log_analytics_resource_group_name

  # If you use your own EntraID Service Principal, uncomment the below and insert appropriate value
  client_app_id     = var.client_app_id
  client_app_secret = var.client_app_secret
  tenant_id         = var.tenant_id
  use_existing_spn  = var.use_existing_spn
  azure_cloud       = var.azure_cloud

  # Tags
  tags = var.tags
}
