aws_region = "us-east-2"
logstash_instance_size = "t3.small"
syslog_port = "5000"
vpc_id = "vpc-12345"
subnet_ids = [ "subnet-12345" ]
ssh_key_name = "key_name"
logstash_output_config_path = "../../logstash-configs/output_splunk_hec"
logstash_output_config_name = "logstash_output_splunk_hec.conf"
logstash_base_config_path = "../../logstash-configs/base_config"
logstash_config_variables = {
  "splunk_hec_auth" = "aac90b81-123-123-123-123",
  "splunk_port" = "8088",
  "splunk_address" = "https://1.1.1.1" //Enter your Splunk HEC URL, include the protocol
}