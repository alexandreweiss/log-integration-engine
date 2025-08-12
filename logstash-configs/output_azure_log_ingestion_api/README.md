# Azure Log Ingestion API Configuration

The Azure Log Ingestion API configuration enables the ingestion of Aviatrix logs into Azure Monitor Log Analytics

Required variables in the terraform deployment are as follows:

```
logstash_config_variables = {
  "azure_dcr_suricata_id"  = "dcr-12345678-1234-1234-1234-123456789abc",
  "azure_dcr_mitm_id"      = "dcr-12345678-1234-1234-1234-123456789def",
  "azure_dcr_microseg_id"  = "dcr-12345678-1234-1234-1234-123456789ghi",
  "azure_dcr_fqdn_id"      = "dcr-12345678-1234-1234-1234-123456789jkl",
  "azure_dcr_cmd_id"       = "dcr-12345678-1234-1234-1234-123456789mno",
  "azure_stream_suricata"  = "Custom-AviatrixSuricata_CL",
  "azure_stream_mitm"      = "Custom-AviatrixMITM_CL",
  "azure_stream_microseg"  = "Custom-AviatrixMicroseg_CL",
  "azure_stream_fqdn"      = "Custom-AviatrixFQDN_CL",
  "azure_stream_cmd"       = "Custom-AviatrixCMD_CL",
  "client_app_id"          = "12345678-1234-1234-1234-123456789abc",
  "client_app_secret"      = "your-client-secret-value",
  "tenant_id"              = "12345678-1234-1234-1234-123456789abc",
  "data_collection_endpoint" = "https://your-dce-name.westeurope-1.ingest.monitor.azure.com"
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
  --name "your-dce-name" \
  --resource-group "<resource-group>" \
  --location "your-location" \
  --network-acls-public-network-access "Enabled"
```

#### 2. Create Custom Tables in Log Analytics Workspace
Create custom tables for each log type using Azure CLI:

```bash
# Suricata IDS logs table
az monitor log-analytics workspace table create \
  --resource-group "<resource-group>" \
  --workspace-name "your-workspace-name" \
  --name "AviatrixSuricata_CL" \
  --columns TimeGenerated=datetime Computer=string alert=dynamic app_proto=string dest_ip=string dest_port=int event_type=string files=dynamic flow=dynamic flow_id=long http=dynamic in_iface=string ls_timestamp=string ls_version=string proto=string src_ip=string src_port=int tags=dynamic timestamp=string tx_id=int SourceType=string UnixTime=long

# Microsegmentation Layer 4 firewall logs table
az monitor log-analytics workspace table create \
  --resource-group "<resource-group>" \
  --workspace-name "your-workspace-name" \
  --name "AviatrixMicroseg_CL" \
  --columns TimeGenerated=datetime action=string dst_ip=string dst_mac=string dst_port=int enforced=boolean gw_hostname=string ls_timestamp=string proto=string src_ip=string src_mac=string src_port=int tags=dynamic uuid=string SourceType=string
```

**Work in progress below, so far, we support only Suricata and MicroSeg**

```bash
# MITM Layer 7 firewall logs table
az monitor log-analytics workspace table create \
  --resource-group "<resource-group>" \
  --workspace-name "your-workspace-name" \
  --name "AviatrixMITM_CL" \
  --columns TimeGenerated=datetime Computer=string EventData=dynamic SourceType=string UnixTime=long

# FQDN firewall rules logs table
az monitor log-analytics workspace table create \
  --resource-group "<resource-group>" \
  --workspace-name "your-workspace-name" \
  --name "AviatrixFQDN_CL" \
  --columns TimeGenerated=datetime Computer=string SourceIP=string DestinationIP=string Gateway=string State=string Hostname=string Rule=string SyslogMessage=string SourceType=string UnixTime=long

# Command and API audit logs table
az monitor log-analytics workspace table create \
  --resource-group "<resource-group>" \
  --workspace-name "your-workspace-name" \
  --name "AviatrixCMD_CL" \
  --columns TimeGenerated=datetime Computer=string Action=string Arguments=string Result=string Reason=string Username=string SyslogMessage=string SourceType=string UnixTime=long
```

**Note**: Replace `<subscription-id>` with your actual Azure subscription ID and `<resource-group>` with actual resource group name to use in all the commands above.

#### 4. Service Principal Authentication
Create a service principal to be used by the Microsoft Log Ingestion API Logstash plugin:
```bash
az ad sp create-for-rbac --name "aviatrix-log-ingestion"
az login --service-principal -u <client-id> -p <client-secret> --tenant <tenant-id>
```

#### 5. Assign Permissions
Assign the "Monitoring Metrics Publisher" role to the service principal for each DCR:
```bash
az role assignment create \
  --assignee <service-principal-id> \
  --role "Monitoring Metrics Publisher" \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Insights/dataCollectionRules/<dcr-name>
```

### Log Types and Tables

| Log Type | Stream Name | Custom Table | Description |
|----------|-------------|--------------|-------------|
| Suricata | `Custom-AviatrixSuricata_CL` | `AviatrixSuricata_CL` | Intrusion Detection System logs |
| MITM | `Custom-AviatrixMITM_CL` | `AviatrixMITM_CL` | Layer 7 firewall inspection logs |
| Microseg | `Custom-AviatrixMicroseg_CL` | `AviatrixMicroseg_CL` | Layer 4 microsegmentation logs |
| FQDN | `Custom-AviatrixFQDN_CL` | `AviatrixFQDN_CL` | Domain-based firewall rule logs |
| CMD | `Custom-AviatrixCMD_CL` | `AviatrixCMD_CL` | Command and API audit logs |

### Troubleshooting

1. **Authentication Issues**: Verify service principal has correct permissions on DCRs
2. **Schema Errors**: Ensure custom table schemas match the field mappings in the configuration
3. **Network Issues**: Check DCE network access rules and firewall settings
4. **Rate Limiting**: Azure Log Ingestion API has rate limits - implement appropriate retry logic

### Improvments

1. Better secure the DCE maybe by inserting it into Aviatrix Control Plane VNET.
