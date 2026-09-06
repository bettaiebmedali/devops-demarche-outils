# TP — Vagrant avec Docker Provider

## Objectifs

Dans ce TP, nous allons utiliser **Vagrant avec Docker comme provider** afin de créer et gérer des environnements de développement.

À la fin du TP, vous serez capable de :

- Initialiser un projet Vagrant.
- Configurer Vagrant avec Docker comme provider.
- Utiliser une image Ubuntu.
- Démarrer et arrêter un environnement.
- Se connecter avec `vagrant ssh`.
- Configurer le hostname.
- Configurer les ports.
- Utiliser le provisioning.
- Utiliser un dossier partagé.
- Gérer plusieurs machines avec Vagrant.
- Maîtriser le cycle de vie d'un environnement Vagrant.

---

# 1. Prérequis

Vérifier que Vagrant est installé :

```bash
vagrant --version
```

---

# 2. Créer un projet Vagrant

Créer le dossier du projet :

```bash
mkdir tp-vagrant-docker
cd tp-vagrant-docker
```

Initialiser Vagrant :

```bash
vagrant init
```

Cette commande crée le fichier :

```text
Vagrantfile
```

---

# 3. Configurer Vagrant avec Docker

Modifier le fichier `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:latest"
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

end
```

Le provider utilisé est Docker :

```ruby
config.vm.provider "docker" do |docker|
```

L'image utilisée est définie avec :

```ruby
docker.image = "ubuntu:latest"
```

L'accès SSH est activé avec :

```ruby
docker.has_ssh = true
```

La commande exécutée au démarrage est :

```ruby
docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
```

---

# 4. Démarrer l'environnement

Lancer l'environnement :

```bash
vagrant up
```

Ou préciser le provider :

```bash
vagrant up --provider=docker
```

Vérifier l'état :

```bash
vagrant status
```

---

# 5. Se connecter à l'environnement

Utiliser :

```bash
vagrant ssh
```

Tester :

```bash
whoami
```

Puis :

```bash
hostname
```

Pour quitter :

```bash
exit
```

---

# 6. Modifier le hostname

Modifier le `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "vagrant-server"

  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:latest"
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

end
```

Appliquer la modification :

```bash
vagrant reload
```

Se connecter :

```bash
vagrant ssh
```

Vérifier :

```bash
hostname
```

Résultat attendu :

```text
vagrant-server
```

---

# 7. Provisioning

Vagrant permet d'exécuter automatiquement des commandes lors de la configuration de l'environnement.

Ajouter dans le `Vagrantfile` :

```ruby
config.vm.provision "shell", inline: <<-SHELL
  echo "Bienvenue dans Vagrant"
  touch /home/vagrant/test.txt
SHELL
```

Exécuter le provisioning :

```bash
vagrant provision
```

Se connecter :

```bash
vagrant ssh
```

Vérifier :

```bash
ls /home/vagrant
```

Le fichier suivant doit exister :

```text
test.txt
```

---

# 8. Provisioning avec un script

Créer le fichier :

```text
bootstrap.sh
```

Contenu :

```bash
#!/bin/bash

echo "Configuration de la machine Vagrant"

mkdir -p /home/vagrant/project

echo "Projet Vagrant" > /home/vagrant/project/info.txt
```

Modifier le `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:latest"
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.provision "shell",
    path: "bootstrap.sh"

end
```

Exécuter :

```bash
vagrant provision
```

Puis :

```bash
vagrant ssh
```

Vérifier :

```bash
cat /home/vagrant/project/info.txt
```

---

# 9. Dossier partagé

Le dossier du projet est accessible dans l'environnement via :

```text
/vagrant
```

Se connecter :

```bash
vagrant ssh
```

Puis :

```bash
ls -la /vagrant
```

Créer un fichier :

```bash
echo "Hello Vagrant" > /vagrant/message.txt
```

Quitter :

```bash
exit
```

Sur la machine hôte :

```bash
cat message.txt
```

Résultat :

```text
Hello Vagrant
```

---

# 10. Port forwarding

Vagrant permet de rediriger un port.

Ajouter dans le `Vagrantfile` :

```ruby
config.vm.network "forwarded_port",
  guest: 80,
  host: 8080
```

La correspondance est :

```text
Machine hôte
    |
    | localhost:8080
    v
Machine Vagrant
    |
    | port 80
    v
Service
```

Appliquer la configuration :

```bash
vagrant reload
```

Le service disponible sur le port `80` de l'environnement sera accessible via le port `8080` de la machine hôte.

---

# 11. Réseau privé

Il est également possible de configurer une adresse IP privée :

```ruby
config.vm.network "private_network",
  ip: "192.168.56.10"
```

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:latest"
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.vm.network "private_network",
    ip: "192.168.56.10"

end
```

Appliquer :

```bash
vagrant reload
```

---

# 12. Plusieurs machines

Vagrant permet de gérer plusieurs environnements dans un seul `Vagrantfile`.

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|

    web.vm.hostname = "web-server"

    web.vm.provider "docker" do |docker|
      docker.image = "ubuntu:latest"
      docker.has_ssh = true
      docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
    end

  end

  config.vm.define "db" do |db|

    db.vm.hostname = "database-server"

    db.vm.provider "docker" do |docker|
      docker.image = "ubuntu:latest"
      docker.has_ssh = true
      docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
    end

  end

end
```

Démarrer les deux machines :

```bash
vagrant up
```

Afficher leur état :

```bash
vagrant status
```

Se connecter à `web` :

```bash
vagrant ssh web
```

Se connecter à `db` :

```bash
vagrant ssh db
```

Démarrer uniquement `web` :

```bash
vagrant up web
```

Arrêter uniquement `web` :

```bash
vagrant halt web
```

---

# 13. Cycle de vie Vagrant

## Initialiser

```bash
vagrant init
```

## Démarrer

```bash
vagrant up
```

## Démarrer avec Docker

```bash
vagrant up --provider=docker
```

## Vérifier l'état

```bash
vagrant status
```

## Se connecter

```bash
vagrant ssh
```

## Recharger

```bash
vagrant reload
```

## Exécuter le provisioning

```bash
vagrant provision
```

## Arrêter

```bash
vagrant halt
```

## Suspendre

```bash
vagrant suspend
```

## Reprendre

```bash
vagrant resume
```

## Détruire

```bash
vagrant destroy
```

Sans confirmation :

```bash
vagrant destroy -f
```

---

# 14. Commandes utiles

Afficher toutes les machines Vagrant :

```bash
vagrant global-status
```

Afficher les boxes disponibles :

```bash
vagrant box list
```

Afficher la version de Vagrant :

```bash
vagrant --version
```

Afficher l'aide :

```bash
vagrant --help
```

---

# 15. Démonstration complète

Créer le projet :

```bash
mkdir demo-vagrant
cd demo-vagrant
```

Initialiser :

```bash
vagrant init
```

Configurer le `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.image = "ubuntu:latest"
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.provision "shell", inline: <<-SHELL
    echo "Mission Mars" > /home/vagrant/mission.txt
  SHELL

end
```

Démarrer :

```bash
vagrant up --provider=docker
```

Vérifier :

```bash
vagrant status
```

Se connecter :

```bash
vagrant ssh
```

Vérifier le hostname :

```bash
hostname
```

Vérifier le fichier :

```bash
cat /home/vagrant/mission.txt
```

Quitter :

```bash
exit
```

Arrêter :

```bash
vagrant halt
```

Redémarrer :

```bash
vagrant up
```

Supprimer l'environnement :

```bash
vagrant destroy -f
```

---

# 16. Exercice final

Créer un projet :

```bash
mkdir tp-final-vagrant
cd tp-final-vagrant
```

Initialiser Vagrant :

```bash
vagrant init
```

Créer un `Vagrantfile` qui doit :

1. Utiliser Docker comme provider.
2. Utiliser une image Ubuntu.
3. Activer SSH.
4. Définir le hostname `mission-mars`.
5. Configurer un port forwarding `8080 -> 80`.
6. Créer le fichier `/home/vagrant/mission.txt` avec le provisioning.

Lancer :

```bash
vagrant up --provider=docker
```

Vérifier :

```bash
vagrant status
```

Se connecter :

```bash
vagrant ssh
```

Vérifier :

```bash
hostname
cat /home/vagrant/mission.txt
```

Quitter :

```bash
exit
```

Arrêter :

```bash
vagrant halt
```

Supprimer :

```bash
vagrant destroy -f
```

---

# 17. Résumé

Les commandes principales à retenir :

```bash
vagrant init
vagrant up
vagrant up --provider=docker
vagrant status
vagrant ssh
vagrant reload
vagrant provision
vagrant halt
vagrant suspend
vagrant resume
vagrant destroy
```

Les principales configurations du `Vagrantfile` :

```ruby
config.vm.provider "docker"
config.vm.hostname
config.vm.network
config.vm.provision
config.ssh.username
config.ssh.password
```

Workflow principal :

```text
vagrant init
      |
      v
Vagrantfile
      |
      v
vagrant up
      |
      v
Environnement Vagrant
      |
      v
vagrant ssh
      |
      v
Travail
      |
      v
vagrant halt
      |
      v
vagrant destroy
```

# Conclusion

Avec **Vagrant + Docker Provider**, le `Vagrantfile` permet de décrire l'environnement et les commandes Vagrant permettent de gérer simplement son cycle de vie.

Les commandes essentielles sont :

```bash
vagrant init
vagrant up --provider=docker
vagrant status
vagrant ssh
vagrant reload
vagrant provision
vagrant halt
vagrant destroy
```
