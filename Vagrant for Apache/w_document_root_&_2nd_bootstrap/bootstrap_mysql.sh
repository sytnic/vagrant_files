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
# ==============================================================================
