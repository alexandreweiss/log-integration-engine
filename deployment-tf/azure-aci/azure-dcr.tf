data "azurerm_monitor_data_collection_endpoint" "dce" {
    name                = "avx-we-log"
    resource_group_name = var.log_analytics_resource_group_name
}

resource "azurerm_monitor_data_collection_rule" "aviatrix_microseg" {
  name                = "aviatrix-microseg-dcr"
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = var.log_analytics_resource_group_name
  data_collection_endpoint_id = data.azurerm_monitor_data_collection_endpoint.dce.id

  data_flow {
    streams      = ["Custom-AviatrixMicroseg_CL"]
    destinations = ["la-destination"]
    output_stream = "Custom-AviatrixMicroseg_CL"
    transform_kql = "source"
  }

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = "la-destination"
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
  data_collection_endpoint_id = data.azurerm_monitor_data_collection_endpoint.dce.id

  data_flow {
    streams      = ["Custom-AviatrixSuricata_CL"]
    destinations = ["la-destination"]
    output_stream = "Custom-AviatrixSuricata_CL"
    transform_kql = "source"
  }

  destinations {
    log_analytics {
      workspace_resource_id = data.azurerm_log_analytics_workspace.workspace.id
      name                  = "la-destination"
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