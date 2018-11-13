# Usage

## Pre-req's:

 - [AWS Account](http://aws.amazon.com/) (Configuration not included)
 - [Ansible 2.5.1](https://www.ansible.com/) -  Resource configuration
 - [Gatling.io 3.0](https://gatling.io/) - Load testing tool
 - [Terraform 0.11.8](https://www.terraform.io/) - Provision resources
 - A (sub)domain - Used for HTTP URL resolution

## Description

This is an experiment to show the performance increase of enabling HTTP2 on a Nginx web server.

Inside the ./configs directory are traffic_source a traffic_target.

## Usage

### Traffic Target

This will stand up a basic LEMP server with Wordpress 4.x installed. Next we need to also start up a target_source instance.

Before anything else edit ./config/traffic_target/files/dump.sql line 11; change the domain to your domain.

    cd /path/to/project/root    
    cd ./configs/traffic_target
    terraform init
    terraform plan --out tf.plan
    terraform apply --auto-approve tf.plan

Wait for the process to complete. Once complete use the IP address and update your (sub)domain with the address.

Example

    your.domain.exp 1.2.3.4

Wait for the TTL (time to live) to refresh. You should be able to visit the site via the URL.

#### For HTTP/2

To enable HTTP2 SSH into the traffic_source machine, sudo to root, and cd to root's home dire.

    ssh -i ./shared/http2_effectiveness.pem ubuntu@TRAFFIC_SOURCE_IP
    sudo su
    cd ~/

Then run the `ssl_install.sh` script.

Once completed ensure 443 is reachable. Often this means opening the port.
**Note**: Terraform does not support Lightsail port management as of the time of writing.


### Traffic Generator

First, stand up the traffic source resources.

    cd /path/to/project/root
    cd ./configs/traffic_source
    terraform init
    terraform plan --out tf.plan
    terraform apply --auto-approve tf.plan

Wait for the process to complete. Using the IP output by Terraform, ssh into the traffic_source machine.

    ssh -i ../shared/http2_effectiveness.pem ubuntu@TERRAFORM_OUTPIT_IP

Switch to root, and goto home dir.

    sudo su
    cd ~/
    
The following command will generate traffic. Change the target URL of course :).

    JAVA_OPTS="-Dtarget=http://test.davidjeddy.com/" ./gatling-charts-highcharts-bundle-3.0.0/bin/gatling.sh  -sf ./ -rf ./results/ -s Http2Test
    
To test HTTP2 change to address from http to https.


### Retrieving Reports

If you want to be able to download the generated reports, execute the following command.

    chmod -R 0755 ./results && chown -R ubuntu:ubuntu ./results && cp -rf /root/results  /home/ubuntu

From you local machine use SCP to download the generated reports.

    scp -r -i ./configs/shared/http2_effectiveness.pem  ubuntu@34.200.238.33:/home/ubuntu/results .

Reports should be available under ./results directory.

### Tear down

To remove the services run the following command in both the traffic_target_* and traffic_source directories.

    terraform destroy -auto-approve

## Testing

TODO: Impairment https://github.com/ottomatica/opunit 