#!/usr/bin/env bash
# Основан на https://github.com/betawax/vagrant MIT Lisence

# ==============================================================================
# Vagrant
# ==============================================================================

# Sanity Check 👊🏻
if [ "$1" != "Vagrant" ]; then
  echo "The provisioning script should not be called directly!"
  exit 1
fi

# Passed Properties
PROJECT_SLUG=$2
DOCUMENT_ROOT=$3

# ==============================================================================
# System
# ==============================================================================

# We are no humans 🧟‍♂️
export DEBIAN_FRONTEND=noninteractive

# Locales
# apt-get install -y language-pack-de

# Common Tools
# apt-get install -y git

# Aliases
echo "alias artisan=\"php artisan\"" >> /home/vagrant/.bash_aliases

# ==============================================================================
# PHP
# ==============================================================================

# PHP 7.3 Repository
add-apt-repository -y ppa:ondrej/php
apt-get update

# Common Extensions
apt-get install -y php7.3-cli
apt-get install -y php7.3-curl
apt-get install -y php7.3-gd
apt-get install -y php7.3-json
apt-get install -y php7.3-mbstring
apt-get install -y php7.3-mysql
apt-get install -y php7.3-tidy
apt-get install -y php7.3-xml
# me added
apt-get install -y php7.3-zip
apt-get install -y unzip
apt-get install -y php7.3-intl


# Set the default timezone to UTC
# sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php/7.3/cli/php.ini

# ==============================================================================
# Apache
# ==============================================================================

# Default VHost
# $PROJECT_SLUG.local должен быть прописан в hosts Windows
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerName $PROJECT_SLUG.local
    DocumentRoot /var/www/$PROJECT_SLUG/$DOCUMENT_ROOT
    <Directory /var/www/$PROJECT_SLUG/$DOCUMENT_ROOT>
        AllowOverride All
    </Directory>
</VirtualHost>
EOF
)

# Default SSL VHost
#VHOST_SSL=$(cat <<EOF
#<VirtualHost *:443>
#    ServerName $PROJECT_SLUG.local
#    DocumentRoot /var/www/$PROJECT_SLUG/$DOCUMENT_ROOT
#    <Directory /var/www/$PROJECT_SLUG/$DOCUMENT_ROOT>
#        AllowOverride All
#    </Directory>
#    SSLEngine on
#    SSLCertificateFile /etc/ssl/$PROJECT_SLUG.crt
#    SSLCertificateKeyFile /etc/ssl/$PROJECT_SLUG.key
#</VirtualHost>
#EOF
#)

# Apache 2 & Mod PHP
apt-get install -y apache2
apt-get install -y libapache2-mod-php7.3

# Common Mods
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod ssl

# Create a self-signed SSL certificate
#openssl req -x509 -sha256 -newkey rsa:2048 -nodes -keyout /etc/ssl/$PROJECT_SLUG.key -out /etc/ssl/$PROJECT_SLUG.crt -days 365 -subj "/CN=$PROJECT_SLUG.local"

# Clean up
rm -f /etc/apache2/sites-available/*
rm -f /etc/apache2/sites-enabled/*
rm -rf /var/www/html

# Create and enable the default VHosts
echo "$VHOST" > /etc/apache2/sites-available/default.conf
#echo "$VHOST_SSL" > /etc/apache2/sites-available/default-ssl.conf
ln -fs /etc/apache2/sites-available/default.conf /etc/apache2/sites-enabled/default.conf
#ln -fs /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

# Set the default timezone to UTC and increase upload_max_filesize
#sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php/7.3/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 32M/" /etc/php/7.3/apache2/php.ini

# Please Apache 🙄
printf "\n\nServerName $PROJECT_SLUG" >> /etc/apache2/apache2.conf
service apache2 restart

# ==============================================================================
# MySQL
# ==============================================================================

# MySQL 5.7 Repository
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 5072E1F5
echo "deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7" >> /etc/apt/sources.list.d/mysql.list
apt-get update

# Pre-configure MySQL for a silent install
debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password"
debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password"

# MySQL
apt-get install -y mysql-server

# Allow remote database connections
sed -i "s/bind-address\t= 127.0.0.1/bind-address\t= 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart

# Get the host address to grant remote access to
HOST=$(ifconfig eth1 | grep "inet addr" | awk -F : '{print $2}' | awk '{print $1}' | sed "s/.[0-9]*$/.%/")

# Сразу создаётся база данных
# Create a UTF8 database
mysql -u root -e "CREATE DATABASE $PROJECT_SLUG DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;"
# Под Laravel и Workbench должно быть:
#                 CREATE SCHEMA `poligon`       DEFAULT CHARACTER SET utf8mb4         COLLATE utf8mb4_unicode_ci; 

# Create a database user
mysql -u root -e "GRANT ALL ON $PROJECT_SLUG.* TO '$PROJECT_SLUG'@'localhost' IDENTIFIED BY '$PROJECT_SLUG';"
mysql -u root -e "GRANT ALL ON $PROJECT_SLUG.* TO '$PROJECT_SLUG'@'$HOST' IDENTIFIED BY '$PROJECT_SLUG';"
mysql -u root -e "FLUSH PRIVILEGES;"

# ==============================================================================
# Postfix
# ==============================================================================

# Pre-configure Postfix for a silent install
#debconf-set-selections <<< "postfix postfix/mailname string $PROJECT_SLUG.local"
#debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Postfix
#apt-get install -y postfix

# ==============================================================================
# Package Managers
# ==============================================================================

# Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Node & NPM
#curl -sL https://deb.nodesource.com/setup_10.x | bash
#apt-get install -y nodejs

# ==============================================================================
# ==============================================================================
