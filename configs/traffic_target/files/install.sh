#!/bin/bash

# install wordpress files
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp ./wordpress/wp-config-sample.php ./wordpress/wp-config.php
rm -rf /var/www/html
mv ./wordpress /var/www/html

# Place current IP in dump.SQL, CHANGE THIS TO MATCH YOUR DOMAIN.
sed -i "s/CURRENT_IP/test\.davidjeddy\.com/g" /root/dump.sql

# setup MySQL database user
sudo mysql -uroot -proot -hlocalhost -e "DROP DATABASE IF EXISTS database_name_here; CREATE DATABASE database_name_here;  GRANT ALL PRIVILEGES ON *.* TO 'username_here'@'localhost' IDENTIFIED BY '2!3swZ$NVO(wcigcw('; FLUSH PRIVILEGES;"

# import SQL DB
mysql -uroot -proot database_name_here < /root/dump.sql

# unzip content images into WP root
unzip /root/wp-content.zip
cp -r ./wp-content /var/www/html/

# Change www properties
chmod -R 0755 /var/www/html
chown -R www-data:www-data /var/www/html

# install SSL certification
add-apt-repository -y ppa:certbot/certbot
apt install -y python-certbot-nginx

certbot \
   --agree-tos \
   --non-interactive \
   --nginx \
   --rsa-key-size 4096 \
   --email test@email.com \
   --webroot-path /var/www/html \
   --domains "test.davidjeddy.com"

sed -i "s/443 ssl/443 ssl http2/g" /etc/nginx/sites-available/default

# restart services to take new configurations
service php-fpm restart
service mysql restart
service nginx restart
