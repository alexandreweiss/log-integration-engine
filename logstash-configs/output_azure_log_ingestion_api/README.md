# Azure Log Ingestion API Configuration

The Azure Log Ingestion API configuration enables the ingestion of Aviatrix logs into Azure Monitor Log Analyt  --data-coll  --data-coll  --data-collection-endpoint-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixCMD_CL": {
      "columns": [
        {"name": "EventData", "type": "dynamic"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",t-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixFQDN_CL": {
      "columns": [
        {"name": "EventData", "type": "dynamic"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",t-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixMicroseg_CL": {
      "columns": [
        {"name": "EventData", "type": "dynamic"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws", via the Azure Log Ingestion API.

Required variables in the terraform deployment are as follows:

```
logstash_config_variables = {
  "azure_dce_endpoint" = "https://your-dce-name.eastus-1.ingest.monitor.azure.com",
  "azure_access_token" = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6...",
  "azure_dcr_suricata_id" = "dcr-12345678-1234-1234-1234-123456789abc",
  "azure_dcr_mitm_id" = "dcr-12345678-1234-1234-1234-123456789def",
  "azure_dcr_microseg_id" = "dcr-12345678-1234-1234-1234-123456789ghi",
  "azure_dcr_fqdn_id" = "dcr-12345678-1234-1234-1234-123456789jkl",
  "azure_dcr_cmd_id" = "dcr-12345678-1234-1234-1234-123456789mno",
  "azure_stream_suricata" = "Custom-AviatrixSuricata_CL",
  "azure_stream_mitm" = "Custom-AviatrixMITM_CL",
  "azure_stream_microseg" = "Custom-AviatrixMicroseg_CL",
  "azure_stream_fqdn" = "Custom-AviatrixFQDN_CL",
  "azure_stream_cmd" = "Custom-AviatrixCMD_CL"
}
```

Example full `var.tfvars` for deploying the Azure Log Ingestion API with the "aws-ec2-single-instance" model:

```
aws_region = "us-east-2"
logstash_instance_size = "t3.small"
syslog_port = "5000"
vpc_id = "vpc-12345"
subnet_id = "subnet-12345"
ssh_key_name = "aws-ssh-key"
logstash_output_config_path = "../../logstash-configs/output_azure_log_ingestion_api"
logstash_output_config_name = "logstash_output_azure_lia.conf"
logstash_base_config_path = "../../logstash-configs/base_config"
logstash_config_variables = {
  "azure_dce_endpoint" = "https://your-dce-name.eastus-1.ingest.monitor.azure.com",
  "azure_access_token" = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6...",
  "azure_dcr_suricata_id" = "dcr-12345678-1234-1234-1234-123456789abc",
  "azure_dcr_mitm_id" = "dcr-12345678-1234-1234-1234-123456789def",
  "azure_dcr_microseg_id" = "dcr-12345678-1234-1234-1234-123456789ghi",
  "azure_dcr_fqdn_id" = "dcr-12345678-1234-1234-1234-123456789jkl",
  "azure_dcr_cmd_id" = "dcr-12345678-1234-1234-1234-123456789mno",
  "azure_stream_suricata" = "Custom-AviatrixSuricata_CL",
  "azure_stream_mitm" = "Custom-AviatrixMITM_CL",
  "azure_stream_microseg" = "Custom-AviatrixMicroseg_CL",
  "azure_stream_fqdn" = "Custom-AviatrixFQDN_CL",
  "azure_stream_cmd" = "Custom-AviatrixCMD_CL"
}
```

## Configuring Azure Log Ingestion API

### Prerequisites

1. **Azure Monitor Log Analytics Workspace** - Create or use existing workspace
2. **Data Collection Endpoint (DCE)** - Regional endpoint for data ingestion
3. **Data Collection Rules (DCRs)** - One for each log type (Suricata, MITM, Microseg, FQDN, CMD)
4. **Custom Tables** - Tables in Log Analytics workspace with appropriate schemas
5. **Service Principal** - With appropriate permissions for data ingestion

### Setup Steps

#### 1. Create Data Collection Endpoint (DCE)
```bash
az monitor data-collection-endpoint create \
  --name "avx-we-log" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --network-acls-public-network-access "Enabled"
```

#### 2. Create Custom Tables in Log Analytics Workspace
Create custom tables for each log type using Azure CLI:

```bash
# Suricata IDS logs table
az monitor log-analytics workspace table create \
  --resource-group "we-loga-rg" \
  --workspace-name "we-loga-ws" \
  --name "AviatrixSuricata_CL" \
  --columns TimeGenerated=datetime Computer=string SuricataData=string SourceType=string UnixTime=long

# MITM Layer 7 firewall logs table
az monitor log-analytics workspace table create \
  --resource-group "we-loga-rg" \
  --workspace-name "we-loga-ws" \
  --name "AviatrixMITM_CL" \
  --columns TimeGenerated=datetime Computer=string EventData=dynamic SourceType=string UnixTime=long

# Microsegmentation Layer 4 firewall logs table
az monitor log-analytics workspace table create \
  --resource-group "we-loga-rg" \
  --workspace-name "we-loga-ws" \
  --name "AviatrixMicroseg_CL" \
  --columns TimeGenerated=datetime Computer=string Protocol=string Action=string SourceIP=string SourcePort=int DestinationIP=string DestinationPort=int Enforced=boolean PolicyUUID=string SyslogMessage=string SourceType=string UnixTime=long

# FQDN firewall rules logs table
az monitor log-analytics workspace table create \
  --resource-group "we-loga-rg" \
  --workspace-name "we-loga-ws" \
  --name "AviatrixFQDN_CL" \
  --columns TimeGenerated=datetime Computer=string SourceIP=string DestinationIP=string Gateway=string State=string Hostname=string Rule=string SyslogMessage=string SourceType=string UnixTime=long

# Command and API audit logs table
az monitor log-analytics workspace table create \
  --resource-group "we-loga-rg" \
  --workspace-name "we-loga-ws" \
  --name "AviatrixCMD_CL" \
  --columns TimeGenerated=datetime Computer=string Action=string Arguments=string Result=string Reason=string Username=string SyslogMessage=string SourceType=string UnixTime=long
```

#### 3. Create Data Collection Rules (DCRs)
Create separate DCRs for each log type, mapping to the appropriate custom tables and streams:

```bash
# Suricata IDS Data Collection Rule
az monitor data-collection rule create \
  --name "aviatrix-suricata-dcr" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --data-collection-endpoint-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixSuricata_CL": {
      "columns": [
        {"name": "TimeGenerated", "type": "DateTime"},
        {"name": "Computer", "type": "string"},
        {"name": "SuricataData", "type": "string"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",
        "name": "la-destination"
      }
    ]
  }' \
  --data-flows '[
    {
      "streams": ["Custom-AviatrixSuricata_CL"],
      "destinations": ["la-destination"],
      "transformKql": "source",
      "outputStream": "Custom-AviatrixSuricata_CL"
    }
  ]'

# MITM Layer 7 firewall Data Collection Rule
az monitor data-collection rule create \
  --name "aviatrix-mitm-dcr" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --data-collection-endpoint-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixMITM_CL": {
      "columns": [
        {"name": "EventData", "type": "dynamic"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",
        "name": "la-destination"
      }
    ]
  }' \
  --data-flows '[
    {
      "streams": ["Custom-AviatrixMITM_CL"],
      "destinations": ["la-destination"],
      "transformKql": "source",
      "outputStream": "Custom-AviatrixMITM_CL"
    }
  ]'

# Microsegmentation Layer 4 Data Collection Rule
az monitor data-collection rule create \
  --name "aviatrix-microseg-dcr" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --data-collection-endpoint-id "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixMicroseg_CL": {
      "columns": [
        {"name": "TimeGenerated", "type": "DateTime"},
        {"name": "Protocol", "type": "string"},
        {"name": "Action", "type": "string"},
        {"name": "SourceIP", "type": "string"},
        {"name": "SourcePort", "type": "int"},
        {"name": "DestinationIP", "type": "string"},
        {"name": "DestinationPort", "type": "int"},
        {"name": "Enforced", "type": "boolean"},
        {"name": "PolicyUUID", "type": "string"},
        {"name": "SyslogMessage", "type": "string"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",
        "name": "la-destination"
      }
    ]
  }' \
  --data-flows '[
    {
      "streams": ["Custom-AviatrixMicroseg_CL"],
      "destinations": ["la-destination"],
      "transformKql": "source",
      "outputStream": "Custom-AviatrixMicroseg_CL"
    }
  ]'

# FQDN firewall rules Data Collection Rule
az monitor data-collection rule create \
  --name "aviatrix-fqdn-dcr" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --data-collection-endpoint-id "/subscriptions/<subscription-id>/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixFQDN_CL": {
      "columns": [
        {"name": "SourceIP", "type": "string"},
        {"name": "DestinationIP", "type": "string"},
        {"name": "Gateway", "type": "string"},
        {"name": "State", "type": "string"},
        {"name": "Hostname", "type": "string"},
        {"name": "Rule", "type": "string"},
        {"name": "SyslogMessage", "type": "string"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/<subscription-id>/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",
        "name": "la-destination"
      }
    ]
  }' \
  --data-flows '[
    {
      "streams": ["Custom-AviatrixFQDN_CL"],
      "destinations": ["la-destination"],
      "transformKql": "source",
      "outputStream": "Custom-AviatrixFQDN_CL"
    }
  ]'

# Command and API audit Data Collection Rule
az monitor data-collection rule create \
  --name "aviatrix-cmd-dcr" \
  --resource-group "we-loga-rg" \
  --location "westeurope" \
  --data-collection-endpoint-id "/subscriptions/<subscription-id>/resourceGroups/we-loga-rg/providers/Microsoft.Insights/dataCollectionEndpoints/avx-we-log" \
  --stream-declarations '{
    "Custom-AviatrixCMD_CL": {
      "columns": [
        {"name": "Action", "type": "string"},
        {"name": "Arguments", "type": "string"},
        {"name": "Result", "type": "string"},
        {"name": "Reason", "type": "string"},
        {"name": "Username", "type": "string"},
        {"name": "SyslogMessage", "type": "string"},
        {"name": "SourceType", "type": "string"},
        {"name": "UnixTime", "type": "long"}
      ]
    }
  }' \
  --destinations '{
    "logAnalytics": [
      {
        "workspaceResourceId": "/subscriptions/<subscription-id>/resourceGroups/we-loga-rg/providers/Microsoft.OperationalInsights/workspaces/we-loga-ws",
        "name": "la-destination"
      }
    ]
  }' \
  --data-flows '[
    {
      "streams": ["Custom-AviatrixCMD_CL"],
      "destinations": ["la-destination"],
      "transformKql": "source",
      "outputStream": "Custom-AviatrixCMD_CL"
    }
  ]'
```

**Note**: Replace `<subscription-id>` with your actual Azure subscription ID in all the commands above.

#### 4. Service Principal Authentication
Create a service principal and obtain an access token:
```bash
az ad sp create-for-rbac --name "aviatrix-log-ingestion"
az login --service-principal -u <client-id> -p <client-secret> --tenant <tenant-id>
az account get-access-token --resource https://monitor.azure.com/
```

#### 5. Assign Permissions
Assign the "Monitoring Metrics Publisher" role to the service principal for each DCR:
```bash
az role assignment create \
  --assignee <service-principal-id> \
  --role "Monitoring Metrics Publisher" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Insights/dataCollectionRules/<dcr-name>
```

### Log Types and Tables

| Log Type | Stream Name | Custom Table | Description |
|----------|-------------|--------------|-------------|
| Suricata | `Custom-AviatrixSuricata_CL` | `AviatrixSuricata_CL` | Intrusion Detection System logs |
| MITM | `Custom-AviatrixMITM_CL` | `AviatrixMITM_CL` | Layer 7 firewall inspection logs |
| Microseg | `Custom-AviatrixMicroseg_CL` | `AviatrixMicroseg_CL` | Layer 4 microsegmentation logs |
| FQDN | `Custom-AviatrixFQDN_CL` | `AviatrixFQDN_CL` | Domain-based firewall rule logs |
| CMD | `Custom-AviatrixCMD_CL` | `AviatrixCMD_CL` | Command and API audit logs |

### Token Management

⚠️ **Important**: Access tokens expire (typically 1 hour). For production deployments, implement token refresh logic or use managed identities when possible.

Consider using:
- **Managed Identity** (recommended for Azure-hosted resources)
- **Azure Key Vault** for secure token storage
- **Automated token refresh** mechanism

### Troubleshooting

1. **Authentication Issues**: Verify service principal has correct permissions on DCRs
2. **Schema Errors**: Ensure custom table schemas match the field mappings in the configuration
3. **Network Issues**: Check DCE network access rules and firewall settings
4. **Rate Limiting**: Azure Log Ingestion API has rate limits - implement appropriate retry logic
