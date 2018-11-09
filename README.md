# Usage

## Pre-req's:
 - [AWS Account](http://aws.amazon.com/) - Configuration not included herein
 - [Ansible 2.5.1](https://www.ansible.com/) - Configur machine
 - [Gatling.io 3.0](https://gatling.io/) - Load Test Tool
 - [Terraform 0.11.8](https://www.terraform.io/) - Provision machine

## Description

This is an experement to show the performance increase of enabling HTTP2 on a Nginx web server.

## Usage

The./config directory contains three sub directories: ./traffic_source, ./traffic_target_http, and ./traffic_target_http2. When started traffic_source is configured with Gatling 3.0 installed and ready to run. The two *_target_* directories are nearly identical configurations outside of the Nginx 'default' configuration.

To execute the performance comparison follow the below steps:

[Setup your AWS CLI and API keys.](https://www.terraform.io/docs/providers/aws/)



First change into the directory of the protocal you want to test. Ideally you will do this for both HTTP and HTTP2 for  side-by-side comparison.

    cd /path/to/root/of/this/project    
    cd /configs/target_target_http 
    # OR `cd target_target_http2` to start up a HTTP2 Nginx server
    terraform init
    terraform plan --out target_source.plan
    terraform apply --auto-approve --out target_source.plan

Thay will stand up a basic LEMP server with Wordpress 4.x installed. Next we need to also start up a target_source instance.

    cd /path/to/root/of/this/project    
    cd /configs/target_source
    terraform init
    terraform plan --out target_source.plan
    terraform apply --auto-approve --out target_source.plan

Wait for the process to complete. Using the IP output ssh into the traffic_source machine

    ssh -i ../shared/http2_effectiveness.pem ubuntu@TERRAFORM_OUTPIT_IP

Once in the traffic source machine, switch to root and root's home dir.

    sudo su
    cd ~/
    JAVA_OPTS="-Dtarget=TARGET_FQDN" ./gatling-charts-highcharts-bundle-3.0.0/bin/gatling.sh  -sf ./ -rf ./results/ -s load_test

In order to down load the results we need to change permissions to allow all users to read

    chown -R 0667 ./results

Then exit out of the target_source machine and use SCP to download the reports

    scp -i /path/to/project/configs/shared/http2_effectiveness.pem ubuntu@TERRAFORM_IP_OUT_OF_TRAFFIC_SOURCE:/root/results ./

### Tear down

To remove the services run the following command in both the traffic_target_* and traffic_source directories.

    terraform destroy -auto-approve

## Download reports from Traffic_Source
scp i ./configs/shared/http2_effectiveness.pem ubuntu@{TRAFFIC_SOURCE_IP}:/root/results ./

## NOTES
### For HTTP/2
 - IP <-> FQDN has to be updated in Route 53 after `tf apply` for tragget_target*
 - Terraform does not current support Lightsail port administration, open port 443 for HTTP/2
 - HTTP/2 req. SSL; ssh into HTTP/2 instance and execute /root/ssl_install.sh to generate a cert
