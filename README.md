# Usage

## Pre-req's:

 - [AWS Account](http://aws.amazon.com/) (Configuration not included)
 - [Ansible 2.5.1](https://www.ansible.com/) -  Resource configuration
 - [Gatling.io 3.0](https://gatling.io/) - Load testing tool
 - [Terraform 0.11.8](https://www.terraform.io/) - Provision resources
 - A (sub)domain - Used for HTTP URL resolution

## Description

This is an experiment to show the performance increase of enabling HTTP2 on a Nginx web server.

## Description

The./config directory contains three sub directories: ./traffic_source, ./traffic_target_http, and ./traffic_target_http2.

traffic_source a traffic generator resource.

The two traffic_target_* directories are nearly identical configurations, the difference being the toggle of http2.

## Usage

### Traffic Target

Now this will stand up a basic LEMP server with Wordpress 4.x installed. Next we need to also start up a target_source instance.

    cd /path/to/project/root    
    cd ./configs/traffic_target
    terraform init
    terraform plan --out tf.plan
    terraform apply --auto-approve tf.plan

Wait for the process to complete. Once complete use the IP address and update your (sub)domain with the address.

    test.davidjeddy.com 1.2.3.4

Wait for the TTL (time to live) to refresh. You should be able to visit the site via the URL.

#### For HTTP/2

 - HTTP/2 req. SSL; ssh into the traffic_target instance and execute the /root/ssl_install.sh to generate a cert.
 - Ensure port 443 is open, Terraform does not support Lightsail pot management as of the time of writing.


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

If you want to be able to download the generated reports, execute the following command.

    chmod -R 0755 ./results && chown -R ubuntu:ubuntu ./results && cp -rf /root/results  /home/ubuntu
   
the reports are then available at /home/ubuntu/results and owned by the ubuntu (ssh-able) user.

### Retrieve Data

From you local machine use SCP to download the generated reports.

    scp -r -i ./configs/shared/http2_effectiveness.pem  ubuntu@TRAFFIC_SOURCE_IP:/home/ubuntu/results .

Reports should be available under ./results directory.

### Tear down

To remove the services run the following command in both the traffic_target_* and traffic_source directories.

    terraform destroy -auto-approve
