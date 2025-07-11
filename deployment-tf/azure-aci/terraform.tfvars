# Azure ACI Logstash Deployment Configuration

# Resource Configuration
resource_group_name  = "logstash-aci-rg"
location            = "France Central"

# Container Configuration
container_group_name = "logstash-container-group"
container_name      = "logstash"
container_image     = "docker.elastic.co/logstash/logstash:8.16.2"
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
  "LOG_LEVEL"             = "info"
  "XPACK_MONITORING_ENABLED" = "false"
  "PIPELINE_WORKERS"       = "1"
  # Splunk HEC Configuration - Update these values
  "SPLUNK_ADDRESS"         = "https://your-splunk-server.com"
  "SPLUNK_PORT"           = "8088"
  "SPLUNK_HEC_AUTH"       = "your-hec-token-here"
}

# Tags
tags = {
  Environment = "production"
  Project     = "log-integration-engine"
  Service     = "logstash"
  Owner       = "platform-team"
  CostCenter  = "infrastructure"
}
