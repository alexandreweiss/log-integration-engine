# Azure ACI Logstash Deployment Configuration

# Resource Configuration
resource_group_name  = "logstash-aci-rg"
location            = "West Europe"

# Container Configuration
container_group_name = "logstash-container-group"
container_name      = "logstash"
container_image     = "docker.elastic.co/logstash/logstash:9.0.3"
cpu_cores          = 1
memory_gb          = 1.5
container_port     = 5000
dns_name_label     = "logstash-aci-francecentral"

# Storage Configuration
storage_account_name   = "logstashstoragefc01"
file_share_name       = "logstash-config"
file_share_quota_gb   = 5

# Log Analytics Configuration
log_analytics_workspace_name        = "we-loga-ws"
log_analytics_resource_group_name   = "we-loga-rg"

# Environment Variables for Logstash
environment_variables = {
  "LS_JAVA_OPTS"           = "-Xmx1g -Xms1g"
  # "LOG_LEVEL"             = "info"
  LOG_LEVEL             = "debug"
  "XPACK_MONITORING_ENABLED" = "false"
  "PIPELINE_WORKERS"       = "1"
  # Azure Log Ingestion API Configuration - Update these values
  "AZURE_DCE_ENDPOINT"     = "https://avx-we-log-0syf.westeurope-1.ingest.monitor.azure.com"
  "AZURE_ACCESS_TOKEN"     = "token"
  "AZURE_DCR_SURICATA_ID"  = "dcr-dc9894bcbd3e495f99c247ba15df4e02"
  "AZURE_DCR_MITM_ID"      = "dcr-mitm-rule-id"
  "AZURE_DCR_MICROSEG_ID"  = "dcr-9a4a471a1b654a02b810f09b0f1d2b58"
  "AZURE_DCR_FQDN_ID"      = "dcr-fqdn-rule-id"
  "AZURE_DCR_CMD_ID"       = "dcr-cmd-rule-id"
  "AZURE_STREAM_SURICATA"  = "Custom-AviatrixSuricata_CL"
  "AZURE_STREAM_MITM"      = "Custom-AviatrixMITM_CL"
  "AZURE_STREAM_MICROSEG"  = "Custom-AviatrixMicroseg_CL"
  "AZURE_STREAM_FQDN"      = "Custom-AviatrixFQDN_CL"
  "AZURE_STREAM_CMD"       = "Custom-AviatrixCMD_CL"
  # Splunk HEC Configuration - Update these values
  "SPLUNK_ADDRESS"         = "https://your-splunk-server.com"
  "SPLUNK_PORT"           = "8088"
  "SPLUNK_HEC_AUTH"       = "your-hec-token-here"
}

# Tags
tags = {
  Environment = "dev"
  Project     = "log-integration-engine"
  Service     = "logstash"
}
