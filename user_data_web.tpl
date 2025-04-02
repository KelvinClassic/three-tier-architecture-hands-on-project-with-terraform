#!/bin/bash
sudo apt update -y
sudo apt install curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install v20.18.0
sudo apt install nginx
# Copy web-tier from local device to aws s3 bucket
# aws s3 cp ./web-tier s3://demo-bucket/application/ --recursive
# Copy web-tier from aws s3 bucket to ec2 instance
# aws s3 cp s3://demo-bucket/application/web-tier/ web-tier --recursive
# Copy nginx.conf file from local device to aws s3 bucket
# aws s3 cp ./nginx.conf s3://demo-bucket/application/
# cd web-tier
# npm install
# npm run build
# cd /etc/nginx
# Copy nginx.conf file from s3 to current directory
# sudo aws s3 cp s3://demo-bucket/application/nginx.conf .
# sudo systemctl restart nginx.service