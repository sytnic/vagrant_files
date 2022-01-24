#!/usr/bin/env bash
# Основан на https://github.com/betawax/vagrant MIT Lisence

# В этом файле 
# используется вложенная папка DOCUMENT_ROOT
# и устанавливается:
# - Apache, без ssl .


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
# чтобы инсталлировать несколько пакетов в Debian/Ubuntu Linux «без лишних вопросов»
export DEBIAN_FRONTEND=noninteractive

# Locales

# Common Tools

# Aliases artisan=\"php artisan\"

# ==============================================================================
# PHP
# ==============================================================================

# PHP 7.3 Repository

# Common Extensions


# me added
apt-get update # обязательно
apt-get install -y unzip 
# -y обязательно
# (автоматический ответ Yes на [Y/N]?)


# Set the default timezone to UTC in php.ini

# ==============================================================================
# Apache
# ==============================================================================

# Default VHost
# константа VHOST, используется далее
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
# -y обязательно 
# (автоматический ответ Yes на [Y/N]?)

# apt-get install -y libapache2-mod-php7.3

# Common Mods
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod ssl

# Create a self-signed SSL certificate
#openssl req -x509 -sha256 -newkey rsa:2048 -nodes -keyout /etc/ssl/$PROJECT_SLUG.key -out /etc/ssl/$PROJECT_SLUG.crt -days 365 -subj "/CN=$PROJECT_SLUG.local"

# Чистка
# Clean up
# Удаление файлов и ссылок по умолчанию: 000-default.conf  default-ssl.conf
# apache, вероятно, подхватывает в порядке важности:
# - файл, именнованный как сайт
# - файл  default.conf
# - файл  000-default.conf

# rm -f /etc/apache2/sites-available/*
# rm -f /etc/apache2/sites-enabled/*
# папка апача
# rm -rf /var/www/html

# Файлы настроек и ссылки
# Create and enable the default VHosts
# Запись в файл
echo "$VHOST" > /etc/apache2/sites-available/default.conf
#echo "$VHOST_SSL" > /etc/apache2/sites-available/default-ssl.conf
ln -fs /etc/apache2/sites-available/default.conf /etc/apache2/sites-enabled/default.conf
#ln -fs /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

# Set the default timezone to UTC and increase upload_max_filesize in php.ini

# Please Apache 🙄
# Запись в файл
printf "\n\nServerName $PROJECT_SLUG" >> /etc/apache2/apache2.conf
systemctl restart apache2
# или systemctl restart apache2
# или service apache2 restart

# ==============================================================================
# MySQL
# ==============================================================================

# MySQL 5.7 Repository

# Pre-configure MySQL for a silent install

# MySQL

# Allow remote database connections

# Get the host address to grant remote access to

# Сразу создаётся база данных
# Create a UTF8 database 

# Create a database user

# ==============================================================================
# Postfix
# ==============================================================================

# Pre-configure Postfix for a silent install

# Postfix

# ==============================================================================
# Package Managers
# ==============================================================================

# Composer

# Node & NPM

# ==============================================================================
# ==============================================================================
