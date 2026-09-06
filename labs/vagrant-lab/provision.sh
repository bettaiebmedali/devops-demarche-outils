#!/bin/bash

apt-get update
apt-get install -y nginx

echo "<h1>Serveur Web provisionné avec Vagrant</h1>" > /var/www/html/index.html
