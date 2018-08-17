#!/bin/bash

sudo chmod -R 777 /var/www/rails-app
cd /var/www/rails-app

export DATABASE_ROOT_PASSWORD=$(aws ssm get-parameter --name RAILS-DATABASE-ROOT-PASSWORD --with-decryption --query 'Parameter.Value' --output text --region us-west-2)
export DATABASE_HOST=$(aws cloudformation describe-stacks --query 'Stacks[?contains(StackId,`rails-stack`)]|[0].Outputs[?contains(OutputKey,`RDSAddress`)]|[].OutputValue' --output text --region us-west-2)

sudo sed -i s/SED_REPLACE_DATABASE_ROOT_PASSWORD/$DATABASE_ROOT_PASSWORD/g /var/www/rails-app/config/database.yml
sudo sed -i s/SED_REPLACE_DATABASE_HOST/$DATABASE_HOST/g /var/www/rails-app/config/database.yml

bundle install

# bundle exec rake db:migrate


sudo service nginx restart