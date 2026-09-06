# Cloud Computing Labs — Cloud sans Provider

## AWS / Azure / GCP Concepts avec Infrastructure Locale

---

# Objectifs

Ce parcours permet d'apprendre les concepts fondamentaux du Cloud Computing sans avoir besoin d'un compte AWS, Microsoft Azure ou Google Cloud.

L'ensemble des travaux pratiques est réalisé localement avec :

- VirtualBox ou KVM/libvirt
- Vagrant
- Ubuntu
- Docker
- Docker Compose
- Terraform
- Ansible
- Nginx
- PostgreSQL
- MinIO
- Prometheus
- Grafana

L'objectif n'est pas de reproduire exactement AWS, Azure ou GCP.

L'objectif est de comprendre les concepts Cloud et de savoir les transposer ensuite vers un provider Cloud.

---

# Architecture globale

Architecture Cloud conceptuelle :

                         Cloud Provider
                               |
              +----------------+----------------+
              |                |                |
             IaaS             Network         Storage
              |                |                |
              v                v                v
             VM              VPC/VNet          Disk
              |
              v
           Compute
              |
              v
          Application

Architecture de notre laboratoire :

                         PC Local
                            |
                  VirtualBox / KVM
                            |
          +-----------------+-----------------+
          |                 |                 |
          v                 v                 v
       cloud01           cloud02           cloud03
       Ubuntu            Ubuntu            Ubuntu
          |                 |                 |
          +-----------------+-----------------+
                            |
                       Private Network
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
           Docker       Terraform      Ansible
              |
              v
        Applications

---

# Prérequis

Configuration minimale recommandée :

- CPU : 4 cores
- RAM : 8 GB
- Disque : 40 GB

Configuration confortable :

- CPU : 6 à 8 cores
- RAM : 16 GB
- Disque : 60 GB ou plus

Logiciels :

- Ubuntu
- VirtualBox ou KVM/libvirt
- Vagrant
- Docker
- Terraform
- Ansible
- Git

Vérifier :

    vagrant --version
    docker --version
    terraform version
    ansible --version

---

# Lab 1 — Comprendre le Cloud Computing

## Objectif

Comprendre les concepts fondamentaux du Cloud Computing.

## IaaS

Infrastructure as a Service.

Le provider fournit principalement :

- machines virtuelles
- réseau
- stockage
- IP
- firewall

Exemples :

- AWS EC2
- Azure Virtual Machines
- Google Compute Engine

Dans notre laboratoire :

    VM Ubuntu

---

## PaaS

Platform as a Service.

Le provider gère une partie importante de l'infrastructure et fournit une plateforme prête à utiliser.

Exemples :

- AWS Elastic Beanstalk
- Azure App Service
- Google App Engine

Dans notre laboratoire, certains concepts seront simulés avec :

- Docker
- Docker Compose
- Kubernetes

---

## SaaS

Software as a Service.

L'utilisateur consomme directement une application.

Exemples :

- Gmail
- Microsoft 365
- Salesforce

---

## Public Cloud

Infrastructure fournie par un provider public.

Exemples :

- AWS
- Microsoft Azure
- Google Cloud

---

## Private Cloud

Infrastructure privée appartenant à une organisation.

Exemples :

- OpenStack
- VMware
- Proxmox
- CloudStack

---

## Hybrid Cloud

Combinaison :

    On-Premise
        +
    Public Cloud

---

## Challenge

Classer les éléments suivants :

    VM
    Docker
    Kubernetes
    Gmail
    PostgreSQL managé
    Object Storage
    réseau privé

dans :

    IaaS
    PaaS
    SaaS

---

# Lab 2 — Préparer l'environnement Cloud Local

## Objectif

Préparer l'environnement nécessaire pour les labs.

Vérifier VirtualBox :

    VBoxManage --version

ou KVM :

    virsh --version

Vérifier Vagrant :

    vagrant --version

Vérifier Docker :

    docker --version

Vérifier Terraform :

    terraform version

Vérifier Ansible :

    ansible --version

Vérifier Git :

    git --version

---

# Lab 3 — Première Machine Virtuelle

## Objectif

Créer une VM représentant une instance Cloud.

Créer un dossier :

    mkdir cloud-labs
    cd cloud-labs

Créer :

    Vagrantfile

Configuration :

    Vagrant.configure("2") do |config|

      config.vm.box = "ubuntu/jammy64"

      config.vm.hostname = "cloud01"

      config.vm.network "private_network",
        ip: "192.168.56.10"

      config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end

    end

Démarrer :

    vagrant up

Vérifier :

    vagrant status

Se connecter :

    vagrant ssh

Tester :

    hostname
    ip addr
    free -h
    df -h

---

# Lab 4 — Cloud Compute

## Objectif

Comprendre le concept de Compute.

Dans un Cloud :

    AWS EC2
    Azure VM
    Google Compute Engine

représentent des ressources de calcul.

Dans notre laboratoire :

    VM Ubuntu

Créer plusieurs VMs :

    cloud01
    cloud02
    cloud03

Architecture :

                 Local Host
                     |
              Hypervisor
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
    cloud01       cloud02       cloud03
     2 CPU          2 CPU         2 CPU
     2 GB           2 GB          2 GB

## Challenge

Modifier :

    CPU
    RAM
    hostname
    IP

d'une VM.

---

# Lab 5 — Provisioning avec Vagrant

## Objectif

Automatiser la création de plusieurs VMs.

Exemple :

    Vagrant.configure("2") do |config|

      config.vm.box = "ubuntu/jammy64"

      config.vm.define "cloud01" do |node|
        node.vm.hostname = "cloud01"
        node.vm.network "private_network",
          ip: "192.168.56.10"

        node.vm.provider "virtualbox" do |vb|
          vb.memory = 2048
          vb.cpus = 2
        end
      end

      config.vm.define "cloud02" do |node|
        node.vm.hostname = "cloud02"
        node.vm.network "private_network",
          ip: "192.168.56.11"

        node.vm.provider "virtualbox" do |vb|
          vb.memory = 2048
          vb.cpus = 2
        end
      end

      config.vm.define "cloud03" do |node|
        node.vm.hostname = "cloud03"
        node.vm.network "private_network",
          ip: "192.168.56.12"

        node.vm.provider "virtualbox" do |vb|
          vb.memory = 2048
          vb.cpus = 2
        end
      end

    end

Démarrer :

    vagrant up

Vérifier :

    vagrant status

Lister les VMs :

    VBoxManage list runningvms

## Challenge

Créer trois instances :

    cloud01
    cloud02
    cloud03

---

# Lab 6 — Cloud Networking

## Objectif

Comprendre les concepts réseau utilisés dans le Cloud.

Concepts :

    VPC
    VNet
    Subnet
    Private IP
    Public IP
    Route Table
    Security Group
    Firewall
    NAT
    Internet Gateway

Notre simulation :

    Cloud Network
          |
    +-----+-----+
    |           |
    v           v
  cloud01    cloud02

Réseau :

    192.168.56.0/24

Adresses :

    cloud01 -> 192.168.56.10
    cloud02 -> 192.168.56.11
    cloud03 -> 192.168.56.12

Tester :

    ping 192.168.56.11

Tester SSH :

    ssh vagrant@192.168.56.11

## Challenge

Créer deux sous-réseaux conceptuels :

    frontend
    backend

Exemple :

    frontend:
    192.168.10.0/24

    backend:
    192.168.20.0/24

---

# Lab 7 — Security Groups et Firewall

## Objectif

Comprendre le filtrage réseau Cloud.

Dans AWS :

    Security Groups

Dans Azure :

    Network Security Groups

Dans GCP :

    Firewall Rules

Sur Ubuntu :

    UFW

Installer :

    sudo apt update
    sudo apt install -y ufw

Autoriser SSH :

    sudo ufw allow 22/tcp

Autoriser HTTP :

    sudo ufw allow 80/tcp

Activer :

    sudo ufw enable

Vérifier :

    sudo ufw status

## Challenge

Autoriser uniquement :

    SSH 22
    HTTP 80

et bloquer :

    PostgreSQL 5432

depuis le réseau externe.

---

# Lab 8 — Cloud Storage

## Objectif

Comprendre les différents types de stockage Cloud.

## Block Storage

Exemples :

    AWS EBS
    Azure Managed Disk
    Google Persistent Disk

Simulation :

    disque attaché à une VM

---

## File Storage

Exemples :

    NFS
    AWS EFS
    Azure Files

---

## Object Storage

Exemples :

    Amazon S3
    Azure Blob Storage
    Google Cloud Storage

Dans notre laboratoire :

    MinIO

Architecture :

             Application
                  |
                  v
                MinIO
                  |
          +-------+-------+
          |       |       |
          v       v       v
       bucket  bucket  bucket

Déployer MinIO avec Docker.

## Challenge

Créer :

    bucket-logs
    bucket-backups
    bucket-app

---

# Lab 9 — Docker comme couche Cloud

## Objectif

Comprendre la relation entre VM et containers.

Architecture :

    Cloud VM
       |
       v
    Docker Engine
       |
    +--+--+--+
    |  |  |  |
    v  v  v  v
   App DB API Cache

Installer Docker :

    curl -fsSL https://get.docker.com | sh

Vérifier :

    docker version

Lancer :

    docker run -d \
      --name nginx \
      -p 8080:80 \
      nginx

Tester :

    curl http://localhost:8080

## Challenge

Déployer :

    nginx
    redis
    postgres

---

# Lab 10 — Infrastructure as Code avec Terraform

## Objectif

Comprendre le concept Infrastructure as Code.

Terraform permet de décrire l'infrastructure sous forme déclarative.

Architecture :

    Terraform
        |
        v
    Infrastructure
        |
        +---- VM
        +---- Network
        +---- Storage
        +---- Security

Créer :

    main.tf

Initialiser :

    terraform init

Valider :

    terraform validate

Prévisualiser :

    terraform plan

Appliquer :

    terraform apply

Détruire :

    terraform destroy

## Cycle Terraform

    init
      |
      v
    validate
      |
      v
    plan
      |
      v
    apply
      |
      v
    destroy

## Challenge

Expliquer la différence entre :

    terraform plan

et :

    terraform apply

---

# Lab 11 — Terraform + Docker

## Objectif

Utiliser Terraform pour gérer des ressources Docker.

Architecture :

    Terraform
        |
        v
    Docker Provider
        |
        +-----------+
        |           |
        v           v
     Network      Container
                    |
                    v
                  Nginx

Configuration :

    terraform {
      required_providers {
        docker = {
          source = "kreuzwerker/docker"
        }
      }
    }

Provider :

    provider "docker" {
      host = "unix:///var/run/docker.sock"
    }

Image :

    resource "docker_image" "nginx" {
      name = "nginx:alpine"
    }

Container :

    resource "docker_container" "nginx" {
      name  = "nginx"
      image = docker_image.nginx.image_id

      ports {
        internal = 80
        external = 8080
      }
    }

Exécuter :

    terraform init
    terraform plan
    terraform apply

Vérifier :

    docker ps

Tester :

    curl http://localhost:8080

Détruire :

    terraform destroy

## Challenge

Créer avec Terraform :

    network
    nginx
    redis
    postgres

---

# Lab 12 — Terraform Variables

## Objectif

Rendre l'infrastructure configurable.

Créer :

    variables.tf

Exemple :

    variable "nginx_port" {
      type    = number
      default = 8080
    }

Utilisation :

    external = var.nginx_port

Créer :

    terraform.tfvars

Exemple :

    nginx_port = 9090

Exécuter :

    terraform plan

## Challenge

Paramétrer :

    CPU
    RAM
    ports
    image versions
    environment

---

# Lab 13 — Terraform Outputs

## Objectif

Afficher les informations de l'infrastructure.

Créer :

    outputs.tf

Exemple :

    output "container_name" {
      value = docker_container.nginx.name
    }

Exécuter :

    terraform output

## Challenge

Afficher :

    container name
    IP
    port
    network

---

# Lab 14 — Configuration Management avec Ansible

## Objectif

Comprendre la différence entre Terraform et Ansible.

Terraform :

    Infrastructure

Ansible :

    Configuration

Architecture :

    Terraform
        |
        v
      VM
        |
        v
      Ansible
        |
        +---- Docker
        +---- Nginx
        +---- Configuration
        +---- Application

Terraform crée.

Ansible configure.

## Challenge

Créer une VM puis utiliser Ansible pour :

    installer Docker
    installer Nginx
    configurer Nginx
    déployer l'application

---

# Lab 15 — Load Balancing

## Objectif

Comprendre le Load Balancing Cloud.

Architecture :

                       Client
                         |
                         v
                      Nginx
                    Load Balancer
                         |
             +-----------+-----------+
             |                       |
             v                       v
          backend01              backend02

Créer deux applications :

    backend01
    backend02

Configuration Nginx :

    upstream backend {
        server backend01:8080;
        server backend02:8080;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
        }
    }

Tester :

    curl http://localhost

Répéter plusieurs fois.

## Challenge

Ajouter :

    backend03

et vérifier que le trafic peut être distribué entre les trois backends.

---

# Lab 16 — High Availability

## Objectif

Comprendre la haute disponibilité.

Architecture :

                         Client
                           |
                           v
                       Load Balancer
                           |
                 +---------+---------+
                 |                   |
                 v                   v
              Server1             Server2
                 |                   |
                 +---------+---------+
                           |
                         Database

Simuler une panne :

    docker stop backend01

Vérifier que l'application reste disponible.

Puis :

    docker start backend01

## Challenge

Arrêter successivement les backends.

L'application doit rester accessible tant qu'un backend est disponible.

---

# Lab 17 — Auto Scaling

## Objectif

Comprendre le concept d'Auto Scaling.

Dans un Cloud :

    CPU > 70%
          |
          v
    Create instance
          |
          v
    Add to Load Balancer

Simulation locale :

    backend01
    backend02

Puis :

    backend03

Architecture :

    Load Balancer
          |
    +-----+-----+
    |     |     |
    v     v     v
   B01   B02   B03

Politique :

    CPU > 70%
        |
        v
      Scale Up

    CPU < 30%
        |
        v
      Scale Down

## Challenge

Créer un mécanisme simple permettant d'ajouter ou supprimer un backend.

---

# Lab 18 — Service Discovery

## Objectif

Comprendre le Service Discovery.

Architecture :

    frontend
        |
        v
    service discovery
        |
        +---- backend01
        +---- backend02
        +---- backend03

Avec Docker :

    docker network

permet déjà une forme de Service Discovery DNS.

Tester :

    docker exec frontend \
      getent hosts backend

## Challenge

Créer plusieurs instances du backend.

Tester la résolution DNS interne.

---

# Lab 19 — Monitoring Cloud

## Objectif

Surveiller l'infrastructure.

Stack :

    Prometheus
        +
    Grafana

Architecture :

                    Grafana
                       |
                       v
                  Prometheus
                       |
          +------------+------------+
          |            |            |
          v            v            v
        VM01         VM02         VM03

Déployer Prometheus.

Déployer Grafana.

Configurer les targets.

Accéder à Grafana :

    http://localhost:3000

## Métriques

Surveiller :

    CPU
    RAM
    Disk
    Network
    Containers
    HTTP requests

## Challenge

Créer un dashboard :

    Cloud Infrastructure

avec :

    CPU usage
    Memory usage
    Disk usage
    Network traffic
    Container count

---

# Lab 20 — Centralized Logging

## Objectif

Intégrer ELK au laboratoire Cloud.

Architecture :

                         Applications
                              |
                              v
                             Logs
                              |
                              v
                          Logstash
                              |
                              v
                       Elasticsearch
                              |
                              v
                            Kibana

Les VMs et containers produisent des logs.

ELK les centralise.

## Challenge

Collecter les logs :

    nginx
    backend
    Docker

et créer un dashboard Kibana.

---

# Lab 21 — Cloud Network Architecture

## Objectif

Construire une architecture réseau plus réaliste.

Architecture :

                       Internet
                           |
                           v
                    Load Balancer
                           |
                     Public subnet
                           |
             +-------------+-------------+
             |                           |
             v                           v
          Frontend                    Frontend
             |                           |
             +-------------+-------------+
                           |
                      Private subnet
                           |
             +-------------+-------------+
             |                           |
             v                           v
          Backend                    Backend
             |                           |
             +-------------+-------------+
                           |
                      Database subnet
                           |
                           v
                       PostgreSQL

## Contraintes

Le réseau doit respecter :

    Internet
       |
       v
    Load Balancer
       |
       v
    Frontend
       |
       v
    Backend
       |
       v
    Database

PostgreSQL ne doit jamais être directement accessible depuis Internet.

## Challenge

Définir les règles réseau :

    Internet -> Load Balancer
    Load Balancer -> Frontend
    Frontend -> Backend
    Backend -> Database

Interdire :

    Internet -> Database
    Internet -> Backend

---

# Lab 22 — Cloud Security

## Objectif

Comprendre les principaux mécanismes de sécurité Cloud.

Concepts :

    IAM
    Users
    Groups
    Roles
    Policies
    Secrets
    Encryption
    TLS
    Firewall
    Security Groups
    Network Segmentation

---

## Simulation IAM

Créer les rôles :

    admin
    developer
    readonly

Définir :

    admin
      -> full access

    developer
      -> deploy applications

    readonly
      -> read only

## Challenge

Créer une matrice :

    Resource | Admin | Developer | Readonly

Exemple :

    Compute     | RW | RW | R
    Network     | RW | R  | R
    Storage     | RW | RW | R
    Database    | RW | R  | R

---

# Lab 23 — Secrets Management

## Objectif

Comprendre la gestion des secrets.

Ne jamais stocker directement des secrets dans Git.

Mauvaise pratique :

    POSTGRES_PASSWORD=secret

dans un fichier versionné.

Solutions possibles :

    .env
    Ansible Vault
    Docker Secrets
    Secret Manager Cloud
    Vault

Exemple Docker Compose :

    services:

      postgres:
        image: postgres:16
        environment:
          POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}

Créer :

    .env

Exemple :

    POSTGRES_PASSWORD=MySecretPassword

Ajouter `.env` au `.gitignore`.

## Challenge

Déplacer tous les secrets hors du code source.

---

# Lab 24 — Backup et Disaster Recovery

## Objectif

Comprendre le Backup et le Disaster Recovery Cloud.

Architecture :

                    Application
                         |
                         v
                     Database
                         |
                         v
                       Backup
                         |
                         v
                       Storage

Backup PostgreSQL :

    pg_dump

Exemple :

    pg_dump \
      -h localhost \
      -U app \
      application > backup.sql

Restaurer :

    psql \
      -h localhost \
      -U app \
      application < backup.sql

## Challenge

Automatiser :

    backup quotidien

Conserver :

    7 backups

Tester :

    Backup
       |
       v
    Delete Database
       |
       v
    Restore
       |
       v
    Verify

---

# Lab 25 — Cloud Cost Optimization

## Objectif

Comprendre les principaux facteurs de coûts Cloud.

Facteurs :

    CPU
    RAM
    Disk
    Network
    Storage
    Requests
    Runtime

Exemple :

    VM
      |
      +---- CPU
      +---- RAM
      +---- Disk
      +---- Network

## Challenge

Comparer :

    1 grosse VM

avec :

    3 petites VMs

Analyser :

    coût
    disponibilité
    performance
    complexité
    maintenance

---

# Lab 26 — Infrastructure complète avec Terraform

## Objectif

Créer une infrastructure complète avec Terraform.

Architecture :

    Terraform
        |
        +----------------+
        |                |
        v                v
     Network             VMs
                          |
              +-----------+-----------+
              |           |           |
              v           v           v
           frontend    backend     database

Terraform doit gérer :

    network
    VMs
    firewall
    Docker
    containers

## Structure

    terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    └── terraform.tfvars

## Challenge

Décrire toute l'infrastructure avec du code Terraform.

---

# Lab 27 — Terraform Modules

## Objectif

Créer des modules Terraform réutilisables.

Structure :

    terraform/
    ├── main.tf
    ├── modules/
    │   ├── network/
    │   ├── compute/
    │   ├── database/
    │   └── monitoring/
    │
    └── environments/
        ├── dev/
        └── prod/

Module network :

    module "network" {
      source = "./modules/network"
    }

Module compute :

    module "compute" {
      source = "./modules/compute"
    }

## Challenge

Créer les environnements :

    dev
    test
    prod

en réutilisant les mêmes modules.

---

# Lab 28 — Terraform State

## Objectif

Comprendre le Terraform State.

Terraform conserve l'état de l'infrastructure dans :

    terraform.tfstate

Afficher :

    terraform show

Lister :

    terraform state list

Afficher une ressource :

    terraform state show <resource>

## Questions

Pourquoi le State est-il nécessaire ?

Que se passe-t-il si le State est supprimé ?

Pourquoi faut-il protéger le State ?

Pourquoi un State distant est-il utilisé en environnement d'équipe ?

## Challenge

Documenter une stratégie de gestion du State pour une équipe DevOps.

---

# Lab 29 — CI/CD Cloud Infrastructure

## Objectif

Automatiser Terraform avec GitLab CI.

Architecture :

                         Git
                          |
                          v
                     GitLab CI
                          |
              +-----------+-----------+
              |                       |
              v                       v
        terraform validate       terraform plan
                                      |
                                      v
                               Manual Approval
                                      |
                                      v
                               terraform apply
                                      |
                                      v
                              Infrastructure

Pipeline :

    stages:
      - validate
      - plan
      - apply

Validate :

    terraform validate

Plan :

    terraform plan

Apply :

    terraform apply -auto-approve

## Challenge

Créer une pipeline complète.

La pipeline doit :

1. vérifier le code Terraform
2. générer le plan
3. demander une validation
4. appliquer l'infrastructure

---

# Lab 30 — Final Cloud Project

## Objectif

Construire un mini Cloud privé local.

Vous devez construire une infrastructure complète sans utiliser AWS, Azure ou GCP.

Architecture :

                              User
                                |
                                v
                         Load Balancer
                                |
                   +------------+------------+
                   |                         |
                   v                         v
                Frontend                 Frontend
                   |                         |
                   +------------+------------+
                                |
                           Private Network
                                |
                   +------------+------------+
                   |                         |
                   v                         v
                Backend                   Backend
                   |                         |
                   +------------+------------+
                                |
                           Database
                                |
                                v
                            PostgreSQL


                         Monitoring
                              |
                              v
                         Prometheus
                              |
                              v
                           Grafana

                         Logging
                              |
                              v
                           Logstash
                              |
                              v
                       Elasticsearch
                              |
                              v
                            Kibana

                         Storage
                              |
                              v
                            MinIO

---

# Projet Final — Architecture Cloud Locale

## Mission

Vous êtes une équipe DevOps chargée de construire une plateforme Cloud privée locale.

Vous ne disposez d'aucun compte :

    AWS
    Azure
    GCP

Vous devez donc construire une infrastructure locale permettant de reproduire les principaux concepts Cloud.

---

# Infrastructure

L'infrastructure doit comprendre :

    3 VMs

avec :

    cloud01
    cloud02
    cloud03

Chaque VM doit être accessible sur le réseau privé.

---

# Réseau

Créer une architecture logique :

    Public Network
          |
          v
    Load Balancer
          |
          v
    Frontend Network
          |
          v
    Backend Network
          |
          v
    Database Network

---

# Compute

Les VMs représentent les ressources Compute.

Exemple :

    cloud01
      |
      +---- Nginx
      +---- Docker

    cloud02
      |
      +---- Backend
      +---- Docker

    cloud03
      |
      +---- Database
      +---- Docker

---

# Storage

Déployer :

    PostgreSQL
    MinIO

PostgreSQL utilise un volume persistant.

MinIO fournit un stockage objet.

---

# Networking

Configurer :

    private network
    firewall
    ports
    DNS/service discovery
    load balancing

---

# Security

Mettre en place :

    SSH
    firewall
    segmentation réseau
    secrets
    TLS si possible

Les bases de données ne doivent pas être directement exposées.

---

# Infrastructure as Code

Terraform doit gérer les ressources d'infrastructure.

Ansible doit gérer la configuration des machines.

Architecture :

    Terraform
        |
        v
    Infrastructure
        |
        v
    Ansible
        |
        v
    Configuration
        |
        v
    Docker
        |
        v
    Applications

---

# Monitoring

Déployer :

    Prometheus
    Grafana

Surveiller :

    CPU
    RAM
    Disk
    Network
    Containers
    Application

---

# Logging

Déployer :

    Elasticsearch
    Logstash
    Kibana

Centraliser :

    Nginx logs
    Backend logs
    Docker logs

Créer un dashboard :

    Cloud Logs Dashboard

---

# Backup

Mettre en place :

    PostgreSQL backup

Stocker les backups dans :

    MinIO

Tester une restauration complète.

---

# Haute disponibilité

Déployer plusieurs backends :

    backend01
    backend02
    backend03

Utiliser un Load Balancer.

Simuler une panne :

    backend01 DOWN

L'application doit continuer à fonctionner.

---

# Auto Scaling

Simuler :

    CPU > 70%
        |
        v
    Add backend

et :

    CPU < 30%
        |
        v
    Remove backend

---

# Validation finale

L'infrastructure est considérée comme terminée si :

    [ ] 3 VMs fonctionnelles

    [ ] réseau privé fonctionnel

    [ ] SSH fonctionnel

    [ ] firewall configuré

    [ ] Docker installé

    [ ] Docker Compose fonctionnel

    [ ] Terraform fonctionnel

    [ ] Ansible fonctionnel

    [ ] Nginx fonctionnel

    [ ] Load Balancer fonctionnel

    [ ] plusieurs backends

    [ ] PostgreSQL fonctionnel

    [ ] stockage persistant

    [ ] MinIO fonctionnel

    [ ] Prometheus fonctionnel

    [ ] Grafana fonctionnel

    [ ] Elasticsearch fonctionnel

    [ ] Logstash fonctionnel

    [ ] Kibana fonctionnel

    [ ] logs centralisés

    [ ] monitoring opérationnel

    [ ] backup fonctionnel

    [ ] restauration testée

    [ ] secrets protégés

    [ ] infrastructure reproductible

    [ ] Terraform State géré

    [ ] CI/CD Terraform fonctionnel

---

# Mapping Cloud Provider

L'objectif est maintenant de faire le lien entre le laboratoire local et les providers Cloud.

## Compute

Notre laboratoire :

    Vagrant VM

AWS :

    EC2

Azure :

    Azure Virtual Machines

GCP :

    Compute Engine

---

## Network

Notre laboratoire :

    Private Network
    Firewall
    NAT

AWS :

    VPC
    Security Groups
    Route Tables
    NAT Gateway

Azure :

    VNet
    NSG
    Route Tables
    NAT Gateway

GCP :

    VPC
    Firewall Rules
    Routes
    Cloud NAT

---

## Storage

Notre laboratoire :

    Docker Volume
    MinIO

AWS :

    EBS
    S3

Azure :

    Managed Disk
    Blob Storage

GCP :

    Persistent Disk
    Cloud Storage

---

## Load Balancing

Notre laboratoire :

    Nginx

AWS :

    Elastic Load Balancing

Azure :

    Azure Load Balancer

GCP :

    Cloud Load Balancing

---

## Monitoring

Notre laboratoire :

    Prometheus
    Grafana

AWS :

    CloudWatch

Azure :

    Azure Monitor

GCP :

    Cloud Monitoring

---

## IAM

Notre laboratoire :

    utilisateurs
    rôles
    permissions

AWS :

    IAM

Azure :

    Microsoft Entra ID
    RBAC

GCP :

    IAM

---

## Infrastructure as Code

Notre laboratoire :

    Terraform

AWS :

    Terraform
    CloudFormation

Azure :

    Terraform
    ARM
    Bicep

GCP :

    Terraform

---

# Tableau de correspondance

| Concept | Lab local | AWS | Azure | GCP |
|---|---|---|---|---|
| Compute | Vagrant VM | EC2 | Azure VM | Compute Engine |
| Network | Private Network | VPC | VNet | VPC |
| Firewall | UFW | Security Group | NSG | Firewall Rules |
| Load Balancer | Nginx | ELB | Load Balancer | Cloud Load Balancing |
| Block Storage | VM Disk | EBS | Managed Disk | Persistent Disk |
| Object Storage | MinIO | S3 | Blob Storage | Cloud Storage |
| Monitoring | Prometheus/Grafana | CloudWatch | Azure Monitor | Cloud Monitoring |
| IAM | Users/Roles | IAM | Entra ID/RBAC | IAM |
| IaC | Terraform | Terraform | Terraform | Terraform |
| Configuration | Ansible | Ansible | Ansible | Ansible |
| Containers | Docker | ECS/EKS | AKS/Container Apps | GKE/Cloud Run |

---

# Best Practices Cloud

## Infrastructure

- Infrastructure as Code
- environnement reproductible
- séparation dev/test/prod
- documentation
- versioning
- automatisation

## Network

- segmentation réseau
- principe du moindre privilège
- services privés par défaut
- firewall
- éviter l'exposition inutile

## Security

- ne jamais stocker les secrets dans Git
- utiliser des rôles
- limiter les permissions
- utiliser TLS
- protéger les accès SSH
- utiliser des clés plutôt que des mots de passe
- appliquer le principe du moindre privilège

## Storage

- persistance
- backup
- restauration testée
- monitoring de l'espace
- stratégie de rétention

## Monitoring

Surveiller :

    CPU
    RAM
    Disk
    Network
    Application
    Logs

## Reliability

Prévoir :

    Healthchecks
    Load Balancing
    Redundancy
    Backup
    Disaster Recovery
    Monitoring

---

# Cheat Sheet Vagrant

Démarrer :

    vagrant up

Arrêter :

    vagrant halt

Redémarrer :

    vagrant reload

SSH :

    vagrant ssh

Statut :

    vagrant status

Détruire :

    vagrant destroy

Provisionner :

    vagrant provision

Démarrer avec provisioning :

    vagrant up --provision

Forcer le provisioning :

    vagrant provision

---

# Cheat Sheet Docker

Vérifier :

    docker ps

Lister tous les containers :

    docker ps -a

Images :

    docker images

Networks :

    docker network ls

Volumes :

    docker volume ls

Logs :

    docker logs <container>

Inspect :

    docker inspect <container>

Stats :

    docker stats

---

# Cheat Sheet Terraform

Initialiser :

    terraform init

Formater :

    terraform fmt

Valider :

    terraform validate

Planifier :

    terraform plan

Appliquer :

    terraform apply

Détruire :

    terraform destroy

Afficher :

    terraform show

Outputs :

    terraform output

Lister les ressources :

    terraform state list

---

# Cheat Sheet Ansible

Version :

    ansible --version

Ping :

    ansible all -m ping

Inventory :

    ansible-inventory --graph

Facts :

    ansible all -m setup

Playbook :

    ansible-playbook site.yml

Check :

    ansible-playbook site.yml --check

Diff :

    ansible-playbook site.yml --diff

Debug :

    ansible-playbook site.yml -vvv

---

# Cheat Sheet Linux Networking

Interfaces :

    ip addr

Routes :

    ip route

Ports :

    ss -lntup

DNS :

    resolvectl status

Tester :

    ping <ip>

Tester HTTP :

    curl http://<ip>

Tester port :

    nc -vz <host> <port>

---

# Cheat Sheet Cloud Concepts

## Compute

    VM
    Container
    Serverless

## Network

    VPC
    Subnet
    Route
    NAT
    Firewall
    Load Balancer

## Storage

    Block
    File
    Object

## Security

    IAM
    Roles
    Policies
    Secrets
    TLS

## Operations

    Monitoring
    Logging
    Backup
    Disaster Recovery

## Automation

    Terraform
    Ansible
    CI/CD

---

# Final Challenge — Cloud From Zero

## Situation

Vous recevez une machine vide.

Aucun compte Cloud n'est disponible.

Vous devez construire une infrastructure Cloud-like locale.

## Point de départ

    Ubuntu
       |
       +---- Hypervisor
       |
       +---- Vagrant
       |
       +---- Terraform
       |
       +---- Ansible
       |
       +---- Docker

## Mission

Automatiser entièrement :

    1. création des VMs
    2. configuration réseau
    3. configuration firewall
    4. installation Docker
    5. déploiement Nginx
    6. déploiement Backend
    7. déploiement PostgreSQL
    8. déploiement MinIO
    9. Load Balancing
    10. Monitoring
    11. Logging
    12. Backup
    13. Security
    14. CI/CD
    15. Disaster Recovery

## Objectif final

Passer de :

    Machine vide

à :

    Cloud privé local

avec :

    Compute
    Network
    Storage
    Security
    Load Balancing
    Monitoring
    Logging
    Backup
    Automation
    High Availability

---

# Architecture finale

                                  USER
                                    |
                                    v
                              Load Balancer
                                    |
                         +----------+----------+
                         |                     |
                         v                     v
                      Frontend              Frontend
                         |                     |
                         +----------+----------+
                                    |
                              Private Network
                                    |
                         +----------+----------+
                         |                     |
                         v                     v
                      Backend               Backend
                         |                     |
                         +----------+----------+
                                    |
                              Database Network
                                    |
                                    v
                                PostgreSQL
                                    |
                                    v
                                  Backup
                                    |
                                    v
                                  MinIO


        Monitoring                         Logging
            |                                  |
            v                                  v
       Prometheus                          Logstash
            |                                  |
            v                                  v
         Grafana                       Elasticsearch
                                             |
                                             v
                                           Kibana


                    Infrastructure Management
                              |
                 +------------+------------+
                 |                         |
                 v                         v
             Terraform                  Ansible
                 |                         |
                 v                         v
            Infrastructure            Configuration