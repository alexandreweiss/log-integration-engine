variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "logstash_instance_size" {
  description = "Instance size for Logstash instances"
  default     = "t3.small"
}

variable "ssh_key_name" {
  description = "SSH key name"
  default     = "logstash"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_id" {
    description = "Subnet ID"
}

variable "use_existing_copilot_security_group" {
  description = "Use existing security group for Copilot"
  default     = false
}

variable "copilot_security_group_id" {
  description = "Security group ID for Copilot"
  default=""
}

variable "syslog_port" {
  description = "Syslog port"
  default     = 5000
}

variable "syslog_protocol" {
  description = "Syslog protocol"
  default     = "tcp"
}

variable "logstash_base_config_path" {
  description = "Path to logstash config file"
  default     = "../../logstash_configs/output_splunk_hec"
}

variable "logstash_output_config_path" {
  description = "Path to logstash config file"
  default     = "../../logstash_configs/output_splunk_hec"
}

variable "logstash_output_config_name" {
  description = "Name of logstash config file"
  default     = "logstash_output.conf"
}

variable "autoscale_min_size" {
    description = "Minimum number of instances in autoscale group"
    default     = 2
}

variable "autoscale_max_size" {
    description = "Maximum number of instances in autoscale group"
    default     = 6
}

variable "autoscale_step_size" {
    description = "Number of instances to add/remove when scaling"
    default     = 2
}

variable "tags" {
    description = "Tags to apply to all resources"
    type        = map(string)
    default     = {
        "App" = "avx-log-integration"
    }
}

variable "logstash_config_variables" {
    #map variable
    type = map(string)
    default = {
      "name" = "value"
    }
}