# Building custom container from Logstash container
# version 8.11 is a logstash plugin requirement as of August 2025.
# Works fine with the below version.
# More info at https://github.com/pkhabazi/microsoft-sentinel-logstash-output
FROM docker.elastic.co/logstash/logstash:8.13.4

# Install the Microsoft Sentinel Log Analytics output plugin for Logstash,
# enabling Logstash to send data directly to Azure Sentinel Log Analytics workspaces.
RUN logstash-plugin install microsoft-sentinel-log-analytics-logstash-output-plugin