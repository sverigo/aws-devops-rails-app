#!/bin/bash

export DATABASE_ROOT_PASSWORD=$(aws ssm get-parameter --name RAILS-DATABASE-ROOT-PASSWORD --with-decryption --query 'Parameter.Value' --output text)
export DATABASE_HOST=$(aws cloudformation describe-stacks --query 'Stacks[?contains(StackId,`rails-stack`)]|[0].Outputs[?contains(OutputKey,`RDSAddress`)]|[].OutputValue' --output text)

# hosts config update

IP=$(echo $(hostname -I) | sed 's/\./-/g')
IP='127.0.1.1 ip-'$IP
sudo sh -c "echo $IP >> /etc/hosts"

# ruby install

sudo apt-get update
sudo apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
sudo apt-get install ruby-full

# nginx and passenger install

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main' >> /etc/apt/sources.list.d/passenger.list"

sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list

sudo apt-get update

sudo apt-get install nginx-extras passenger

# nginx with passenger config update

sudo sed -i '/passenger.conf/a \\tpassenger_ruby /usr/bin/ruby;' /etc/nginx/nginx.conf
sudo sed -i '/passenger.conf/a \\tpassenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;' /etc/nginx/nginx.conf
sudo service nginx restart