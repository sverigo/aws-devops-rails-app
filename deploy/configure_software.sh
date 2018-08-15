#!/bin/bash

# hosts config update

IP=$(echo $(hostname -I) | sed 's/\./-/g')
IP='127.0.1.1 ip-'$IP
sudo sh -c "echo $IP >> /etc/hosts"

# ruby install

sudo apt-get update
sudo apt-get install -y build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
sudo apt-get install -y libpq-dev
sudo apt-get install -y ruby-full

# nginx and passenger install

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main' >> /etc/apt/sources.list.d/passenger.list"

sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list

sudo apt-get update

sudo apt-get install -y nginx-extras passenger

# nginx with passenger config update

sudo sed -i '/passenger.conf/a \\tpassenger_ruby /usr/bin/ruby;' /etc/nginx/nginx.conf
sudo sed -i '/passenger.conf/a \\tpassenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;' /etc/nginx/nginx.conf

sudo service nginx restart




sudo sed -i '/listen 80 default_server;/d' /etc/nginx/sites-available/default
sudo sed -i '/listen [::]:80 default_server ipv6only=on;/d' /etc/nginx/sites-available/default

sudo sh -c "echo ' server {
  listen 80 default_server;
  passenger_enabled on;
  passenger_app_env development;
  root /var/www/rails-app/public;
}' > /etc/nginx/sites-available/rails-app"

sudo ln -s /etc/nginx/sites-available/rails-app /etc/nginx/sites-enabled/rails-app

sudo service nginx restart

export DATABASE_ROOT_PASSWORD=$(aws ssm get-parameter --name RAILS-DATABASE-ROOT-PASSWORD --with-decryption --query 'Parameter.Value' --output text)
export DATABASE_HOST=$(aws cloudformation describe-stacks --query 'Stacks[?contains(StackId,`rails-stack`)]|[0].Outputs[?contains(OutputKey,`RDSAddress`)]|[].OutputValue' --output text)

sudo sed -i s/SED_REPLACE_DATABASE_ROOT_PASSWORD/$DATABASE_ROOT_PASSWORD/g /var/www/rails-app/config/database.yml
sudo sed -i s/SED_REPLACE_DATABASE_HOST/$DATABASE_HOST/g /var/www/rails-app/config/database.yml

sudo service nginx restart