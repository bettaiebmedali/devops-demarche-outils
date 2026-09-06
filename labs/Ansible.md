# 🚀 TP Ansible — Mission Mars : Déploiement automatique d'une colonie spatiale
### (Édition GitHub Codespaces — 100% conteneurisée)

---

## 🎯 Objectif du TP

Vous êtes l'équipe DevOps de la mission Mars.
Votre objectif est de préparer une infrastructure Linux complète en utilisant **Ansible** afin d'automatiser le déploiement d'une colonie martienne.

Contrairement à la version originale, **tout se passe dans GitHub Codespaces** :

- ❌ Pas de WSL
- ❌ Pas de machine Windows
- ✅ Un Codespace = une machine Linux dans le cloud, avec Docker déjà prêt à l'emploi
- ✅ **Le contrôleur Ansible lui-même est un conteneur Docker**, au même titre que les serveurs Mars
- ✅ **Toutes les images sont construites avec des `Dockerfile`** (pas d'installation manuelle paquet par paquet après coup)

À la fin du TP, vous serez capables de :

- écrire un `Dockerfile` et construire une image sur mesure avec `docker build`
- créer un inventaire Ansible
- communiquer avec des machines distantes (ici, des conteneurs) en SSH
- écrire des playbooks YAML
- utiliser des variables
- utiliser les templates Jinja2
- créer des rôles Ansible
- automatiser un déploiement complet

> 💡 **Comment utiliser ce document** : chaque étape est numérotée et contient une commande à exécuter, suivie d'un bloc **✅ Vérification** qui vous dit exactement quoi regarder pour savoir que ça a fonctionné avant de passer à la suite. Ne sautez pas les vérifications !

---

## 🏗️ Nouvelle architecture du laboratoire

Tout tourne **à l'intérieur du Codespace**, qui héberge lui-même 4 conteneurs Docker reliés par un réseau virtuel `mars-network` :

```
                 GitHub Codespace (Ubuntu, Docker déjà installé)
                              |
                   docker network : mars-network
                              |
        ------------------------------------------------
        |              |              |                |
  ansible-controller  mars-web      mars-db      mars-monitoring
     (conteneur)      (conteneur)   (conteneur)     (conteneur)
```

| Conteneur | Rôle |
|---|---|
| `ansible-controller` | Machine de pilotage : Ansible y est installé, c'est depuis là qu'on lance les playbooks |
| `mars-web` | Serveur web de la colonie |
| `mars-db` | Stockage des données |
| `mars-monitoring` | Surveillance de la base |

Le dossier de travail `mission-mars/` sera créé **sur le disque du Codespace** et **monté en volume** dans `ansible-controller`. Cela veut dire que vous éditerez vos fichiers YAML confortablement dans l'éditeur VS Code du Codespace, mais qu'ils seront exécutés depuis l'intérieur du conteneur `ansible-controller`, exactement comme s'il s'agissait d'une vraie machine de contrôle séparée.

---

## Partie 0 — Ouvrir le Codespace

1. Sur GitHub, allez sur un dépôt (vous pouvez créer un dépôt vide `mission-mars`).
2. Cliquez sur **Code** → onglet **Codespaces** → **Create codespace on main**.
3. Attendez que l'environnement se charge (VS Code dans le navigateur).
4. Ouvrez un terminal dans le Codespace : menu **Terminal → New Terminal**.

**✅ Vérification** — Docker doit déjà être disponible par défaut dans un Codespace standard :

```bash
docker --version
```

Vous devez voir une version de Docker s'afficher. Si ce n'est pas le cas, il faut ajouter la feature `docker-in-docker` au `devcontainer.json` du dépôt (dites-le-moi si vous êtes dans ce cas, c'est réglable en 2 minutes).

---

## Partie 1 — Préparation de l'environnement Codespace

Mettre à jour le système du Codespace (pas un conteneur, ici c'est la machine hôte du Codespace) :

```bash
sudo apt update && sudo apt upgrade -y
```

**✅ Vérification** : la commande se termine sans erreur (`0 upgraded` ou une liste de paquets mis à jour, mais pas de message rouge `E:`).

---

## Partie 2 — Construction des images Docker avec des Dockerfile

Plutôt que de partir d'une image `ubuntu:24.04` nue et d'installer les paquets un par un avec `docker exec ... apt install`, on construit **deux images sur mesure** : une pour le contrôleur, une pour les serveurs Mars. C'est l'approche propre en Docker : l'image contient déjà tout ce qu'il faut, et n'importe qui peut la reconstruire à l'identique avec `docker build`.

### 2.1 Créer l'arborescence du projet

```bash
mkdir -p ~/mission-mars/docker/controller
mkdir -p ~/mission-mars/docker/server
cd ~/mission-mars
```

### 2.2 Dockerfile du contrôleur

Créez **`mission-mars/docker/controller/Dockerfile`** :

```dockerfile
FROM ubuntu:24.04

# Tout ce dont le contrôleur Ansible a besoin, en une seule couche
RUN apt update && apt install -y \
        ansible \
        openssh-client \
        python3 \
        vim \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Génère une paire de clés SSH une fois pour toutes, à la construction de l'image
RUN mkdir -p /root/.ssh && \
    ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

WORKDIR /mission-mars

CMD ["sleep", "infinity"]
```

### 2.3 Dockerfile des serveurs Mars

Créez **`mission-mars/docker/server/Dockerfile`** :

```dockerfile
FROM ubuntu:24.04

# Tout ce dont un serveur Mars a besoin pour être piloté par Ansible en SSH
RUN apt update && apt install -y \
        openssh-server \
        python3 \
        sudo \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# La clé publique du contrôleur est copiée ici avant le build (étape 2.5)
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
```

> 💡 Cette image contient volontairement la clé publique du contrôleur : c'est comme ça qu'Ansible pourra s'y connecter en SSH sans mot de passe, dès le premier démarrage du conteneur, sans étape manuelle supplémentaire.

### 2.4 Construire l'image du contrôleur

```bash
docker build -t mars/controller:1.0 ./docker/controller
```

**✅ Vérification** :

```bash
docker images | grep mars/controller
```

### 2.5 Récupérer la clé publique du contrôleur pour l'image serveur

On lance temporairement un conteneur à partir de l'image du contrôleur, le temps d'en extraire la clé publique générée à l'étape 2.2 :

```bash
docker create --name temp-controller mars/controller:1.0
docker cp temp-controller:/root/.ssh/id_rsa.pub ./docker/server/authorized_keys
docker rm temp-controller
```

**✅ Vérification** :

```bash
cat ./docker/server/authorized_keys
```

Vous devez voir une ligne commençant par `ssh-rsa AAAA...`.

### 2.6 Construire l'image des serveurs Mars

```bash
docker build -t mars/server:1.0 ./docker/server
```

**✅ Vérification** :

```bash
docker images | grep mars/server
```

<details>
<summary>🤔 Pourquoi deux `docker build` et pas un seul ?</summary>

L'image `mars/server` a besoin de la clé publique générée **à l'intérieur** de l'image `mars/controller`. Il faut donc construire le contrôleur d'abord, en extraire la clé publique, puis seulement construire l'image serveur avec cette clé intégrée via `COPY`. C'est une bonne illustration d'une dépendance entre deux images Docker.

</details>

---

## Partie 3 — Création du réseau et lancement des conteneurs

### 3.1 Créer le réseau Docker

```bash
docker network create mars-network
```

**✅ Vérification** :

```bash
docker network ls | grep mars-network
```

### 3.2 Lancer les 4 conteneurs à partir de vos images

```bash
# Le contrôleur Ansible — notez le volume monté, c'est lui qui relie
# votre dossier VS Code au conteneur qui exécutera les commandes
docker run -d --name ansible-controller \
  --network mars-network \
  -v ~/mission-mars:/mission-mars \
  -w /mission-mars \
  mars/controller:1.0

docker run -d --name mars-web \
  --network mars-network \
  -p 8080:80 \
  mars/server:1.0

docker run -d --name mars-db \
  --network mars-network \
  mars/server:1.0

docker run -d --name mars-monitoring \
  --network mars-network \
  mars/server:1.0
```

**✅ Vérification** :

```bash
docker ps
```

Vous devez voir **4 conteneurs** avec le statut `Up`, tous démarrés à partir de vos propres images (`mars/controller:1.0` et `mars/server:1.0`), sans aucune installation manuelle après le `docker run`.

---

## Partie 4 — Vérification de la connexion SSH

Grâce aux images construites en Partie 2, aucune installation ni copie de clé n'est nécessaire ici : tout était déjà prêt dans les images. Il ne reste qu'à vérifier que ça fonctionne.

```bash
docker exec ansible-controller ansible --version
```

**✅ Vérification** : la version d'Ansible s'affiche (ex : `ansible [core 2.16.x]`), preuve que l'image contrôleur est bien construite.

Testez ensuite une connexion SSH directe depuis le contrôleur vers un serveur :

```bash
docker exec ansible-controller ssh -o StrictHostKeyChecking=no root@mars-web hostname
```

**✅ Vérification** : vous devez voir s'afficher `mars-web`, sans qu'aucun mot de passe ne soit demandé — la clé publique intégrée dans l'image `mars/server:1.0` a fait tout le travail.

<details>
<summary>😱 Ça ne marche pas ? Cliquez ici pour les causes fréquentes</summary>

- Vérifiez que les 4 conteneurs sont bien `Up` (`docker ps`)
- Vérifiez que `docker/server/authorized_keys` contient bien une clé (Partie 2.5) **avant** d'avoir construit `mars/server:1.0` — si le fichier était vide au moment du build, il faut refaire les étapes 2.5 et 2.6
- Si vous modifiez le Dockerfile du contrôleur après coup, la clé change : il faut alors refaire les étapes 2.4 à 2.6 et relancer les conteneurs (`docker rm -f` puis `docker run`) pour que tout soit synchronisé

</details>

---

## Partie 5 — Création de l'inventaire Ansible

Dans VS Code (panneau de gauche), ouvrez le dossier `mission-mars` qui a été créé à la racine de votre Codespace, et créez le fichier :

**`mission-mars/inventory.ini`**

```ini
[mars_servers]
mars-web ansible_host=mars-web ansible_user=root
mars-db ansible_host=mars-db ansible_user=root
mars-monitoring ansible_host=mars-monitoring ansible_user=root

[mars_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

```

**✅ Vérification** — testez la communication Ansible :

```bash
docker exec ansible-controller ansible mars_servers -i inventory.ini -m ping
```

Les 3 serveurs doivent répondre `"ping": "pong"` en vert.

<details>
<summary>😱 Ça ne marche pas ? Cliquez ici pour les causes fréquentes</summary>

- Vérifiez que les 3 conteneurs cibles sont bien `Up` (`docker ps`)
- Vérifiez que le test SSH manuel de la Partie 4 fonctionne
- Le nom `inventory.ini` doit être exactement celui-là, et vous devez lancer la commande depuis `/mission-mars` dans le conteneur (c'est le cas si vous utilisez `docker exec ansible-controller ...` tel quel, grâce à `-w /mission-mars` défini à la création du conteneur)

</details>

---

## Partie 6 — Premier Playbook : préparation des astronautes

Créez **`mission-mars/prepare_mars.yml`** :

```yaml
---
- name: Prepare Mars infrastructure
  hosts: mars_servers
  become: yes

  tasks:

  - name: Install tools
    apt:
      name:
        - vim
        - curl
        - htop
        - net-tools
      state: present
      update_cache: yes
```

Exécution :

```bash
docker exec ansible-controller ansible-playbook -i inventory.ini prepare_mars.yml
```

**✅ Vérification** : dans le résumé final (`PLAY RECAP`), chaque serveur doit afficher `failed=0` et `unreachable=0`.

---

## Partie 7 — Création des utilisateurs astronautes

Ajoutez à la fin de **`prepare_mars.yml`**, ou créez un nouveau fichier `create_users.yml` :

```yaml
---
- name: Create astronauts
  hosts: mars_servers
  become: yes

  tasks:

  - name: Create users
    user:
      name: "{{ item }}"
      state: present
    loop:
      - commander
      - engineer
      - scientist
```

Exécution :

```bash
docker exec ansible-controller ansible-playbook -i inventory.ini create_users.yml
```

**✅ Vérification** :

```bash
docker exec ansible-controller ansible mars_servers -i inventory.ini -a "id commander"
```

Les 3 serveurs doivent renvoyer un `uid` pour l'utilisateur `commander`.

---

## Partie 8 — Déploiement du serveur Web Mars

### 8.1 Créer le template Jinja2

Créez le dossier et le fichier **`mission-mars/templates/index.html.j2`** :

```jinja2
<h1>🚀 Welcome to Mars Colony</h1>

<p>
Server : {{ ansible_hostname }}
</p>

<p>
Mission : {{ mission }}
</p>
```

### 8.2 Créer le playbook web

Créez **`mission-mars/deploy_web.yml`** :

```yaml
---
- name: Deploy Mars web server
  hosts: mars-web
  become: yes
  vars:
    mission: "Mission Mars 2030"
  tasks:

  - name: Install nginx
    apt:
      name: nginx
      state: present
      update_cache: yes

  - name: Deploy web page
    template:
      src: index.html.j2
      dest: /var/www/html/index.html

  - name: Start nginx
    service:
      name: nginx
      state: started
```

Exécution :

```bash
docker exec ansible-controller ansible-playbook -i inventory.ini deploy_web.yml
```

**✅ Vérification** — depuis le terminal du Codespace (pas depuis le conteneur), le port 8080 a été publié à la création de `mars-web` :

```bash
curl http://localhost:8080
```

Vous devez voir le HTML `Welcome to Mars Colony`. Dans un vrai Codespace, vous pouvez aussi ouvrir l'onglet **Ports** de VS Code, repérer le port `8080`, et cliquer sur le globe 🌐 pour l'ouvrir dans le navigateur.

---

# Partie 9 — Variables Ansible

## Objectif

Dans cette partie, nous allons externaliser la variable `mission` dans un fichier `group_vars` afin de comprendre le fonctionnement des variables Ansible.

---

## 9.1 Suppression de la variable `mission` dans le playbook

Lors de la partie précédente, pour résoudre l'erreur :

```
AnsibleUndefinedVariable: 'mission' is undefined
```

nous avons pu ajouter temporairement une variable directement dans le playbook :

```yaml
vars:
  mission: "Mission Mars 2030"
```

Avant de commencer cette partie, cette variable doit être supprimée.

Pourquoi ?

Parce que l'objectif est maintenant d'utiliser les variables globales Ansible avec `group_vars`.

Si la variable reste dans le playbook :

```yaml
vars:
  mission: "Mission Mars 2030"
```

elle sera prioritaire et Ansible utilisera cette valeur au lieu de celle définie dans :

```
group_vars/all.yml
```

---

## 9.2 Ordre de priorité des variables Ansible

Ansible possède un mécanisme de priorité des variables.

Une même variable peut être définie à plusieurs endroits :

- ligne de commande ;
- playbook ;
- inventaire ;
- host_vars ;
- group_vars ;
- rôles.

Lorsque plusieurs valeurs existent pour une même variable, Ansible utilise celle qui possède la priorité la plus élevée.

Ordre simplifié du plus prioritaire au moins prioritaire :

| Priorité | Source | Exemple |
|---|---|---|
| 1 | Variables extra (`-e`) | `ansible-playbook deploy.yml -e "mission=Test"` |
| 2 | Variables définies dans le playbook | `vars:` dans `deploy_web.yml` |
| 3 | Variables au niveau d'une tâche | `vars:` dans une task |
| 4 | Variables d'hôte (`host_vars`) | `host_vars/mars-web.yml` |
| 5 | Variables de groupe (`group_vars`) | `group_vars/all.yml` |
| 6 | Variables par défaut d'un rôle | `roles/nginx/defaults/main.yml` |

Exemple :

Dans `deploy_web.yml` :

```yaml
vars:
  mission: "Mission Mars 2030"
```

Dans `group_vars/all.yml` :

```yaml
mission: "Mars Exploration 2035"
```

Résultat :

```
Mission Mars 2030
```

La valeur du playbook gagne car elle possède une priorité supérieure.

C'est pourquoi il faut supprimer la variable `mission` du playbook avant de continuer.

---

## 9.3 Création du fichier `group_vars/all.yml`

Créer le dossier :

```bash
mkdir group_vars
```

Créer le fichier :

```bash
touch group_vars/all.yml
```

Structure finale :

```
mission-mars/
├── inventory.ini
├── deploy_web.yml
├── templates/
│   └── index.html.j2
└── group_vars/
    └── all.yml
```

---

## 9.4 Définition de la variable globale

Modifier le fichier :

```
group_vars/all.yml
```

avec :

```yaml
mission: Mars Exploration 2035
```

Ansible charge automatiquement ce fichier.

Aucun changement n'est nécessaire dans le playbook.

---

## 9.5 Utilisation dans le template Jinja2

Le fichier :

```
templates/index.html.j2
```

contient :

```jinja2
<h1>🚀 Welcome to Mars Colony</h1>

<p>
Server : {{ ansible_hostname }}
</p>

<p>
Mission : {{ mission }}
</p>
```

La variable :

```jinja2
{{ mission }}
```

sera remplacée automatiquement par la valeur définie dans :

```
group_vars/all.yml
```

---

## 9.6 Déploiement

Relancer le playbook :

```bash
docker exec ansible-controller ansible-playbook -i inventory.ini deploy_web.yml
```

Ansible va :

1. Charger `group_vars/all.yml`.
2. Récupérer la variable `mission`.
3. Envoyer la variable au moteur de template Jinja2.
4. Générer le fichier :

```
/var/www/html/index.html
```

---

## 9.7 Vérification

Depuis la machine hôte :

```bash
curl http://localhost:8080
```

Résultat attendu :

```html
<h1>🚀 Welcome to Mars Colony</h1>

<p>
Server : mars-web
</p>

<p>
Mission : Mars Exploration 2035
</p>
```

La variable est maintenant gérée proprement par la configuration Ansible et non plus directement dans le playbook.

**✅ Vérification** : la page affichée doit maintenant contenir `Mission : Mars Exploration 2035`.

---

# Partie 10 — Collecte des informations système avec Ansible Facts

## Objectif

Ansible possède un mécanisme appelé **Facts** qui permet de récupérer automatiquement des informations sur les machines cibles avant l'exécution des tâches.

Ces informations sont collectées grâce au module Ansible :

```text
setup
```

Le module `setup` interroge la machine distante et retourne un ensemble d'informations système sous forme de variables appelées :

```
ansible_facts
```

Ces variables peuvent ensuite être utilisées dans les playbooks.

---

# 10.1 Exécution du module setup

Lancer la commande :

```bash
docker exec ansible-controller ansible mars_servers -i inventory.ini -m setup
```

Décomposition de la commande :

| Élément | Signification |
|---|---|
| `docker exec ansible-controller` | Exécute la commande dans le conteneur Ansible |
| `ansible` | Lance une commande Ansible ad-hoc |
| `mars_servers` | Groupe de machines défini dans l'inventaire |
| `-i inventory.ini` | Utilise cet inventaire |
| `-m setup` | Utilise le module `setup` pour collecter les informations système |

---

# 10.2 Exemple d'inventaire

Exemple :

```ini
[mars_servers]
mars-web
```

Le groupe :

```
mars_servers
```

indique à Ansible quelles machines doivent être interrogées.

---

# 10.3 Fonctionnement interne

Lors de l'exécution :

```bash
ansible mars_servers -m setup
```

Ansible réalise plusieurs étapes :

1. Connexion à la machine distante.
2. Exécution du module Python `setup`.
3. Collecte des informations système.
4. Retour des résultats au contrôleur Ansible.

Le résultat est retourné sous forme JSON.

---

# 10.4 Informations récupérées

Le module `setup` récupère plusieurs catégories d'informations.

## Processeur (CPU)

Exemple :

```json
"ansible_processor": [
    "0",
    "Genuine Intel(R) CPU"
]
```

Permet de connaître :

- le type de processeur ;
- l'architecture ;
- le nombre de CPU.

Variable principale :

```yaml
ansible_processor
```

---

## Mémoire RAM

Exemple :

```json
"ansible_memtotal_mb": 4096
```

Cette variable indique la mémoire totale disponible en Mo.

Variable :

```yaml
ansible_memtotal_mb
```

Exemple d'utilisation :

```yaml
- debug:
    msg: "RAM disponible : {{ ansible_memtotal_mb }} MB"
```

Résultat :

```
RAM disponible : 4096 MB
```

---

## Système d'exploitation

Exemple :

```json
"ansible_distribution": "Ubuntu"
```

Informations disponibles :

```yaml
ansible_distribution
ansible_distribution_version
ansible_os_family
```

Exemple :

```yaml
- debug:
    msg: "OS : {{ ansible_distribution }} {{ ansible_distribution_version }}"
```

Résultat :

```
OS : Ubuntu 22.04
```

---

## Réseau

Exemple :

```json
"ansible_default_ipv4": {
    "address": "172.18.0.2",
    "interface": "eth0"
}
```

Informations récupérées :

- adresse IP ;
- interface réseau ;
- passerelle ;
- MAC address.

Variables :

```yaml
ansible_default_ipv4.address
ansible_interfaces
```

Exemple :

```yaml
- debug:
    msg: "IP : {{ ansible_default_ipv4.address }}"
```

---

## Nom de machine (hostname)

Exemple :

```json
"ansible_hostname": "mars-web"
```

Variable :

```yaml
ansible_hostname
```

Utilisation dans un template :

```jinja2
Server : {{ ansible_hostname }}
```

Résultat :

```
Server : mars-web
```

---

# 10.5 Exemple de sortie

La sortie contient une structure similaire :

```json
{
    "ansible_facts": {
        "ansible_hostname": "mars-web",
        "ansible_distribution": "Ubuntu",
        "ansible_memtotal_mb": 4096,
        "ansible_processor": [
            "Intel CPU"
        ]
    }
}
```

La clé importante est :

```text
ansible_facts
```

Elle contient toutes les variables collectées automatiquement.

---

# 10.6 Utilisation dans un playbook

Les Facts sont automatiquement disponibles dans les playbooks.

Exemple :

```yaml
- name: Display system information
  hosts: mars_servers

  tasks:

  - name: Show hostname
    debug:
      msg: "Machine : {{ ansible_hostname }}"

  - name: Show operating system
    debug:
      msg: "OS : {{ ansible_distribution }}"

  - name: Show RAM
    debug:
      msg: "RAM : {{ ansible_memtotal_mb }} MB"
```

Résultat :

```
Machine : mars-web
OS : Ubuntu
RAM : 4096 MB
```

---

# 10.7 Vérification

La sortie de la commande :

```bash
docker exec ansible-controller ansible mars_servers -i inventory.ini -m setup
```

doit contenir :

```
"ansible_facts"
```

avec notamment :

```
ansible_processor
ansible_memtotal_mb
ansible_distribution
ansible_hostname
ansible_default_ipv4
```

Les Facts permettent donc à Ansible d'adapter automatiquement les déploiements selon l'environnement réel de chaque serveur.

**✅ Vérification** : la sortie JSON doit contenir une clé `"ansible_facts"` avec, entre autres, `ansible_processor`, `ansible_memtotal_mb`, `ansible_distribution`.

---

## Partie 11 — Création d'un rôle Ansible

Structure cible :

```
mission-mars/
├── inventory.ini
├── deploy_mars.yml
└── roles/
    ├── common/
    ├── nginx/
    └── monitoring/
```

Créer le rôle nginx :

```bash
docker exec ansible-controller ansible-galaxy init roles/nginx
```

**✅ Vérification** :

```bash
ls ~/mission-mars/roles/nginx
```

Vous devez voir les sous-dossiers `tasks/`, `handlers/`, `templates/`, `defaults/`, etc.

> 🎯 **À vous de jouer** : répétez la commande pour créer `roles/common` et `roles/monitoring`, puis déplacez le contenu de vos playbooks précédents (installation d'outils → `roles/common/tasks/main.yml`, installation nginx + template → `roles/nginx/tasks/main.yml`) dans la structure de rôle correspondante.

---

## 🏁 Mission finale 🚀
in-progress



## 🏆 Bonus Challenges

### Challenge Alien Detector 👽

Créez, via un playbook, le fichier `/etc/mars/alien.conf` sur tous les serveurs avec le contenu :

```ini
alien_detection=true
```

<details>
<summary>💡 Indice (cliquez pour afficher)</summary>

Utilisez le module `file` pour créer le dossier `/etc/mars`, puis le module `copy` avec l'option `content:` pour écrire le fichier — pas besoin de template Jinja2 ici puisqu'il n'y a pas de variable.

</details>

### Challenge Message du Commandant

Modifiez `/etc/motd` sur tous les serveurs pour qu'il affiche à la connexion :

```
🚀 Bienvenue sur Mars
Serveur sécurisé par Ansible
```

<details>
<summary>💡 Indice (cliquez pour afficher)</summary>

Même approche que le challenge précédent : module `copy` avec `content:`, cible `/etc/motd`, sur `hosts: mars_servers`.

</details>

---

## 📝 Quiz corrigé

> Cliquez sur chaque **"Afficher la réponse"** pour révéler la correction.

**Question 1 — Quel est le rôle d'Ansible Controller ?**

A. Stocker les bases de données
B. Exécuter les automatisations
C. Remplacer Docker

<details>
<summary>Afficher la réponse</summary>

**Réponse : B**

</details>

---

**Question 2 — Quel format utilise un playbook Ansible ?**

A. JSON
B. XML
C. YAML

<details>
<summary>Afficher la réponse</summary>

**Réponse : C**

</details>

---

**Question 3 — Quelle commande teste la communication Ansible ?**

A. `ansible all -m ping`
B. `docker ping`
C. `ssh ping`

<details>
<summary>Afficher la réponse</summary>

**Réponse : A**

</details>

---

**Question 4 — Quel outil permet de créer un rôle Ansible ?**

A. `ansible-role-create`
B. `ansible-galaxy init`
C. `ansible-new-role`

<details>
<summary>Afficher la réponse</summary>

**Réponse : B**

</details>

---

**Question 5 — Quel langage utilisent les templates Ansible ?**

A. Python
B. Jinja2
C. Java

<details>
<summary>Afficher la réponse</summary>

**Réponse : B**

</details>

---

**Question 6 — Pourquoi utiliser Ansible plutôt que configurer manuellement les serveurs ?**

<details>
<summary>Afficher la réponse</summary>

**Réponse :** Pour automatiser, reproduire et fiabiliser les déploiements.

</details>

---

## 🧹 Nettoyage (fin de TP)

Une fois le TP terminé, pour libérer les ressources du Codespace :

```bash
docker rm -f ansible-controller mars-web mars-db mars-monitoring
docker network rm mars-network
docker rmi mars/controller:1.0 mars/server:1.0
```

---

## Fin du TP

🚀 **Mission réussie** : la colonie Mars est opérationnelle grâce à l'automatisation DevOps — entièrement pilotée depuis un GitHub Codespace, contrôleur Ansible compris.