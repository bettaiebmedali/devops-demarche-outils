# Ansible + Docker Labs

## Objectifs

Ce TP permet d'apprendre Ansible progressivement en utilisant Docker comme infrastructure de laboratoire.

Le parcours couvre :

- Control Node et Managed Nodes
- Inventory
- Ad-Hoc commands
- Playbooks
- Modules
- Variables et Facts
- Jinja2
- Handlers
- Idempotence
- Conditions et Loops
- Roles
- Ansible Vault
- Ansible + Docker
- Ansible + Docker Compose
- Troubleshooting
- Déploiement complet

---

# Lab 1 — Introduction à Ansible et environnement Docker

## Objectif

Comprendre l'architecture Ansible et préparer un laboratoire basé sur Docker.

Architecture :

    Control Node
    Ubuntu / WSL
         |
      Ansible
         |
    +----+----+----+
    |         |    |
    v         v    v
  web01     web02 db01

## Installation

    sudo apt update
    sudo apt install -y ansible

Vérifier :

    ansible --version

Vérifier Docker :

    docker --version
    docker ps

Créer le réseau :

    docker network create ansible-network

## Challenge

Créer trois conteneurs :

    ansible-web01
    ansible-web02
    ansible-db01

---

# Lab 2 — Ansible Inventory

## Objectif

Créer et organiser un inventory Ansible.

Structure :

    ansible-labs/
    ├── inventory/
    │   └── hosts.ini
    └── site.yml

Exemple :

    [web]
    web01
    web02

    [database]
    db01

    [all:vars]
    ansible_user=ansible

Afficher l'inventory :

    ansible-inventory -i inventory/hosts.ini --graph

    ansible-inventory -i inventory/hosts.ini --list

## Challenge

Créer les groupes :

    web
    database
    production

---

# Lab 3 — Préparer les conteneurs Docker pour Ansible

## Objectif

Créer des Managed Nodes Linux accessibles en SSH.

Créer un fichier :

    Dockerfile

Contenu :

    FROM ubuntu:24.04

    RUN apt-get update && \
        apt-get install -y \
            openssh-server \
            python3 \
            sudo \
            curl \
            vim && \
        useradd -m -s /bin/bash ansible && \
        echo 'ansible:ansible' | chpasswd && \
        usermod -aG sudo ansible && \
        mkdir -p /run/sshd && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

    EXPOSE 22

    CMD ["/usr/sbin/sshd", "-D"]

Construire l'image :

    docker build -t ansible-node .

Créer le réseau :

    docker network create ansible-network

Créer web01 :

    docker run -d \
      --name web01 \
      --network ansible-network \
      -p 2221:22 \
      ansible-node

Créer web02 :

    docker run -d \
      --name web02 \
      --network ansible-network \
      -p 2222:22 \
      ansible-node

Créer db01 :

    docker run -d \
      --name db01 \
      --network ansible-network \
      -p 2223:22 \
      ansible-node

Vérifier :

    docker ps

Tester SSH :

    ssh ansible@127.0.0.1 -p 2221

Mot de passe :

    ansible

Inventory :

    [web]
    web01 ansible_host=127.0.0.1 ansible_port=2221
    web02 ansible_host=127.0.0.1 ansible_port=2222

    [database]
    db01 ansible_host=127.0.0.1 ansible_port=2223

    [all:vars]
    ansible_user=ansible
    ansible_password=ansible
    ansible_become_password=ansible
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'

Tester :

    ansible all -i inventory/hosts.ini -m ping

Résultat attendu :

    web01 | SUCCESS
    web02 | SUCCESS
    db01  | SUCCESS

## Challenge

Créer automatiquement les trois conteneurs avec un script Bash.

---

# Lab 4 — Ansible Ad-Hoc Commands

## Objectif

Utiliser Ansible sans Playbook.

Tester la connectivité :

    ansible all -i inventory/hosts.ini -m ping

Afficher le hostname :

    ansible all -i inventory/hosts.ini -m command -a "hostname"

Afficher la version Linux :

    ansible all -i inventory/hosts.ini -m command -a "uname -a"

Afficher l'uptime :

    ansible all -i inventory/hosts.ini -m command -a "uptime"

Afficher le filesystem :

    ansible all -i inventory/hosts.ini -m shell -a "df -h"

Afficher les informations système :

    ansible all -i inventory/hosts.ini -m setup

Limiter au groupe web :

    ansible web -i inventory/hosts.ini -m command -a "hostname"

Limiter à un serveur :

    ansible web01 -i inventory/hosts.ini -m command -a "hostname"

## Challenge

Afficher avec Ansible :

- hostname
- distribution Linux
- mémoire
- nombre de CPU
- espace disque

---

# Lab 5 — Premier Playbook

## Objectif

Créer son premier Playbook Ansible.

Créer :

    site.yml

Contenu :

    ---
    - name: Configure web servers
      hosts: web
      become: true

      tasks:

        - name: Install nginx
          ansible.builtin.apt:
            name: nginx
            state: present
            update_cache: true

        - name: Start nginx
          ansible.builtin.service:
            name: nginx
            state: started

Exécuter :

    ansible-playbook -i inventory/hosts.ini site.yml

Mode simulation :

    ansible-playbook -i inventory/hosts.ini site.yml --check

## Challenge

Installer :

    nginx
    curl
    vim

sur les serveurs web.

Installer PostgreSQL sur le serveur database.

---

# Lab 6 — Modules Ansible

## Objectif

Découvrir les principaux modules Ansible.

Modules :

    apt
    package
    file
    copy
    template
    lineinfile
    user
    group
    service
    command
    shell
    uri
    stat

Créer un répertoire :

    - name: Create application directory
      ansible.builtin.file:
        path: /opt/myapp
        state: directory
        mode: '0755'

Créer les répertoires :

    - name: Create configuration directory
      ansible.builtin.file:
        path: /opt/myapp/config
        state: directory

    - name: Create logs directory
      ansible.builtin.file:
        path: /opt/myapp/logs
        state: directory

    - name: Create data directory
      ansible.builtin.file:
        path: /opt/myapp/data
        state: directory

Créer un utilisateur :

    - name: Create application user
      ansible.builtin.user:
        name: appuser
        shell: /bin/bash
        create_home: true

Créer un fichier :

    - name: Create application file
      ansible.builtin.copy:
        content: |
          Application started
        dest: /opt/myapp/config/application.conf
        mode: '0644'

Vérifier :

    - name: Check configuration file
      ansible.builtin.stat:
        path: /opt/myapp/config/application.conf
      register: config_file

Afficher :

    - name: Display file status
      ansible.builtin.debug:
        var: config_file.stat.exists

## Challenge

Automatiser complètement :

    /opt/myapp/
    ├── config/
    ├── logs/
    └── data/

avec l'utilisateur :

    appuser

---

# Lab 7 — Variables et Facts

## Objectif

Rendre les Playbooks dynamiques.

Créer :

    group_vars/
    ├── all.yml
    └── web.yml

Exemple :

    app_name: myapp
    app_port: 8080
    environment: dev
    server_name: localhost

Utilisation :

    - name: Display application
      ansible.builtin.debug:
        msg: "Application {{ app_name }} running on port {{ app_port }}"

Facts disponibles :

    ansible_hostname
    ansible_distribution
    ansible_os_family
    ansible_memory_mb
    ansible_processor_vcpus

Exemple :

    - name: Display system information
      ansible.builtin.debug:
        msg:
          - "Hostname: {{ ansible_hostname }}"
          - "OS: {{ ansible_distribution }}"
          - "CPU: {{ ansible_processor_vcpus }}"

## Challenge

Créer une page HTML contenant :

    Hostname
    OS
    Environment
    CPU
    Memory

---

# Lab 8 — Jinja2 Templates

## Objectif

Générer dynamiquement des fichiers de configuration.

Créer :

    templates/
    └── nginx.conf.j2

Contenu :

    server {

        listen {{ app_port }};

        server_name {{ server_name }};

        location / {
            proxy_pass http://{{ backend_host }}:{{ backend_port }};
        }
    }

Déployer :

    - name: Deploy nginx configuration
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/app.conf
        mode: '0644'

Variables :

    app_port: 8080
    server_name: localhost
    backend_host: backend
    backend_port: 8080

## Challenge

Produire une configuration différente pour :

    web01
    web02

sans modifier le template.

Utiliser uniquement les variables.

---

# Lab 9 — Handlers

## Objectif

Redémarrer un service uniquement lorsqu'une configuration change.

Exemple :

    tasks:

      - name: Deploy nginx configuration
        ansible.builtin.template:
          src: nginx.conf.j2
          dest: /etc/nginx/conf.d/app.conf
        notify:
          - Restart nginx

    handlers:

      - name: Restart nginx
        ansible.builtin.service:
          name: nginx
          state: restarted

Modifier le template.

Exécuter :

    ansible-playbook -i inventory/hosts.ini site.yml

Le handler doit être exécuté lorsque le fichier change.

Exécuter une deuxième fois :

    ansible-playbook -i inventory/hosts.ini site.yml

Le handler ne doit pas être exécuté si rien n'a changé.

## Challenge

Ajouter :

    Restart backend
    Restart database

avec des handlers séparés.

---

# Lab 10 — Idempotence

## Objectif

Comprendre l'idempotence Ansible.

Premier lancement :

    ansible-playbook -i inventory/hosts.ini site.yml

Deuxième lancement :

    ansible-playbook -i inventory/hosts.ini site.yml

Le deuxième lancement doit principalement afficher :

    ok

et très peu de :

    changed

## Mauvais exemple

    - name: Bad example
      ansible.builtin.shell:
        cmd: echo "hello" >> /tmp/test.txt

Cette tâche ajoute une ligne à chaque exécution.

## Meilleur exemple

    - name: Add configuration
      ansible.builtin.lineinfile:
        path: /tmp/test.txt
        line: "hello"
        create: true

Cette tâche est idempotente.

## Challenge

Identifier et corriger trois tâches non idempotentes.

---

# Lab 11 — Conditions et Loops

## Objectif

Automatiser des tâches conditionnelles et répétitives.

Loop :

    - name: Install packages
      ansible.builtin.apt:
        name: "{{ item }}"
        state: present
        update_cache: true
      loop:
        - curl
        - wget
        - vim

Condition :

    - name: Install nginx on Debian
      ansible.builtin.apt:
        name: nginx
        state: present
      when: ansible_os_family == "Debian"

Register :

    - name: Check application
      ansible.builtin.command:
        cmd: curl http://localhost
      register: result
      changed_when: false

Afficher le résultat :

    - name: Display result
      ansible.builtin.debug:
        var: result.stdout

## Challenge

Installer différents packages selon la distribution :

    Debian / Ubuntu
    Rocky / RedHat

---

# Lab 12 — Ansible Roles

## Objectif

Structurer un projet Ansible professionnel.

Structure :

    roles/
    ├── nginx/
    │   ├── tasks/
    │   ├── handlers/
    │   ├── templates/
    │   ├── files/
    │   ├── vars/
    │   ├── defaults/
    │   └── meta/
    │
    ├── application/
    │   ├── tasks/
    │   ├── handlers/
    │   ├── templates/
    │   ├── files/
    │   └── defaults/
    │
    └── database/
        ├── tasks/
        ├── handlers/
        ├── templates/
        └── defaults/

Créer automatiquement un rôle :

    ansible-galaxy init roles/nginx

Playbook :

    ---
    - name: Deploy application
      hosts: web
      become: true

      roles:
        - nginx
        - application

## Challenge

Créer :

    roles/database

et y déplacer toutes les tâches PostgreSQL.

---

# Lab 13 — Ansible Vault

## Objectif

Gérer les secrets de manière sécurisée.

Créer :

    ansible-vault create vault.yml

Exemple :

    database_user: app
    database_password: MySecretPassword

Modifier :

    ansible-vault edit vault.yml

Afficher :

    ansible-vault view vault.yml

Utilisation :

    - name: Display database user
      ansible.builtin.debug:
        msg: "{{ database_user }}"

Exécuter :

    ansible-playbook \
      -i inventory/hosts.ini \
      site.yml \
      --ask-vault-pass

## Challenge

Protéger :

    database_user
    database_password
    api_key

avec Ansible Vault.

---

# Lab 14 — Ansible + Docker

## Objectif

Utiliser Ansible pour piloter directement Docker.

Installer la collection :

    ansible-galaxy collection install community.docker

Vérifier :

    ansible-galaxy collection list

## Créer un réseau Docker

    - name: Create Docker network
      community.docker.docker_network:
        name: app-network

## Créer un volume

    - name: Create Docker volume
      community.docker.docker_volume:
        name: postgres-data

## Créer un container Nginx

    - name: Start nginx
      community.docker.docker_container:
        name: nginx
        image: nginx:alpine
        state: started
        restart_policy: unless-stopped
        ports:
          - "8080:80"

Vérifier :

    docker ps

Tester :

    curl http://localhost:8080

## Redis

    - name: Start Redis
      community.docker.docker_container:
        name: redis
        image: redis:alpine
        state: started
        restart_policy: unless-stopped

## PostgreSQL

    - name: Start PostgreSQL
      community.docker.docker_container:
        name: postgres
        image: postgres:16
        state: started
        restart_policy: unless-stopped
        env:
          POSTGRES_DB: application
          POSTGRES_USER: app
          POSTGRES_PASSWORD: secret
        volumes:
          - postgres-data:/var/lib/postgresql/data

## Challenge

Créer avec Ansible :

    network
    volume
    nginx
    redis
    postgres

---

# Lab 15 — Ansible + Docker Compose

## Objectif

Déployer une application multi-conteneurs avec Ansible.

Architecture :

    Nginx
       |
    Backend
       |
    PostgreSQL

Créer :

    /opt/myapp/
    └── compose.yaml

Exemple :

    services:

      nginx:
        image: nginx:alpine
        ports:
          - "8080:80"
        depends_on:
          - backend
        restart: unless-stopped

      backend:
        image: nginx:alpine
        restart: unless-stopped

      postgres:
        image: postgres:16
        environment:
          POSTGRES_DB: application
          POSTGRES_USER: app
          POSTGRES_PASSWORD: secret
        volumes:
          - postgres-data:/var/lib/postgresql/data
        restart: unless-stopped

    volumes:
      postgres-data:

Déployer le fichier avec Ansible :

    - name: Create application directory
      ansible.builtin.file:
        path: /opt/myapp
        state: directory
        mode: '0755'

    - name: Deploy compose file
      ansible.builtin.copy:
        src: compose.yaml
        dest: /opt/myapp/compose.yaml
        mode: '0644'

Déployer avec Compose v2 :

    - name: Deploy application
      community.docker.docker_compose_v2:
        project_src: /opt/myapp
        state: present

Alternative :

    - name: Start Docker Compose application
      ansible.builtin.command:
        cmd: docker compose up -d
        chdir: /opt/myapp

Vérifier :

    docker compose -f /opt/myapp/compose.yaml ps

## Challenge

Faire déployer automatiquement :

    compose.yaml
    .env
    nginx.conf
    backend configuration
    PostgreSQL

---

# Lab 16 — Dynamic Configuration

## Objectif

Générer toute la configuration Docker avec Jinja2.

Variables :

    environment: dev
    app_name: myapp
    app_port: 8080
    db_name: application
    db_user: app
    db_password: secret

Générer :

    compose.yaml
    .env
    nginx.conf
    application.conf

## Environnements

Créer :

    dev
    test
    prod

Structure :

    group_vars/
    ├── all.yml
    ├── dev.yml
    ├── test.yml
    └── prod.yml

Le Playbook doit rester identique.

Seules les variables changent.

## Challenge

Déployer différents environnements avec le même Playbook.

---

# Lab 17 — Ansible Tags

## Objectif

Exécuter seulement une partie d'un déploiement.

Installation :

    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present
      tags:
        - install

Configuration :

    - name: Deploy nginx configuration
      ansible.builtin.template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/app.conf
      notify:
        - Restart nginx
      tags:
        - config

Déploiement :

    - name: Deploy application
      ansible.builtin.command:
        cmd: docker compose up -d
        chdir: /opt/myapp
      tags:
        - deploy

Exécuter uniquement l'installation :

    ansible-playbook site.yml --tags install

Configuration :

    ansible-playbook site.yml --tags config

Déploiement :

    ansible-playbook site.yml --tags deploy

## Challenge

Créer les tags :

    install
    config
    database
    deploy
    restart
    cleanup

---

# Lab 18 — Ansible Troubleshooting

## Objectif

Reproduire et diagnostiquer des incidents.

## Incident 1 — Mauvais port

Modifier volontairement :

    8080

en :

    9090

Tester :

    curl http://localhost:8080

Analyser la cause.

## Incident 2 — Container arrêté

    docker ps -a

Logs :

    docker logs <container>

## Incident 3 — Mauvais réseau

    docker network ls

Puis :

    docker network inspect <network>

## Incident 4 — Mauvaise variable

Modifier volontairement :

    backend_port: 9999

Puis exécuter :

    ansible-playbook site.yml

## Incident 5 — Mauvaise image

Utiliser volontairement :

    nginx:invalid

Observer le comportement.

## Debug Ansible

    ansible-playbook site.yml -vvv

## Commandes Docker utiles

    docker ps -a

    docker logs <container>

    docker inspect <container>

    docker network inspect <network>

    docker volume inspect <volume>

    docker stats

## Rapport d'incident

    Symptom:
    Root cause:
    Diagnostic:
    Fix:
    Verification:
    Preventive action:

## Challenge

Créer cinq incidents différents et demander aux stagiaires de les diagnostiquer.

---

# Lab 19 — Production-like Ansible + Docker

## Objectif

Construire une infrastructure Docker complète pilotée par Ansible.

Architecture :

                         Ansible
                            |
                       Docker Engine
                            |
             +--------------+--------------+
             |              |              |
             v              v              v
           Nginx         Backend       PostgreSQL
             |              |              |
             +--------------+--------------+
                            |
                         Networks
                            |
                         Volumes

Structure :

    roles/
    ├── docker/
    ├── nginx/
    ├── backend/
    └── database/

Ansible doit gérer :

    network
    volumes
    images
    containers
    configuration
    secrets
    healthchecks
    restart policies
    reverse proxy
    database
    backend

## Challenge

Construire l'infrastructure entièrement avec des Roles Ansible.

---

# Lab 20 — Final DevOps Challenge

## Objectif

Automatiser le déploiement complet d'une application.

Architecture :

                       Internet
                           |
                           v
                      Nginx Proxy
                           |
                           v
                      Backend API
                           |
                           v
                       PostgreSQL

## Contraintes

L'application doit respecter les contraintes suivantes :

1. Docker doit être utilisé comme infrastructure.
2. Ansible doit piloter le déploiement.
3. Les configurations doivent utiliser Jinja2.
4. Les secrets doivent utiliser Ansible Vault.
5. Le déploiement doit être idempotent.
6. Les changements de configuration doivent utiliser des handlers.
7. PostgreSQL doit utiliser un volume Docker.
8. Les services doivent utiliser des réseaux Docker.
9. Les conteneurs doivent avoir une restart policy.
10. Les services doivent disposer de healthchecks.
11. Seul Nginx doit être exposé vers l'extérieur.
12. Le backend ne doit pas être directement exposé.
13. PostgreSQL ne doit pas être directement exposé.

## Structure attendue

    ansible-project/
    ├── inventory/
    │   └── hosts.ini
    │
    ├── group_vars/
    │   ├── all.yml
    │   └── vault.yml
    │
    ├── roles/
    │   ├── docker/
    │   ├── nginx/
    │   ├── backend/
    │   └── database/
    │
    ├── templates/
    ├── files/
    ├── site.yml
    └── ansible.cfg

## Validation

Vérifier :

- Ansible installé
- Inventory fonctionnel
- Ping fonctionnel
- Docker network
- Docker volume
- Images
- Containers
- Nginx
- Backend
- PostgreSQL
- Healthchecks
- Restart policies
- Jinja2
- Variables
- Handlers
- Roles
- Vault
- Idempotence
- Application accessible
- Persistance des données
- Troubleshooting

---

# Correction Formateur — Exemple

## Installation de la collection Docker

    ansible-galaxy collection install community.docker

## Network

    - name: Create frontend network
      community.docker.docker_network:
        name: frontend-network

    - name: Create backend network
      community.docker.docker_network:
        name: backend-network

## Volume

    - name: Create PostgreSQL volume
      community.docker.docker_volume:
        name: postgres-data

## Container Nginx

    - name: Deploy nginx
      community.docker.docker_container:
        name: nginx
        image: nginx:alpine
        state: started
        restart_policy: unless-stopped
        networks:
          - name: frontend-network
        ports:
          - "8080:80"

---

# Cheat Sheet Ansible

## Installation

    sudo apt update
    sudo apt install -y ansible
    ansible --version

## Inventory

    ansible-inventory -i inventory.ini --graph

    ansible-inventory -i inventory.ini --list

## Ad-Hoc

    ansible all -i inventory.ini -m ping

    ansible all -i inventory.ini -m setup

    ansible all -i inventory.ini -m command -a "hostname"

    ansible all -i inventory.ini -m shell -a "df -h"

## Playbooks

    ansible-playbook -i inventory.ini site.yml

    ansible-playbook -i inventory.ini site.yml --check

    ansible-playbook -i inventory.ini site.yml --diff

    ansible-playbook -i inventory.ini site.yml -vvv

## Tags

    ansible-playbook site.yml --tags deploy

    ansible-playbook site.yml --tags config

    ansible-playbook site.yml --tags install

## Vault

    ansible-vault create vault.yml

    ansible-vault edit vault.yml

    ansible-vault view vault.yml

    ansible-vault encrypt vault.yml

    ansible-playbook site.yml --ask-vault-pass

## Roles

    ansible-galaxy init roles/nginx

## Collections

    ansible-galaxy collection install community.docker

    ansible-galaxy collection list

## Docker

    docker ps

    docker ps -a

    docker images

    docker network ls

    docker volume ls

    docker logs <container>

    docker inspect <container>

    docker stats

---

# Ansible vs Docker Compose

| Technologie | Rôle principal |
|---|---|
| Docker | Exécuter des conteneurs |
| Docker Compose | Décrire et déployer une application multi-conteneurs |
| Ansible | Automatiser et orchestrer des tâches |
| Ansible + Docker | Piloter Docker avec des Playbooks |
| Ansible + Docker Compose | Déployer des stacks Compose de manière automatisée |

Architecture :

                     Git Repository
                           |
                           v
                     Ansible Code
                           |
                           v
                     Control Node
                           |
                           v
                       Docker API
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
          Nginx         Backend      PostgreSQL

---

# Ansible + Docker — Concepts importants

## Ansible

Ansible est principalement utilisé pour :

- automatiser
- configurer
- déployer
- orchestrer
- maintenir une infrastructure

## Docker

Docker est utilisé pour :

- construire des images
- créer des conteneurs
- isoler les applications
- gérer les réseaux
- gérer les volumes

## Docker Compose

Docker Compose permet de décrire une application composée de plusieurs services.

Exemple :

    services:
      frontend:
        image: nginx

      backend:
        image: my-backend

      database:
        image: postgres

## Ansible + Docker

Ansible peut piloter directement Docker :

    community.docker.docker_container

    community.docker.docker_network

    community.docker.docker_volume

    community.docker.docker_image

    community.docker.docker_compose_v2

Architecture :

                 Ansible
                    |
                    v
               Docker API
                    |
          +---------+---------+
          |         |         |
          v         v         v
        Nginx    Backend   PostgreSQL

---

# Bonnes pratiques

## 1. Idempotence

Toujours privilégier des tâches idempotentes.

Éviter :

    shell
    command

lorsqu'un module Ansible existe.

## 2. Utiliser les modules

Préférer :

    ansible.builtin.file

à :

    shell: mkdir

Préférer :

    ansible.builtin.copy

à :

    shell: echo "..." > fichier

## 3. Utiliser des Roles

Organiser les responsabilités :

    docker
    nginx
    backend
    database

## 4. Utiliser des variables

Éviter de coder en dur :

    ports
    passwords
    image versions
    database names

## 5. Utiliser Vault

Ne jamais stocker les secrets directement dans Git.

Utiliser :

    ansible-vault

## 6. Utiliser les Handlers

Redémarrer un service uniquement lorsqu'une configuration a changé.

## 7. Utiliser Jinja2

Générer dynamiquement :

    nginx.conf
    compose.yaml
    application.conf
    .env

## 8. Utiliser --check

Avant un changement :

    ansible-playbook site.yml --check

## 9. Utiliser --diff

Pour voir les changements :

    ansible-playbook site.yml --diff

## 10. Organiser l'inventory

Exemple :

    inventory/
    ├── dev/
    │   └── hosts.ini
    ├── test/
    │   └── hosts.ini
    └── prod/
        └── hosts.ini

---

# Final Challenge — Automation From Zero

## Objectif

Partir d'un Docker Engine vide et automatiser entièrement le déploiement avec Ansible.

## Point de départ

Aucun :

    network
    volume
    container
    configuration
    application

## Ansible doit automatiser

### Étape 1

Préparation de l'environnement.

### Étape 2

Création des networks.

### Étape 3

Création des volumes.

### Étape 4

Préparation des images.

### Étape 5

Génération des configurations.

### Étape 6

Génération de Docker Compose.

### Étape 7

Déploiement de l'application.

### Étape 8

Vérification des services.

### Étape 9

Diagnostic en cas d'erreur.

### Étape 10

Mise à jour de l'application.

## Architecture finale

                         Git
                          |
                          v
                    Ansible Project
                          |
                          v
                    Control Node
                          |
                          v
                    Docker Engine
                          |
             +------------+------------+
             |            |            |
             v            v            v
           Nginx       Backend      PostgreSQL
             |            |            |
             +------------+------------+
                          |
                     Docker Network
                          |
                     PostgreSQL Volume

## Contraintes finales

L'application doit :

- être entièrement déployée avec Ansible
- utiliser Docker
- utiliser Docker Compose
- utiliser Jinja2
- utiliser Roles
- utiliser Variables
- utiliser Handlers
- utiliser Ansible Vault
- être idempotente
- utiliser des healthchecks
- utiliser des restart policies
- utiliser des Docker networks
- utiliser des Docker volumes
- ne pas exposer PostgreSQL
- ne pas exposer directement le Backend
- exposer uniquement Nginx

## Critères de réussite

Le TP est considéré comme réussi si :

    ansible-playbook site.yml

peut être exécuté plusieurs fois sans provoquer de changements inutiles.

La commande :

    docker ps

doit afficher les services attendus.

La commande :

    docker network ls

doit afficher les réseaux nécessaires.

La commande :

    docker volume ls

doit afficher le volume PostgreSQL.

L'application doit être accessible via Nginx.

PostgreSQL doit conserver ses données après recréation du conteneur.

Le backend doit être accessible uniquement depuis le réseau Docker interne.

Les secrets ne doivent jamais apparaître en clair dans le repository Git.

---

# Projet Final — Niveau Avancé

## Mission

Vous êtes responsable de l'automatisation d'une petite plateforme applicative.

L'équipe de développement fournit :

    Backend API
    PostgreSQL

L'équipe infrastructure doit fournir :

    Docker
    Network
    Volumes
    Nginx
    Configuration
    Secrets
    Healthchecks
    Restart policies

Vous devez construire toute l'automatisation avec Ansible.

## Livrables

Le projet doit contenir :

    ansible-project/
    ├── ansible.cfg
    ├── site.yml
    │
    ├── inventory/
    │   └── hosts.ini
    │
    ├── group_vars/
    │   ├── all.yml
    │   └── vault.yml
    │
    ├── roles/
    │   ├── docker/
    │   ├── nginx/
    │   ├── backend/
    │   └── database/
    │
    ├── templates/
    │   ├── nginx.conf.j2
    │   ├── compose.yaml.j2
    │   └── application.conf.j2
    │
    └── README.md

## Validation finale

Exécuter :

    ansible-playbook -i inventory/hosts.ini site.yml

Puis :

    docker ps

    docker network ls

    docker volume ls

Tester :

    curl http://localhost:8080

Tester l'idempotence :

    ansible-playbook -i inventory/hosts.ini site.yml

Le deuxième lancement doit produire principalement :

    ok

et très peu de :

    changed

## Compétences acquises

À la fin de ce parcours, le stagiaire doit être capable de :

- comprendre l'architecture Ansible
- créer un inventory
- exécuter des commandes Ad-Hoc
- écrire des Playbooks
- utiliser les modules Ansible
- gérer les variables
- exploiter les Facts
- utiliser Jinja2
- utiliser les Handlers
- garantir l'idempotence
- utiliser les conditions
- utiliser les loops
- créer des Roles
- protéger les secrets avec Vault
- piloter Docker avec Ansible
- déployer Docker Compose avec Ansible
- diagnostiquer des problèmes
- construire une automatisation DevOps complète

---

# Fin du TP

Ansible + Docker permet de combiner :

    Ansible
       +
    Docker
       +
    Docker Compose
       +
    Jinja2
       +
    Roles
       +
    Vault
       +
    Idempotence

pour construire une automatisation d'infrastructure reproductible, maintenable et industrialisée.