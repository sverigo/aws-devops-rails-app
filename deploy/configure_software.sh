#!/bin/bash

export DATABASE_ROOT_PASSWORD=$(aws ssm get-parameter --name RAILS-DATABASE-ROOT-PASSWORD --with-decryption --query 'Parameter.Value' --output text)
export DATABASE_HOST=$(aws cloudformation describe-stacks --query 'Stacks[?contains(StackId,`rails-stack`)]|[0].Outputs[?contains(OutputKey,`RDSAddress`)]|[].OutputValue' --output text)

sudo sed -i s/SED_REPLACE_DATABASE_ROOT_PASSWORD/$DATABASE_ROOT_PASSWORD/g /var/www/rails-app/config/database.yml
sudo sed -i s/SED_REPLACE_DATABASE_HOST/$DATABASE_HOST/g /var/www/rails-app/config/database.yml

cd /var/www/rails-app
bundle install
sudo chmod -R 777 /var/www/rails-app

sudo service nginx restart