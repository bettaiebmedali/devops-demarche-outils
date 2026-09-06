# Lab: Serveur Ansible et Node dans Docker

## Étape 1 : Créer un Dockerfile pour le serveur Ansible
Créer un Dockerfile pour votre serveur Ansible (OpenSSH + Ansible + sudo).

**Dockerfile serveur Ansible : `Dockerfile_ansible`**
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    openssh-server \
    ansible \
    sudo
RUN useradd -m -s /bin/bash ansible_user && echo "ansible_user:password" | chpasswd \
&& usermod -aG sudo ansible_user
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

## Étape 2 : Créer un Dockerfile pour le node cible
**Dockerfile node cible : `Dockerfile_node`**
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo
RUN useradd -m -s /bin/bash ansible_user && echo "ansible_user:password" | chpasswd \
&& usermod -aG sudo ansible_user
RUN mkdir /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

## Étape 3 : Construire les images Docker
```bash
docker build -t ansible_server -f Dockerfile_ansible .
docker build -t ansible_node -f Dockerfile_node .
```

## Étape 4 : Lancer les conteneurs
```bash
docker network create ansible_network
docker run -d --name ansible_server --network ansible_network ansible_server
docker run -d --name ansible_node --network ansible_network ansible_node
```

## Étape 5 : Configurer SSH entre les conteneurs
1. Récupérer les IP :
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_server
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_node
```

2. Générer les clés SSH sur le serveur Ansible :
```bash
docker exec -it ansible_server bash
su - ansible_user
ssh-keygen -t rsa -b 2048
```

3. Copier la clé publique vers le node cible :
```bash
ssh-copy-id ansible_user@<IP_du_node>
```

4. Tester la connexion :
```bash
ssh ansible_user@<IP_du_node>
```

## Étape 6 : Utiliser Ansible
Pré-requis : installer vim sur le serveur ansible
```bash
sudo apt update
sudo apt install vim
```

Créer un fichier `inventory` :
```ini
[node]
ansible_node ansible_host=<IP_du_node> ansible_user=ansible_user
```

Tester Ansible :
```bash
ansible -i inventory node -m ping
```
