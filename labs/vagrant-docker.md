# TP — Vagrant avec Docker Provider

## Objectifs

Dans ce TP, nous allons utiliser **Vagrant avec Docker comme provider** pour créer et gérer un environnement de développement.

À la fin du TP, vous serez capable de :

- Créer un projet Vagrant.
- Configurer Docker comme provider Vagrant.
- Créer une image personnalisée avec un `Dockerfile`.
- Configurer SSH pour utiliser `vagrant ssh`.
- Démarrer et arrêter un environnement Vagrant.
- Utiliser le provisioning.
- Utiliser les dossiers partagés.
- Configurer les ports.
- Gérer plusieurs machines avec Vagrant.
- Maîtriser le cycle de vie d'un environnement Vagrant.

---

# 1. Prérequis

Vérifier que Vagrant est installé :

```bash
vagrant --version
```

Vérifier que Docker est disponible :

```bash
docker --version
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

Le projet aura finalement cette structure :

```text
tp-vagrant-docker/
├── Dockerfile
└── Vagrantfile
```

---

# 3. Utiliser Docker comme provider

Vagrant peut utiliser différents providers.

Dans ce TP, nous utilisons Docker :

```ruby
config.vm.provider "docker" do |docker|
```

Notre `Vagrantfile` va utiliser une image construite localement à partir d'un `Dockerfile`.

---

# 4. Créer le Dockerfile

Créer un fichier :

```text
Dockerfile
```

Contenu :

```dockerfile
FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    sudo && \
    useradd -m -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    usermod -aG sudo vagrant && \
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/sshd", "-D", "-e"]
```

Ce fichier permet à Vagrant d'utiliser une image Ubuntu contenant :

- Un serveur SSH.
- Un utilisateur `vagrant`.
- Un mot de passe `vagrant`.
- Les permissions `sudo`.
- Le programme `/usr/sbin/sshd`.

---

# 5. Configurer le Vagrantfile

Modifier le fichier `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

end
```

## Configuration utilisée

### Provider

```ruby
config.vm.provider "docker" do |docker|
```

Docker est utilisé comme provider.

### Construction de l'image

```ruby
docker.build_dir = "."
```

Vagrant utilise le `Dockerfile` présent dans le répertoire courant.

### SSH

```ruby
docker.has_ssh = true
```

Permet à Vagrant d'utiliser SSH.

### Commande de démarrage

```ruby
docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
```

Le serveur SSH est lancé au démarrage.

### Utilisateur SSH

```ruby
config.ssh.username = "vagrant"
config.ssh.password = "vagrant"
```

Vagrant utilise l'utilisateur `vagrant`.

---

# 6. Démarrer l'environnement

Lancer :

```bash
vagrant up --provider=docker
```

Vagrant va :

1. Lire le `Vagrantfile`.
2. Utiliser le `Dockerfile`.
3. Construire l'image.
4. Créer l'environnement.
5. Démarrer le serveur SSH.
6. Configurer la connexion SSH.

Vérifier l'état :

```bash
vagrant status
```

---

# 7. Se connecter avec SSH

Utiliser :

```bash
vagrant ssh
```

Tester :

```bash
whoami
```

Résultat attendu :

```text
vagrant
```

Vérifier le hostname :

```bash
hostname
```

Résultat attendu :

```text
mission-mars
```

Quitter :

```bash
exit
```

---

# 8. Démonstration — Cycle de vie

## Démarrer

```bash
vagrant up
```

## Vérifier l'état

```bash
vagrant status
```

## Se connecter

```bash
vagrant ssh
```

## Arrêter

```bash
vagrant halt
```

## Redémarrer

```bash
vagrant up
```

## Recharger la configuration

```bash
vagrant reload
```

## Détruire l'environnement

```bash
vagrant destroy
```

Sans confirmation :

```bash
vagrant destroy -f
```

---

# 9. Démonstration — Modifier le hostname

Modifier :

```ruby
config.vm.hostname = "serveur-vagrant"
```

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "serveur-vagrant"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

end
```

Appliquer :

```bash
vagrant reload
```

Puis :

```bash
vagrant ssh
```

Vérifier :

```bash
hostname
```

Résultat :

```text
serveur-vagrant
```

---

# 10. Démonstration — Provisioning

Le provisioning permet d'exécuter automatiquement des commandes avec Vagrant.

Ajouter dans le `Vagrantfile` :

```ruby
config.vm.provision "shell", inline: <<-SHELL
  echo "Bienvenue dans Vagrant"
  touch /home/vagrant/test.txt
SHELL
```

Exemple complet :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.provision "shell", inline: <<-SHELL
    echo "Bienvenue dans Vagrant"
    touch /home/vagrant/test.txt
  SHELL

end
```

Exécuter :

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

# 11. Démonstration — Provisioning avec un script

Créer :

```text
bootstrap.sh
```

Contenu :

```bash
#!/bin/bash

echo "Configuration de Mission Mars"

mkdir -p /home/vagrant/project

echo "Projet Vagrant" > /home/vagrant/project/info.txt
```

Modifier le `Vagrantfile` :

```ruby
config.vm.provision "shell",
  path: "bootstrap.sh"
```

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
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

Résultat :

```text
Projet Vagrant
```

---

# 12. Démonstration — Dossier partagé

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

# 13. Démonstration — Port forwarding

Vagrant permet de rediriger un port.

Ajouter dans le `Vagrantfile` :

```ruby
config.vm.network "forwarded_port",
  guest: 80,
  host: 8080
```

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
    docker.has_ssh = true
    docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
  end

  config.vm.network "forwarded_port",
    guest: 80,
    host: 8080

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

end
```

Appliquer :

```bash
vagrant reload
```

La correspondance est :

```text
Machine hôte
localhost:8080
       |
       v
Machine Vagrant
port 80
```

---

# 14. Démonstration — Réseau privé

Vagrant permet également de configurer un réseau privé :

```ruby
config.vm.network "private_network",
  ip: "192.168.56.10"
```

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
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

# 15. Démonstration — Plusieurs machines

Vagrant permet de gérer plusieurs environnements dans un seul `Vagrantfile`.

Exemple :

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|

    web.vm.hostname = "web-server"

    web.vm.provider "docker" do |docker|
      docker.build_dir = "."
      docker.has_ssh = true
      docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
    end

    web.ssh.username = "vagrant"
    web.ssh.password = "vagrant"

  end

  config.vm.define "db" do |db|

    db.vm.hostname = "database-server"

    db.vm.provider "docker" do |docker|
      docker.build_dir = "."
      docker.has_ssh = true
      docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
    end

    db.ssh.username = "vagrant"
    db.ssh.password = "vagrant"

  end

end
```

Démarrer les deux :

```bash
vagrant up
```

Afficher l'état :

```bash
vagrant status
```

Se connecter au serveur web :

```bash
vagrant ssh web
```

Se connecter à la base :

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

# 16. Commandes essentielles

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

## Provisionner

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

# 17. Démonstration complète

Créer le projet :

```bash
mkdir demo-vagrant-docker
cd demo-vagrant-docker
```

Initialiser :

```bash
vagrant init
```

Créer le `Dockerfile` :

```dockerfile
FROM ubuntu:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssh-server \
    sudo && \
    useradd -m -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    usermod -aG sudo vagrant && \
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/sshd", "-D", "-e"]
```

Créer le `Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|

  config.vm.hostname = "mission-mars"

  config.vm.provider "docker" do |docker|
    docker.build_dir = "."
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

Supprimer :

```bash
vagrant destroy -f
```

---

# 18. Exercice final

Créer un projet :

```bash
mkdir tp-final-vagrant
cd tp-final-vagrant
```

Initialiser :

```bash
vagrant init
```

Créer un `Dockerfile` permettant d'avoir :

- Ubuntu.
- OpenSSH.
- L'utilisateur `vagrant`.
- Le mot de passe `vagrant`.
- `sudo`.

Créer un `Vagrantfile` permettant de :

1. Utiliser Docker comme provider.
2. Construire l'image à partir du `Dockerfile`.
3. Activer SSH.
4. Définir le hostname `mission-mars`.
5. Configurer le port `8080` vers le port `80`.
6. Créer `/home/vagrant/mission.txt` avec le provisioning.

Le provider doit utiliser :

```ruby
config.vm.provider "docker" do |docker|
  docker.build_dir = "."
  docker.has_ssh = true
  docker.cmd = ["/usr/sbin/sshd", "-D", "-e"]
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

# 19. Structure finale du projet

À la fin du TP, le projet peut avoir cette structure :

```text
tp-vagrant-docker/
├── Dockerfile
├── Vagrantfile
└── bootstrap.sh
```

---

# 20. Résumé

Le principe de Vagrant avec Docker dans ce TP est :

```text
             Vagrant
                |
                v
           Vagrantfile
                |
                v
         Docker Provider
                |
                v
           Dockerfile
                |
                v
       Environnement Vagrant
                |
                v
           vagrant ssh
```

Les commandes essentielles :

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

Les principales configurations :

```ruby
config.vm.provider "docker"
docker.build_dir = "."
docker.has_ssh = true
docker.cmd
config.vm.hostname
config.vm.provision
config.vm.network
config.ssh.username
config.ssh.password
```

Le workflow principal :

```text
1. vagrant init
        ↓
2. Créer Dockerfile
        ↓
3. Configurer Vagrantfile
        ↓
4. vagrant up
        ↓
5. vagrant ssh
        ↓
6. Travailler
        ↓
7. vagrant halt
        ↓
8. vagrant destroy
```

# Conclusion

Vagrant permet de gérer facilement un environnement de développement en décrivant sa configuration dans un `Vagrantfile`.

Dans ce TP, Docker est utilisé uniquement comme **provider de Vagrant**.

L'image utilisée par l'environnement est construite à partir d'un `Dockerfile`, puis Vagrant gère son cycle de vie :

```bash
vagrant up
vagrant ssh
vagrant halt
vagrant destroy
```

Le point essentiel est de séparer les rôles :

```text
Vagrantfile
    ↓
Configuration de l'environnement

Dockerfile
    ↓
Image utilisée par l'environnement

Vagrant
    ↓
Gestion du cycle de vie
```
