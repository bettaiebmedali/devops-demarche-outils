#!/bin/bash

apt-get update

apt-get install -y nginx
apt-get install -y git
apt-get install -y php-fpm

rm -f /var/www/html/index.nginx-debian.html

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Serveur Vagrant</title>
</head>
<body>
    <h1>Application déployée automatiquement</h1>
    <p>Serveur provisionné avec Vagrant.</p>
</body>
</html>
EOF

systemctl restart nginx
