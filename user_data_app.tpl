#!/bin/bash
sudo apt update -y &&
sudo apt install mysql-server -y 
sudo systemctl start mysql.service 
sudo apt install curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash 
source ~/.bashrc 
nvm install v20.18.0 
npm install -g pm2 
# Copy app-tier from local device to aws s3 bucket
# aws s3 cp ./app-tier s3://demo-bucket/application/ --recursive
# Copy app-tier from aws s3 bucket to ec2 instance
# aws s3 cp s3://demo-bucket/application/app-tier/ app-tier --recursive
# cd app-tier
# pm2 start index.js
# pm2 startup
# Run the command that pops up on your screen and then run 'pm2' save to save the configuration
