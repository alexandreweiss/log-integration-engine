resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "avx-drc-${random_integer.suffix.result}"
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = var.log_analytics_resource_group_name

}

resource "azurerm_monitor_data_collection_rule" "aviatrix_microseg" {
  name                = "aviatrix-microseg-dcr"
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = var.log_analytics_resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  data_flow {
    streams      = ["Custom-AviatrixMicroseg_CL"]
    destinations = ["loganalytics-destination"]
    output_stream = "Custom-AviatrixMicroseg_CL"
    transform_kql = "source"
  }

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = "loganalytics-destination"
    }
  }

  stream_declaration {
    stream_name = "Custom-AviatrixMicroseg_CL"
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "action"
      type = "string"
    }
    column {
      name = "dst_ip"
      type = "string"
    }
    column {
      name = "dst_mac"
      type = "string"
    }
    column {
      name = "dst_port"
      type = "int"
    }
    column {
      name = "enforced"
      type = "boolean"
    }
    column {
      name = "gw_hostname"
      type = "string"
    }
    column {
      name = "ls_timestamp"
      type = "string"
    }
    column {
      name = "proto"
      type = "string"
    }
    column {
      name = "src_ip"
      type = "string"
    }
    column {
      name = "src_mac"
      type = "string"
    }
    column {
      name = "src_port"
      type = "int"
    }
    column {
      name = "tags"
      type = "dynamic"
    }
    column {
      name = "uuid"
      type = "string"
    }
  }
}

resource "azurerm_monitor_data_collection_rule" "aviatrix_suricata" {
  name                = "aviatrix-suricata-dcr"
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = var.log_analytics_resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  data_flow {
    streams      = ["Custom-AviatrixSuricata_CL"]
    destinations = ["loganalytics-destination"]
    output_stream = "Custom-AviatrixSuricata_CL"
    transform_kql = "source"
  }

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = "loganalytics-destination"
    }
  }

  stream_declaration {
    stream_name = "Custom-AviatrixSuricata_CL"
    column {
      name = "TimeGenerated"
      type = "datetime"
    }
    column {
      name = "Computer"
      type = "string"
    }
    column {
      name = "alert"
      type = "dynamic"
    }
    column {
      name = "app_proto"
      type = "string"
    }
    column {
      name = "dest_ip"
      type = "string"
    }
    column {
      name = "dest_port"
      type = "int"
    }
    column {
      name = "event_type"
      type = "string"
    }
    column {
      name = "files"
      type = "dynamic"
    }
    column {
      name = "flow"
      type = "dynamic"
    }
    column {
      name = "flow_id"
      type = "long"
    }
    column {
      name = "http"
      type = "dynamic"
    }
    column {
      name = "in_iface"
      type = "string"
    }
    column {
      name = "ls_timestamp"
      type = "string"
    }
    column {
      name = "ls_version"
      type = "string"
    }
    column {
      name = "proto"
      type = "string"
    }
    column {
      name = "src_ip"
      type = "string"
    }
    column {
      name = "src_port"
      type = "int"
    }
    column {
      name = "tags"
      type = "dynamic"
    }
    column {
      name = "timestamp"
      type = "string"
    }
    column {
      name = "tx_id"
      type = "int"
    }
    column {
      name = "SourceType"
      type = "string"
    }
    column {
      name = "UnixTime"
      type = "long"
    }
  }
}

# Azure AD Application and Service Principal for Logstash to authenticate to Azure Monitor DCR
data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

# 1. Application (Service Principal) creation
resource "azuread_application" "logstash_app" {
  display_name = "aweiss-logstash-sentinel-${random_integer.suffix.result}"
  owners    = [data.azuread_client_config.current.object_id]
}
# 2. Create the password for the created APP
resource "azuread_application_password" "logstash_app_password" {
  application_id = azuread_application.logstash_app.id
  end_date = timeadd(timestamp(), "8760h")

  lifecycle {
    ignore_changes = [end_date]
  }
}

# 3. Create SP associated with the APP
resource "azuread_service_principal" "logstash_sp" {
  client_id = azuread_application.logstash_app.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# 4. Create the password for the created SP
resource "azuread_service_principal_password" "logstash_sp_password" {
  service_principal_id = azuread_service_principal.logstash_sp.id
}

# Role assignment for the Log Analytics Data Collection Rules

resource "azurerm_role_assignment" "aviatrix_suricata_dcr_assignment" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.log_analytics_resource_group_name}/providers/Microsoft.Insights/dataCollectionRules/aviatrix-suricata-dcr"
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azuread_service_principal.logstash_sp.object_id
  depends_on = [ azurerm_monitor_data_collection_rule.aviatrix_suricata ]
}

resource "azurerm_role_assignment" "aviatrix_microseg_dcr_assignment" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.log_analytics_resource_group_name}/providers/Microsoft.Insights/dataCollectionRules/aviatrix-microseg-dcr"
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azuread_service_principal.logstash_sp.object_id
  depends_on = [ azurerm_monitor_data_collection_rule.aviatrix_microseg ]
}


## Work in progress - Sample Log Analytics Table for Aviatrix Microseg. Doesn't support TF resource yet.
# resource "azapi_resource" "aviatrix_microseg_table" {
#   type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
#     parent_id = data.azurerm_log_analytics_workspace.workspace.id
#   name      = "AviatrixMicroseg_CL"

#   body = jsonencode({
#     properties = {
#       schema = {
#         name    = "AviatrixMicroseg_CL"
#         columns = [
#           { name = "TimeGenerated",      type = "DateTime" },
#           { name = "Computer",           type = "string" },
#           { name = "action",             type = "string" },
#           { name = "dst_ip",             type = "string" },
#           { name = "dst_mac",            type = "string" },
#           { name = "dst_port",           type = "int" },
#           { name = "enforced",           type = "boolean" },
#           { name = "gw_hostname",        type = "string" },
#           { name = "ls_timestamp",       type = "string" },
#           { name = "message",            type = "string" },
#           { name = "proto",              type = "string" },
#           { name = "src_ip",             type = "string" },
#           { name = "src_mac",            type = "string" },
#           { name = "src_port",           type = "int" },
#           { name = "tags",               type = "dynamic" },
#           { name = "unix_time",          type = "long" },
#           { name = "uuid",               type = "string" },
#           { name = "SourceType",         type = "string" },
#           { name = "UnixTime",           type = "long" }
#         ]
#       }
#     }
#   })
# }