# Azure Container Instances (ACI) Logstash Deployment

This Terraform configuration deploys a Logstash container on Azure Container Instances (ACI) with the following specifications:

## Configuration Details

- **Location**: France Central
- **Container Image**: docker.elastic.co/logstash/logstash:8.16.2
- **Resources**: 1 vCPU, 1.5GB memory
- **Network**: Public IP with TCP port 5000 exposed
- **OS Type**: Linux
- **Storage**: Azure File Share mounted at `/usr/share/logstash/pipeline` for configuration files
- **Logging**: Integrated with Log Analytics workspace `we-log-ws` in resource group `core-rg`

## Prerequisites

1. Azure CLI installed and authenticated
2. Terraform >= 1.0 installed
3. Existing Log Analytics workspace `we-log-ws` in resource group `core-rg`

## Deployment Steps

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

4. **Get outputs**:
   ```bash
   terraform output
   ```

## Configuration Files

- `main.tf` - Main Terraform configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions
- `terraform.tfvars` - Variable values (customize as needed)

## Customization

You can customize the deployment by modifying the `terraform.tfvars` file:

- Change resource names
- Modify container specifications
- Add additional environment variables
- Update tags

## Accessing Logstash

After deployment, Logstash will be accessible at:
- **FQDN**: The output `container_group_fqdn` will provide the full domain name
- **IP**: The output `container_group_ip_address` will provide the public IP
- **Endpoint**: The output `logstash_endpoint` will provide the complete URL

## Logstash Configuration

The deployment automatically uploads the following configuration files to the Azure File Share:

- **Main Configuration**: `logstash.conf` (from `../../logstash-configs/output_splunk_hec/logstash_output_splunk_hec.conf`)
- **Patterns**: `patterns/avx.conf` (from `../../logstash-configs/base_config/patterns/avx.conf`)

These files are mounted to the container at `/usr/share/logstash/pipeline` and `/usr/share/logstash/patterns` respectively.

### Environment Variables Required

The Logstash configuration expects the following environment variables to be set for Splunk HEC integration:

- `SPLUNK_ADDRESS` - Splunk server address (e.g., "https://splunk.example.com")
- `SPLUNK_PORT` - Splunk HEC port (default: 8088)
- `SPLUNK_HEC_AUTH` - Splunk HEC authentication token

You can add these to the `environment_variables` in your `terraform.tfvars` file:

```hcl
environment_variables = {
  "LS_JAVA_OPTS"           = "-Xmx1g -Xms1g"
  "XPACK_MONITORING_ENABLED" = "false"
  "SPLUNK_ADDRESS"         = "https://your-splunk-server.com"
  "SPLUNK_PORT"           = "8088"
  "SPLUNK_HEC_AUTH"       = "your-hec-token-here"
}
```

### Manual File Management

You can also manually upload additional configuration files to the file share:

1. **Access the storage account**: Use the output `storage_account_name` and `storage_account_primary_access_key`
2. **Upload configuration files**: Upload your `.conf` files to the `logstash-config` file share
3. **Restart container**: The container will automatically pick up new configuration files

### Example: Upload configuration via Azure CLI
```bash
# Get storage account details from Terraform outputs
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
STORAGE_KEY=$(terraform output -raw storage_account_primary_access_key)

# Upload a configuration file
az storage.file upload \
  --account-name $STORAGE_ACCOUNT \
  --account-key $STORAGE_KEY \
  --share-name logstash-config \
  --source ./my-logstash.conf \
  --path my-logstash.conf
```

## Monitoring

Container logs are automatically sent to the specified Log Analytics workspace (`we-log-ws`). You can monitor the container performance and logs through Azure Portal.

## Clean Up

To destroy the resources:
```bash
terraform destroy -var-file="terraform.tfvars"
```

## Notes

- The container uses the official Elastic Logstash Docker image
- Java heap size is set to 1GB (adjustable via environment variables)
- The container is configured for production use with appropriate resource limits
- All resources are tagged for better management and cost tracking
