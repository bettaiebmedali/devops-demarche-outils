#!/bin/bash

apt-get update
apt-get install -y nginx

echo "<h1>Web Server</h1>" > /var/www/html/index.html
