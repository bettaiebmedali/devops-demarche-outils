# Lab Vagrant

## Objectifs du Lab
- Installer Vagrant et VirtualBox (ou tout autre provider de machines virtuelles).
- Créer une machine virtuelle simple avec Vagrant.
- Gérer la machine virtuelle avec les commandes de base Vagrant.
- Configurer une machine virtuelle via le Vagrantfile.
- Provisions de base (ex. : installation de packages via shell script).

## Prérequis
- Avoir Vagrant installé
- Avoir VirtualBox installé

## Étapes du Lab

### 1. Initialisation d'un projet Vagrant

1. Créez un répertoire pour votre projet Vagrant :
```bash
mkdir vagrant-lab && cd vagrant-lab
```

2. Initialisez Vagrant dans ce répertoire :
```bash
vagrant init
```

3. Modifiez le fichier `Vagrantfile` pour utiliser une box Ubuntu :
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
end
```

### 2. Démarrer la machine virtuelle

1. Démarrez la machine virtuelle :
```bash
vagrant up
```

2. Vérifiez le statut de la machine :
```bash
vagrant status
```

3. Connectez-vous via SSH :
```bash
vagrant ssh
```

4. Explorez l'environnement avec des commandes Linux de base (`ls`, `whoami`, etc).

### 3. Arrêter, redémarrer et détruire la machine

1. Arrêtez la machine virtuelle :
```bash
vagrant halt
```

2. Redémarrez la machine :
```bash
vagrant up
```

3. Détruisez la machine (optionnel) :
```bash
vagrant destroy
```

### 4. Provisions avec un script shell

1. Ajoutez un provisionnement simple (installation de Nginx par exemple) :
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y nginx
  SHELL
end
```

2. Démarrez la machine avec provisionnement :
```bash
vagrant up --provision
```

3. Vérifiez que Nginx est bien installé :
```bash
vagrant ssh
sudo systemctl status nginx
```

### 5. Partage de répertoires

1. Partagez un répertoire entre l'hôte et la VM :
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.synced_folder "./data", "/vagrant_data"
end
```

2. Créez un répertoire local `data` :
```bash
mkdir data
```

3. Redémarrez la machine :
```bash
vagrant up
```

4. Vérifiez le partage dans la VM :
```bash
vagrant ssh
ls /vagrant_data
```


# Exercices Vagrant — Provisionnement et automatisation

## 6. Provisionnement avec un script externe

Jusqu'à présent, le script Shell était directement écrit dans le `Vagrantfile`.

Dans cet exercice, vous allez externaliser le script dans un fichier `.sh`.

### Objectif

Installer automatiquement Nginx et créer une page Web personnalisée.

### 1. Créez le fichier `provision.sh`

```bash
touch provision.sh
```

Ajoutez le contenu suivant :

```bash
#!/bin/bash

apt-get update
apt-get install -y nginx

echo "<h1>Serveur Web provisionné avec Vagrant</h1>" > /var/www/html/index.html
```

### 2. Rendez le script exécutable

```bash
chmod +x provision.sh
```

### 3. Modifiez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provision "shell", path: "provision.sh"
end
```

### 4. Démarrez la machine

```bash
vagrant up
```

### 5. Lancez le provisionnement manuellement

```bash
vagrant provision
```

### 6. Vérifiez le résultat

Connectez-vous à la VM :

```bash
vagrant ssh
```

Vérifiez que Nginx fonctionne :

```bash
sudo systemctl status nginx
```

Vérifiez la page Web :

```bash
curl http://localhost
```

### Question

Pourquoi est-il préférable de placer un script de provisionnement dans un fichier séparé plutôt que directement dans le `Vagrantfile` ?

---

## 7. Configuration réseau et accès à Nginx

Dans cet exercice, vous allez configurer une adresse IP privée afin d'accéder au serveur Web depuis la machine hôte.

### Objectif

Configurer la VM avec l'adresse IP :

```text
192.168.56.10
```

et rendre Nginx accessible depuis l'hôte.

### 1. Modifiez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y nginx

    echo "<h1>Hello depuis Vagrant</h1>" > /var/www/html/index.html
  SHELL
end
```

### 2. Démarrez la machine

```bash
vagrant up
```

### 3. Vérifiez l'adresse IP

Depuis la VM :

```bash
ip addr
```

Vous devez retrouver :

```text
192.168.56.10
```

### 4. Testez Nginx depuis la VM

```bash
curl http://192.168.56.10
```

### 5. Testez depuis la machine hôte

```bash
curl http://192.168.56.10
```

### Question

Quelle est la différence entre :

```ruby
config.vm.network "private_network"
```

et :

```ruby
config.vm.network "public_network"
```

---

## 8. Déploiement automatique d'une application Web

Vous allez maintenant utiliser Vagrant pour préparer automatiquement un serveur Web.

### Objectif

Installer :

- Nginx
- Git
- PHP

et déployer automatiquement une page Web.

### 1. Créez un script

```bash
touch webserver.sh
```

### 2. Ajoutez le contenu suivant

```bash
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
```

### 3. Rendez le script exécutable

```bash
chmod +x webserver.sh
```

### 4. Configurez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.vm.provision "shell", path: "webserver.sh"
end
```

### 5. Lancez le provisionnement

```bash
vagrant up
```

Si la machine existe déjà :

```bash
vagrant provision
```

### 6. Testez le serveur

```bash
curl http://192.168.56.10
```

---

## 9. Plusieurs machines virtuelles

Jusqu'à présent, vous avez travaillé avec une seule VM.

Dans cet exercice, vous allez créer deux machines :

- un serveur Web ;
- un serveur Database.

### Objectif

Créer l'architecture suivante :

```text
                    Host
                     |
          +----------+----------+
          |                     |
     Web Server             DB Server
  192.168.56.10          192.168.56.11
      Nginx                 MySQL
```

### 1. Créez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/bionic64"

    web.vm.hostname = "web"

    web.vm.network "private_network",
      ip: "192.168.56.10"

    web.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y nginx

      echo "<h1>Web Server</h1>" > /var/www/html/index.html
    SHELL
  end

  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/bionic64"

    db.vm.hostname = "db"

    db.vm.network "private_network",
      ip: "192.168.56.11"

    db.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y mysql-server
    SHELL
  end

end
```

### 2. Démarrez les deux machines

```bash
vagrant up
```

### 3. Listez les machines

```bash
vagrant status
```

Vous devez avoir :

```text
web    running
db     running
```

### 4. Connectez-vous au serveur Web

```bash
vagrant ssh web
```

Vérifiez Nginx :

```bash
sudo systemctl status nginx
```

### 5. Connectez-vous au serveur Database

```bash
vagrant ssh db
```

Vérifiez MySQL :

```bash
sudo systemctl status mysql
```

### 6. Testez la communication

Depuis le serveur Web :

```bash
ping 192.168.56.11
```

### Question

Pourquoi est-il intéressant de séparer le serveur Web et le serveur Database dans deux machines différentes ?

---

## 10. Provisionnement différent selon le rôle de la machine

Dans l'exercice précédent, chaque machine possède un rôle différent.

Vous allez maintenant organiser le projet avec plusieurs scripts.

### Objectif

Créer l'organisation suivante :

```text
vagrant-project/
│
├── Vagrantfile
│
└── scripts/
    ├── web.sh
    └── db.sh
```

### 1. Créez les répertoires

```bash
mkdir -p scripts
```

### 2. Créez le script Web

```bash
touch scripts/web.sh
```

Ajoutez :

```bash
#!/bin/bash

apt-get update
apt-get install -y nginx

echo "<h1>Web Server</h1>" > /var/www/html/index.html
```

### 3. Créez le script Database

```bash
touch scripts/db.sh
```

Ajoutez :

```bash
#!/bin/bash

apt-get update
apt-get install -y mysql-server
```

### 4. Modifiez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|

    web.vm.box = "ubuntu/bionic64"

    web.vm.hostname = "web"

    web.vm.network "private_network",
      ip: "192.168.56.10"

    web.vm.provision "shell",
      path: "scripts/web.sh"

  end

  config.vm.define "db" do |db|

    db.vm.box = "ubuntu/bionic64"

    db.vm.hostname = "db"

    db.vm.network "private_network",
      ip: "192.168.56.11"

    db.vm.provision "shell",
      path: "scripts/db.sh"

  end

end
```

### 5. Démarrez les machines

```bash
vagrant up
```

### 6. Vérifiez les services

```bash
vagrant ssh web
sudo systemctl status nginx
```

Puis :

```bash
vagrant ssh db
sudo systemctl status mysql
```

---

## 11. Utilisation de variables dans le Vagrantfile

Dans cet exercice, vous allez éviter de répéter les informations de configuration.

### Objectif

Définir une variable contenant la version de la box et les adresses IP.

### 1. Modifiez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  BOX = "ubuntu/bionic64"

  WEB_IP = "192.168.56.10"
  DB_IP  = "192.168.56.11"

  config.vm.define "web" do |web|

    web.vm.box = BOX

    web.vm.hostname = "web"

    web.vm.network "private_network",
      ip: WEB_IP

    web.vm.provision "shell",
      path: "scripts/web.sh"

  end

  config.vm.define "db" do |db|

    db.vm.box = BOX

    db.vm.hostname = "db"

    db.vm.network "private_network",
      ip: DB_IP

    db.vm.provision "shell",
      path: "scripts/db.sh"

  end

end
```

### 2. Testez la configuration

```bash
vagrant destroy -f
```

Puis :

```bash
vagrant up
```

### Question

Quels sont les avantages de l'utilisation de variables dans un `Vagrantfile` ?

---

## 12. Configuration d'un serveur avec un fichier de configuration

Dans cet exercice, vous allez générer automatiquement un fichier de configuration Nginx.

### Objectif

Configurer Nginx avec un Virtual Host.

### 1. Créez le script

```bash
touch scripts/nginx.sh
```

### 2. Ajoutez le contenu

```bash
#!/bin/bash

apt-get update
apt-get install -y nginx

cat > /etc/nginx/sites-available/vagrant <<EOF
server {
    listen 80;

    server_name vagrant.local;

    root /var/www/vagrant;

    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

mkdir -p /var/www/vagrant

echo "<h1>Vagrant Web Application</h1>" > /var/www/vagrant/index.html

ln -sf /etc/nginx/sites-available/vagrant \
       /etc/nginx/sites-enabled/vagrant

rm -f /etc/nginx/sites-enabled/default

nginx -t

systemctl restart nginx
```

### 3. Rendez le script exécutable

```bash
chmod +x scripts/nginx.sh
```

### 4. Configurez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network",
    ip: "192.168.56.10"

  config.vm.provision "shell",
    path: "scripts/nginx.sh"

end
```

### 5. Lancez la VM

```bash
vagrant up
```

### 6. Vérifiez la configuration Nginx

```bash
vagrant ssh
```

Puis :

```bash
sudo nginx -t
```

### 7. Vérifiez le site

```bash
curl http://192.168.56.10
```

---

## 13. Provisionnement avec plusieurs étapes

Dans cet exercice, vous allez séparer le provisionnement en plusieurs étapes.

### Objectif

Installer :

1. les paquets système ;
2. Nginx ;
3. l'application.

### 1. Modifiez le `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network",
    ip: "192.168.56.10"

  config.vm.provision "shell",
    inline: <<-SHELL

      apt-get update

      apt-get install -y curl git

    SHELL

  config.vm.provision "shell",
    inline: <<-SHELL

      apt-get install -y nginx

    SHELL

  config.vm.provision "shell",
    inline: <<-SHELL

      echo "<h1>Application Vagrant</h1>" \
        > /var/www/html/index.html

    SHELL

end
```

### 2. Lancez le provisionnement

```bash
vagrant up
```

### 3. Relancez uniquement le provisionnement

```bash
vagrant provision
```

### Question

Pourquoi peut-il être intéressant de séparer le provisionnement en plusieurs étapes ?

---

## 14. Provisionnement conditionnel

Vous allez maintenant rendre le provisionnement plus intelligent.

### Objectif

Installer Nginx uniquement s'il n'est pas déjà installé.

### 1. Modifiez le script

```bash
#!/bin/bash

if ! command -v nginx >/dev/null 2>&1
then

    echo "Installation de Nginx..."

    apt-get update
    apt-get install -y nginx

else

    echo "Nginx est déjà installé."

fi
```

### 2. Ajoutez une page Web

```bash
echo "<h1>Serveur provisionné</h1>" \
  > /var/www/html/index.html
```

### 3. Testez

```bash
vagrant provision
```

Puis :

```bash
vagrant provision
```

### Question

Que remarquez-vous lors de la deuxième exécution ?

### Objectif pédagogique

Comprendre la notion d'**idempotence** dans les outils d'automatisation.

---

## 15. Projet final — Infrastructure Web complète

Vous allez maintenant combiner les concepts précédents.

### Objectif

Créer automatiquement une infrastructure composée de :

```text
                         HOST
                          |
             +------------+------------+
             |                         |
        WEB SERVER                 DB SERVER
      192.168.56.10              192.168.56.11
             |                         |
           Nginx                     MySQL
             |
       Web Application
```

### Architecture du projet

Créez l'arborescence :

```text
vagrant-project/
│
├── Vagrantfile
│
├── scripts/
│   ├── web.sh
│   └── db.sh
│
└── data/
```

### 1. Créez le répertoire

```bash
mkdir -p vagrant-project/scripts
mkdir -p vagrant-project/data
```

### 2. Configurez le serveur Web

Le fichier `scripts/web.sh` doit :

- installer Nginx ;
- installer Git ;
- créer `/var/www/app` ;
- créer une page Web ;
- démarrer Nginx ;
- vérifier que Nginx fonctionne.

### 3. Configurez le serveur Database

Le fichier `scripts/db.sh` doit :

- installer MySQL ;
- démarrer MySQL ;
- vérifier son état ;
- afficher la version de MySQL.

### 4. Configurez le `Vagrantfile`

Le `Vagrantfile` doit :

- créer une VM `web` ;
- créer une VM `db` ;
- attribuer une adresse IP privée à chaque VM ;
- utiliser un script différent pour chaque VM ;
- partager le répertoire `data` avec le serveur Web.

### 5. Démarrez l'infrastructure

```bash
vagrant up
```

### 6. Vérifiez les machines

```bash
vagrant status
```

### 7. Vérifiez le serveur Web

```bash
vagrant ssh web
```

Puis :

```bash
sudo systemctl status nginx
```

Testez :

```bash
curl http://192.168.56.10
```

### 8. Vérifiez le serveur Database

```bash
vagrant ssh db
```

Puis :

```bash
sudo systemctl status mysql
```

Vérifiez la version :

```bash
mysql --version
```

### 9. Testez la communication entre les serveurs

Depuis `web` :

```bash
ping 192.168.56.11
```

### 10. Vérifiez le répertoire partagé

Depuis `web` :

```bash
ls /vagrant_data
```

---

## 16. Challenge — Infrastructure multi-services

Pour aller plus loin, transformez le projet précédent en une infrastructure composée de **trois machines** :

```text
                         HOST
                           |
              +------------+------------+
              |            |            |
             WEB          APP           DB
             |             |             |
           Nginx       Application      MySQL
        192.168.56.10 192.168.56.20  192.168.56.30
```

### Contraintes

Le projet doit respecter les règles suivantes :

1. Chaque machine doit avoir un hostname différent.
2. Chaque machine doit avoir une adresse IP privée différente.
3. Chaque machine doit utiliser son propre script de provisionnement.
4. Le serveur Web doit installer Nginx.
5. Le serveur DB doit installer MySQL.
6. Le serveur APP doit installer les outils nécessaires à l'application.
7. Les trois machines doivent pouvoir communiquer entre elles.
8. Le répertoire `data` de l'hôte doit être partagé avec le serveur Web.
9. Le provisionnement doit être relançable sans provoquer d'erreurs.
10. Le projet doit pouvoir être entièrement recréé avec :

```bash
vagrant destroy -f
vagrant up
```

### Question finale

Quelle serait l'organisation idéale du projet si vous deviez gérer :

- 3 environnements ;
- 10 machines virtuelles ;
- plusieurs versions de logiciels ;
- plusieurs développeurs ?

Réfléchissez notamment à l'utilisation de :

- scripts Shell ;
- variables ;
- fichiers de configuration ;
- Ansible ;
- Terraform ;
- Docker ;
- Kubernetes.
