
# Aviatrix Log Integration Engine

Flexible and Scalable log integration between Aviatrix and 3rd party SIEM, Logging and Observability tools.

  

The integration is built on top of Logstash with an Aviatrix validated log parsing configuration.  The engine is best effort community supported.

  

## AWS deployment option
The logging engine is deployed as a set of VM instances alongside the existing Aviatrix Control plane. The framework provides example configurations for 2 components:

1. deployment-tf\aws* folders : Terraform to deploy the cloud infrastructure (Compute with Logstash, Logstash configuration in an object store (S3) bucket, and optionally load balancers) to point Aviatrix logging to and then forward it to the observability platform.

2. logstash-configs\output_splunk_hec folder : Example Logstash configurations based on the Aviatrix CoPilot validated configurations to parse Aviatrix syslog and forward to destinations (Splunk or Log Analytics)

## Azure deployment option
The logging engine is deployed as an Azure Container Instance (ACI). As a first release, it uses public connectivity to Aviatrix Control plane to export logs.

The framework provides example configurations for 2 components:

1. Terraform to deploy the cloud infrastructure (ACI with Logstash, Logstash configuration in an Azure Storage Account FileShare being mounted by the ACI, Microsoft Sentinel Log Ingestion API Logstash plugin preview) to point Aviatrix logging to and then forward it to the observability platform.

2. logstash-configs\base_config and output_azure_log_ingestion_api folder : Example Logstash configurations based on the Aviatrix CoPilot validated configurations to parse Aviatrix syslog and forward to destinations. (Log Analytics)

You can adapt Logstash configuration to output from AWS to Splunk or Log Analytics as well as from Azure to Splunk and Log Analytics.

## Deployment Architectures
Currently, the following engine deployment architectures are published in the `deployment-tf` folder:
| Deployment Architecture | Description | README |
|--|--|--|
|aws-ec2-autoscale  | An highly-available autoscaling set of EC2 instances running Logstash behind an AWS NLB with a public Elastic IP. An S3 bucket contains the Logstash configuration and roles are created to allow the VMs to pull the logstash configuration. When the logstash configuration changes, and the terraform is re-applied, the instances will automatically refresh with the new configuration via a rolling upgrade. | [Folder](./deployment-tf/aws-ec2-autoscale) |
|aws-ec2-single-instance| A single EC2 instance with Logstash and a public Elastic IP. An S3 bucket contains the Logstash configuration and roles are created to allow the VM to pull the Logstash configuration. When the Logstash configuration changes, and the Terraform is re-applied, the instances will automatically refresh with the new configuration via a rolling upgrade.| [Folder](./deployment-tf/aws-ec2-single-instance/) |
|azure-aci | A single Azure Container Instance (ACI) with Logstash and a public IP. An Azure Storage Account Fileshare contains the Logstash configuration. ACI mounts the fileshare at deployment time to read the Logstash configuration. Any update to those files trigger a Logstash reload. When the Logstash configuration changes, and the Terraform is re-applied, the instances will automatically refresh with the new configuration via a rolling upgrade.| [README](./deployment-tf/azure-aci/README.md) |


## Observability Destinations
Currently, the following destination observability outputs are published:

| Destination | Description | README |
|--|--|--|
| output_splunk_hec | Outputs JSON formatted logs to the Splunk HTTP Event Collector interface | [Folder](./logstash-configs/output_splunk_hec/) |
| output_azure_log_ingestion_api | Outputs logs to Azure Log Analytics via Logstash using Azure Log Ingestion API Logstash plugin (preview) | [Folder](./logstash-configs/output_azure_log_ingestion_api/) |

  
If modifying the Logstash configurations, it is recommended to modify only the "output" section as the inputs will be continuously updated to maintain compatibility with Aviatrix logs. 