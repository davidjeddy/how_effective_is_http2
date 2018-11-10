#!/bin/bash
add-apt-repository -y ppa:certbot/certbot
apt install -y python-certbot-nginx

certbot \
   --agree-tos \
   --non-interactive \
   --nginx \
   --rsa-key-size 4096 \
   --email test@email.com \
   --webroot-path /var/www/html \
   --domains "http2effectiveness.davidjeddy.com"

service nginx reload
