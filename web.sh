#!/bin/bash
sudo su
yum update -y
yum install -y httpd
cd /var/www/html
wget https://github.com/Rupagowthaman/DevOps/archive/refs/heads/main.zip
sudo unzip main.zip
cp -r DevOps-main/* /var/www/html/
rm -rf DevOps-main main.zip
systemctl start httpd
systemctl enable httpd





