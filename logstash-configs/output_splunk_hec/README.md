The Splunk HTTP Event Collector configuration enables the ingestion of Aviatrix logs into Splunk via the Splunk HTTP Event Collector.

Required variables in the terraform deployment are as follows:

```
logstash_config_variables = {
  "splunk_hec_auth" = "aac90b81-123-123-123-123",
  "splunk_port" = "8088",
  "splunk_address" = "1.1.1.1"
}
```

Example full `var.tfvars` for deploying the Splunk HTTP Event Collector with the "aws-ec2-single-instance" model:

```
aws_region = "us-east-2"
logstash_instance_size = "t3.small"
syslog_port = "5000"
vpc_id = "vpc-12345"
subnet_id = "subnet-12345"
ssh_key_name = "aws-ssh-key"
logstash_output_config_path = "../../logstash-configs/output_splunk_hec"
logstash_output_config_name = "logstash_output_splunk_hec.conf"
logstash_base_config_path = "../../logstash-configs/base_config"
logstash_config_variables = {
  "splunk_hec_auth" = "aac12345-123-123-123-12345",
  "splunk_port" = "8088",
  "splunk_address" = "1.1.1.1"
}
```

## Configuring Splunk HEC

1. From the Splunk dashboard, go to Settings -> Data Inputs -> HTTP Event Collector.
2. Create a New Token for Aviatrix
3. Copy the token value and use that as the "splunk_hec_auth" variable in the Log Integration Engine deployment variables