#!/bin/bash
cd ~/

# create swap
# Source: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-18-04
# Per source, swap is NOT recommended on SSD drives. but Gatling needs it
echo "Creating swap file of 256Mb..."
dd if=/dev/zero of=/swapfile bs=1M count=256
mkswap /swapfile
chmod 600 /swapfile
swapon /swapfile
echo 'echo "/swapfile  none  swap  defaults  0  0" >> /etc/fstab' | sudo sh
free -m

# @source https://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
add-apt-repository -y ppa:webupd8team/java
apt-get update -y
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
apt-get install -y oracle-java8-installer

echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle"''' >> /etc/environment

wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.0.0/gatling-charts-highcharts-bundle-3.0.0-bundle.zip
unzip gatling-charts-highcharts-bundle-3.0.0-bundle.zip
echo 'GATLING_HOME="/root/gatling-charts-highcharts-bundle-3.0.0"' >> /etc/environment

mkdir -p ./results

chown -R 0777 ./results
