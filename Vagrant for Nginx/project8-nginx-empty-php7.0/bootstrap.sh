#!/bin/bash

# Using single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='vagrant'
PROJECTFOLDER='html'

# create project folder
sudo mkdir "/var/www/${PROJECTFOLDER}"

# update / upgrade
echo "Updating apt-get..."
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y upgrade > /dev/null 2>&1

# install git
echo "Installing Git..."
sudo apt-get install -y git > /dev/null 2>&1

# install nginx
echo "Installing Nginx..."
sudo apt-get install -y nginx > /dev/null 2>&1

# install php7-fpm
echo "Installing PHP..."
sudo apt-get install -y php-fpm php-mysql php-xml php-gd php7.0-zip > /dev/null 2>&1

# install mariadb and give password to installer
echo "Preparing MariaDB..."
sudo apt-get install -y debconf-utils > /dev/null 2>&1
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu xenial main'

echo "Updating apt-get..."
sudo apt-get update > /dev/null 2>&1
 
echo "Installing MariaDB..."
sudo apt-get install -y mariadb-server

# Nginx Config
echo "Configuring Nginx..."
sudo cp /var/www/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null 2>&1
sudo ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/

sudo rm -rf /etc/nginx/sites-enabled/default

# Restarting Nginx for config to take effect
echo "Restarting Nginx..."
sudo service nginx restart > /dev/null 2>&1