# ELK Stack Labs

## Elasticsearch + Logstash + Kibana

---

# Objectifs

Ce TP permet d'apprendre progressivement à installer, configurer, exploiter et administrer une stack ELK basée sur :

- Elasticsearch
- Logstash
- Kibana
- Docker
- Docker Compose
- REST API Elasticsearch
- Index
- Documents
- Mappings
- Queries
- Log ingestion
- Log parsing
- Grok
- Pipelines Logstash
- Kibana
- Dashboards
- Visualisations
- Monitoring
- Troubleshooting
- Security
- TLS
- Healthchecks
- Persistance
- Architecture production

Architecture générale :

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
                              |
                              v
                           User


---

# Lab 1 — Introduction à ELK

## Objectif

Comprendre le rôle de chaque composant.

## Elasticsearch

Elasticsearch est le moteur de recherche et d'analyse.

Il stocke les événements sous forme de documents JSON.

Exemple :

    {
      "timestamp": "2026-09-05T20:00:00Z",
      "level": "ERROR",
      "service": "backend",
      "message": "Database connection failed"
    }

## Logstash

Logstash collecte et transforme les événements.

Architecture :

    Input
      |
      v
    Filter
      |
      v
    Output

Exemple :

    Application
        |
        v
    Logstash
        |
      Grok
        |
        v
    Elasticsearch

## Kibana

Kibana permet de :

- rechercher les logs
- créer des visualisations
- créer des dashboards
- analyser les données
- surveiller Elasticsearch

## Challenge

Expliquer le rôle de :

    Elasticsearch
    Logstash
    Kibana

et expliquer pourquoi Logstash n'est pas obligatoire dans toutes les architectures ELK.


---

# Lab 2 — Architecture Docker ELK

## Objectif

Préparer une infrastructure ELK avec Docker.

Architecture :

                         Docker Host
                              |
             +----------------+----------------+
             |                |                |
             v                v                v
       Elasticsearch       Logstash          Kibana
         :9200              :5044            :5601

Créer :

    elk/
    ├── docker-compose.yml
    ├── elasticsearch/
    ├── logstash/
    └── kibana/

Créer le réseau :

    docker network create elk-network

## Challenge

Identifier :

    ports
    containers
    network
    volumes


---

# Lab 3 — Déployer Elasticsearch

## Objectif

Déployer Elasticsearch avec Docker.

Créer :

    docker-compose.yml

Exemple :

    services:

      elasticsearch:
        image: docker.elastic.co/elasticsearch/elasticsearch:9.2.0
        container_name: elasticsearch
        environment:
          - discovery.type=single-node
          - xpack.security.enabled=false
          - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
        ports:
          - "9200:9200"
        volumes:
          - elasticsearch-data:/usr/share/elasticsearch/data
        networks:
          - elk

    volumes:
      elasticsearch-data:

    networks:
      elk:

Démarrer :

    docker compose up -d

Vérifier :

    docker ps

Tester :

    curl http://localhost:9200

Résultat attendu :

    {
      "name": "...",
      "cluster_name": "...",
      "version": {
        ...
      }
    }

## Challenge

Identifier :

- nom du cluster
- version Elasticsearch
- nom du node


---

# Lab 4 — Elasticsearch REST API

## Objectif

Manipuler Elasticsearch avec son API REST.

Tester le cluster :

    curl http://localhost:9200

Informations du cluster :

    curl http://localhost:9200/_cluster/health?pretty

Lister les nodes :

    curl http://localhost:9200/_cat/nodes?v

Lister les indices :

    curl http://localhost:9200/_cat/indices?v

Afficher les shards :

    curl http://localhost:9200/_cat/shards?v

Afficher les allocations :

    curl http://localhost:9200/_cat/allocation?v

## Challenge

Déterminer :

    cluster status
    nombre de nodes
    nombre d'indices
    nombre de shards


---

# Lab 5 — Index et Documents

## Objectif

Créer des index et manipuler des documents.

Créer un index :

    curl -X PUT \
      http://localhost:9200/logs

Vérifier :

    curl http://localhost:9200/_cat/indices?v

Créer un document :

    curl -X POST \
      http://localhost:9200/logs/_doc \
      -H "Content-Type: application/json" \
      -d '{
        "level": "INFO",
        "service": "backend",
        "message": "Application started"
      }'

Rechercher :

    curl http://localhost:9200/logs/_search?pretty

## Document avec ID

    curl -X PUT \
      http://localhost:9200/logs/_doc/1 \
      -H "Content-Type: application/json" \
      -d '{
        "level": "ERROR",
        "service": "backend",
        "message": "Database unavailable"
      }'

Récupérer :

    curl http://localhost:9200/logs/_doc/1?pretty

## Challenge

Créer 10 documents représentant des logs applicatifs.


---

# Lab 6 — Elasticsearch Queries

## Objectif

Rechercher des documents.

Recherche globale :

    curl -X GET \
      http://localhost:9200/logs/_search?pretty

Recherche par service :

    curl -X GET \
      http://localhost:9200/logs/_search \
      -H "Content-Type: application/json" \
      -d '{
        "query": {
          "match": {
            "service": "backend"
          }
        }
      }'

Recherche des erreurs :

    curl -X GET \
      http://localhost:9200/logs/_search \
      -H "Content-Type: application/json" \
      -d '{
        "query": {
          "match": {
            "level": "ERROR"
          }
        }
      }'

Recherche exacte :

    curl -X GET \
      http://localhost:9200/logs/_search \
      -H "Content-Type: application/json" \
      -d '{
        "query": {
          "term": {
            "level.keyword": "ERROR"
          }
        }
      }'

## Bool Query

    {
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "service": "backend"
              }
            }
          ],
          "filter": [
            {
              "term": {
                "level.keyword": "ERROR"
              }
            }
          ]
        }
      }
    }

## Challenge

Rechercher :

- tous les ERROR
- tous les logs backend
- les ERROR du backend
- les logs contenant "database"


---

# Lab 7 — Mappings

## Objectif

Comprendre les mappings Elasticsearch.

Exemple :

    {
      "mappings": {
        "properties": {
          "@timestamp": {
            "type": "date"
          },
          "level": {
            "type": "keyword"
          },
          "service": {
            "type": "keyword"
          },
          "message": {
            "type": "text"
          },
          "response_time": {
            "type": "integer"
          }
        }
      }
    }

Créer l'index :

    curl -X PUT \
      http://localhost:9200/application-logs \
      -H "Content-Type: application/json" \
      -d '{
        "mappings": {
          "properties": {
            "@timestamp": {
              "type": "date"
            },
            "level": {
              "type": "keyword"
            },
            "service": {
              "type": "keyword"
            },
            "message": {
              "type": "text"
            },
            "response_time": {
              "type": "integer"
            }
          }
        }
      }'

Afficher le mapping :

    curl http://localhost:9200/application-logs/_mapping?pretty

## Challenge

Créer un mapping pour :

    timestamp
    service
    host
    level
    message
    status_code
    response_time


---

# Lab 8 — Kibana

## Objectif

Déployer Kibana et le connecter à Elasticsearch.

Ajouter :

    kibana:
      image: docker.elastic.co/kibana/kibana:9.2.0
      container_name: kibana
      environment:
        ELASTICSEARCH_HOSTS: '["http://elasticsearch:9200"]'
      ports:
        - "5601:5601"
      networks:
        - elk

Démarrer :

    docker compose up -d

Vérifier :

    docker ps

Accéder à :

    http://localhost:5601

## Vérification

Dans Kibana :

    Stack Management

puis vérifier :

    Elasticsearch

## Challenge

Vérifier que Kibana communique correctement avec Elasticsearch.


---

# Lab 9 — Kibana Data Views

## Objectif

Créer un Data View pour visualiser les logs.

Créer des documents dans :

    application-logs

Dans Kibana :

    Stack Management
        |
        v
    Data Views

Créer :

    application-logs*

Utiliser :

    @timestamp

comme champ temporel.

Aller ensuite dans :

    Discover

## Challenge

Afficher :

- timestamp
- service
- level
- message
- response_time


---

# Lab 10 — Logstash

## Objectif

Déployer Logstash.

Structure :

    logstash/
    ├── config/
    │   └── logstash.yml
    └── pipeline/
        └── logstash.conf

Configuration :

    input {
      stdin {
      }
    }

    output {
      stdout {
        codec => rubydebug
      }
    }

Démarrer Logstash.

Entrer :

    Hello ELK

Observer le résultat dans les logs du container.

Vérifier :

    docker logs logstash

## Challenge

Faire fonctionner :

    stdin
       |
       v
    Logstash
       |
       v
    stdout


---

# Lab 11 — Logstash vers Elasticsearch

## Objectif

Envoyer les événements Logstash vers Elasticsearch.

Configuration :

    input {
      stdin {
      }
    }

    output {
      elasticsearch {
        hosts => ["http://elasticsearch:9200"]
        index => "logstash-demo"
      }

      stdout {
        codec => rubydebug
      }
    }

Envoyer :

    Application started

Puis vérifier :

    curl http://localhost:9200/_cat/indices?v

Rechercher :

    curl http://localhost:9200/logstash-demo/_search?pretty

## Challenge

Envoyer plusieurs logs et vérifier leur présence dans Elasticsearch.


---

# Lab 12 — Logstash Inputs

## Objectif

Découvrir les différents inputs Logstash.

Inputs courants :

    stdin
    file
    tcp
    udp
    beats
    http

## TCP

Exemple :

    input {
      tcp {
        port => 5000
        codec => json
      }
    }

Tester :

    echo '{"level":"INFO","message":"Hello ELK"}' | nc localhost 5000

## HTTP

Exemple :

    input {
      http {
        port => 8080
      }
    }

Tester :

    curl -X POST \
      http://localhost:8080 \
      -H "Content-Type: application/json" \
      -d '{
        "level": "INFO",
        "message": "Application started"
      }'

## Challenge

Créer une pipeline recevant des logs via HTTP.


---

# Lab 13 — Logstash Filters

## Objectif

Transformer les logs avant leur stockage.

Pipeline :

    input
      |
      v
    filter
      |
      v
    output

Exemple :

    filter {
      mutate {
        add_field => {
          "environment" => "dev"
        }
      }
    }

Ajouter un champ :

    filter {
      mutate {
        add_field => {
          "application" => "backend"
        }
      }
    }

Supprimer un champ :

    filter {
      mutate {
        remove_field => [
          "host"
        ]
      }
    }

Convertir un champ :

    filter {
      mutate {
        convert => {
          "response_time" => "integer"
        }
      }
    }

## Challenge

Ajouter :

    environment
    application
    team


---

# Lab 14 — Grok

## Objectif

Parser des logs texte.

Exemple :

    192.168.1.10 - - [05/Sep/2026:20:10:10 +0000] "GET /api/users HTTP/1.1" 200 1532

Utiliser :

    filter {
      grok {
        match => {
          "message" => '%{IP:client_ip} - - \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:http_version}" %{NUMBER:status_code:int} %{NUMBER:bytes:int}'
        }
      }
    }

Le résultat doit contenir :

    client_ip
    timestamp
    method
    request
    http_version
    status_code
    bytes

## Challenge

Parser un log Nginx.

Extraire :

    IP
    date
    HTTP method
    URL
    status
    response size


---

# Lab 15 — Logstash Date et GeoIP

## Objectif

Transformer correctement les timestamps et enrichir les logs.

## Date

Exemple :

    filter {
      date {
        match => [
          "timestamp",
          "dd/MMM/yyyy:HH:mm:ss Z"
        ]
        target => "@timestamp"
      }
    }

## GeoIP

Exemple :

    filter {
      geoip {
        source => "client_ip"
      }
    }

Cela permet d'obtenir des informations géographiques.

## Challenge

À partir d'une IP client :

    client_ip

ajouter les informations GeoIP disponibles.

Créer ensuite une visualisation Kibana par pays.


---

# Lab 16 — Collecte des logs Nginx

## Objectif

Construire une pipeline ELK complète.

Architecture :

    Nginx
      |
      | access.log
      v
    Logstash
      |
      | Grok
      | Date
      | GeoIP
      v
    Elasticsearch
      |
      v
    Kibana

Exemple de log :

    127.0.0.1 - - [05/Sep/2026:20:10:10 +0000] "GET / HTTP/1.1" 200 615

Pipeline :

    input {
      file {
        path => "/var/log/nginx/access.log"
        start_position => "beginning"
        sincedb_path => "/dev/null"
      }
    }

    filter {
      grok {
        match => {
          "message" => '%{IP:client_ip} - - \[%{HTTPDATE:timestamp}\] "%{WORD:method} %{URIPATHPARAM:request} HTTP/%{NUMBER:http_version}" %{NUMBER:status_code:int} %{NUMBER:bytes:int}'
        }
      }

      date {
        match => [
          "timestamp",
          "dd/MMM/yyyy:HH:mm:ss Z"
        ]
        target => "@timestamp"
      }
    }

    output {
      elasticsearch {
        hosts => ["http://elasticsearch:9200"]
        index => "nginx-logs"
      }

      stdout {
        codec => rubydebug
      }
    }

## Challenge

Afficher dans Kibana :

    requests
    status codes
    URLs
    client IPs


---

# Lab 17 — Dashboard Kibana

## Objectif

Construire un dashboard de monitoring.

Créer les visualisations suivantes :

## Nombre de requêtes

Afficher :

    count(requests)

## Requêtes par statut

Créer un graphique :

    200
    301
    400
    401
    403
    404
    500

## Requêtes par URL

Afficher les URLs les plus demandées.

## Requêtes dans le temps

Créer un graphique temporel.

## Top clients

Afficher les IP les plus actives.

## Dashboard

Créer :

    Nginx Monitoring Dashboard

Contenu :

    +---------------------------------------+
    | Total Requests                       |
    +---------------------------------------+
    | Requests Over Time                   |
    +-------------------+-------------------+
    | Status Codes      | Top URLs          |
    +-------------------+-------------------+
    | Top Clients                           |
    +---------------------------------------+

## Challenge

Créer un dashboard permettant à un administrateur de comprendre rapidement l'état du trafic.


---

# Lab 18 — ELK Monitoring et Troubleshooting

## Objectif

Diagnostiquer les problèmes de la stack ELK.

## Vérifier les containers

    docker ps -a

## Logs Elasticsearch

    docker logs elasticsearch

## Logs Logstash

    docker logs logstash

## Logs Kibana

    docker logs kibana

## Elasticsearch Health

    curl http://localhost:9200/_cluster/health?pretty

## Nodes

    curl http://localhost:9200/_cat/nodes?v

## Indices

    curl http://localhost:9200/_cat/indices?v

## Shards

    curl http://localhost:9200/_cat/shards?v

## Network

    docker network inspect elk

## Volumes

    docker volume ls

## Incident 1

Elasticsearch ne démarre pas.

Analyser :

    docker logs elasticsearch

## Incident 2

Kibana ne se connecte pas à Elasticsearch.

Vérifier :

    ELASTICSEARCH_HOSTS

## Incident 3

Logstash ne produit aucun document.

Vérifier :

    input
    filter
    output

## Incident 4

Les logs sont mal parsés.

Analyser :

    grok

## Incident 5

Les timestamps sont incorrects.

Analyser :

    date filter

## Rapport d'incident

    Symptom:
    Root Cause:
    Diagnostic:
    Fix:
    Verification:
    Preventive Action:

## Challenge

Créer volontairement cinq incidents différents et demander aux stagiaires de les résoudre.


---

# Lab 19 — ELK avec sécurité et persistance

## Objectif

Comprendre les éléments nécessaires pour une architecture plus proche de la production.

## Persistance

Elasticsearch doit utiliser un volume :

    elasticsearch-data

Objectif :

    Container deleted
          |
          v
    Container recreated
          |
          v
    Data still available

## Sécurité

En production, Elasticsearch doit être sécurisé.

Concepts :

    Authentication
    Authorization
    Users
    Roles
    TLS
    Certificates
    API Keys

Ne pas désactiver la sécurité en production.

## Architecture

                       Client
                         |
                       HTTPS
                         |
                      Kibana
                         |
                     Elasticsearch
                         |
                       TLS
                         |
                     Logstash

## Challenge

Identifier tous les éléments nécessaires pour sécuriser une stack ELK.


---

# Lab 20 — Final ELK DevOps Challenge

## Objectif

Construire une plateforme complète de centralisation et d'analyse des logs.

Architecture :

                           Applications
                                |
                                v
                              Logs
                                |
                     +----------+----------+
                     |                     |
                     v                     v
                  Nginx                Backend
                     |                     |
                     +----------+----------+
                                |
                                v
                            Logstash
                                |
                     +----------+----------+
                     |                     |
                     v                     v
                   Grok                  Date
                     |                     |
                     +----------+----------+
                                |
                                v
                         Elasticsearch
                                |
                                v
                             Kibana
                                |
                                v
                            Dashboard

## Contraintes

La plateforme doit :

1. Utiliser Docker.
2. Utiliser Docker Compose.
3. Utiliser Elasticsearch.
4. Utiliser Logstash.
5. Utiliser Kibana.
6. Utiliser des volumes persistants.
7. Utiliser un réseau Docker dédié.
8. Collecter des logs applicatifs.
9. Parser les logs avec Grok.
10. Normaliser les timestamps.
11. Stocker les logs dans Elasticsearch.
12. Créer un Data View Kibana.
13. Créer plusieurs visualisations.
14. Créer un dashboard.
15. Permettre la recherche des erreurs.
16. Permettre l'analyse temporelle.
17. Identifier les services générant le plus d'erreurs.
18. Identifier les URLs les plus utilisées.
19. Identifier les codes HTTP.
20. Prévoir une stratégie de troubleshooting.

## Structure attendue

    elk-project/
    ├── docker-compose.yml
    │
    ├── elasticsearch/
    │   └── config/
    │
    ├── logstash/
    │   ├── config/
    │   │   └── logstash.yml
    │   │
    │   └── pipeline/
    │       └── logstash.conf
    │
    ├── kibana/
    │   └── config/
    │
    ├── nginx/
    │   └── logs/
    │
    └── README.md

## Validation

Vérifier :

    docker ps

Vérifier Elasticsearch :

    curl http://localhost:9200

Vérifier le cluster :

    curl http://localhost:9200/_cluster/health?pretty

Vérifier les indices :

    curl http://localhost:9200/_cat/indices?v

Vérifier les documents :

    curl http://localhost:9200/nginx-logs/_search?pretty

Vérifier Logstash :

    docker logs logstash

Vérifier Kibana :

    http://localhost:5601

---

# Projet Final — Centralisation des Logs d'une Application

## Mission

Vous êtes responsable de la mise en place d'une plateforme de centralisation des logs.

L'application possède plusieurs composants :

    frontend
    backend
    nginx
    database

Chaque composant produit des logs.

Vous devez mettre en place une plateforme permettant :

- de centraliser les logs
- de parser les logs
- de rechercher les erreurs
- d'analyser les performances
- de créer des dashboards
- d'identifier les incidents

## Architecture cible

                         +-------------+
                         |  Frontend   |
                         +------+------+
                                |
                                v
                         +-------------+
                         |    Nginx    |
                         +------+------+
                                |
                                v
                         +-------------+
                         |   Backend   |
                         +------+------+
                                |
                                v
                         +-------------+
                         |  Database   |
                         +------+------+

                                |
                              Logs
                                |
                                v
                         +-------------+
                         |  Logstash   |
                         +------+------+
                                |
                       +--------+--------+
                       |                 |
                       v                 v
                     Grok              Date
                       |                 |
                       +--------+--------+
                                |
                                v
                       +------------------+
                       | Elasticsearch    |
                       +--------+---------+
                                |
                                v
                       +------------------+
                       | Kibana           |
                       +--------+---------+
                                |
                                v
                            Dashboard

---

# Dashboard Final

Le dashboard doit contenir au minimum :

## 1. Total Requests

Nombre total de requêtes.

## 2. Errors

Nombre d'erreurs :

    4xx
    5xx

## 3. Requests Over Time

Evolution du trafic dans le temps.

## 4. Errors Over Time

Evolution des erreurs.

## 5. HTTP Status Codes

Répartition :

    200
    201
    301
    400
    401
    403
    404
    500
    502
    503

## 6. Top URLs

URLs les plus demandées.

## 7. Top Clients

Clients générant le plus de trafic.

## 8. Top Services

Services générant le plus de logs.

## 9. Response Time

Temps de réponse moyen.

## 10. Error Messages

Liste des erreurs les plus fréquentes.

---

# Challenge Avancé — ELK Production-like

## Objectif

Faire évoluer l'architecture précédente vers une architecture plus proche de la production.

Architecture :

                              Applications
                                   |
                                   v
                              Log Collectors
                                   |
                                   v
                              Logstash
                                   |
                     +-------------+-------------+
                     |                           |
                     v                           v
              Elasticsearch                 Elasticsearch
                  Node 1                        Node 2
                     |                           |
                     +-------------+-------------+
                                   |
                                   v
                                Kibana

## Ajouter

- plusieurs nodes Elasticsearch
- volumes persistants
- healthchecks
- resource limits
- logs rotation
- sécurité
- TLS
- authentication
- monitoring
- backup
- index lifecycle management
- index templates
- aliases
- alerting

---

# Cheat Sheet Elasticsearch

## Health

    curl http://localhost:9200/_cluster/health?pretty

## Nodes

    curl http://localhost:9200/_cat/nodes?v

## Indices

    curl http://localhost:9200/_cat/indices?v

## Shards

    curl http://localhost:9200/_cat/shards?v

## Create Index

    curl -X PUT http://localhost:9200/my-index

## Delete Index

    curl -X DELETE http://localhost:9200/my-index

## Create Document

    curl -X POST \
      http://localhost:9200/my-index/_doc \
      -H "Content-Type: application/json" \
      -d '{
        "message": "Hello"
      }'

## Search

    curl http://localhost:9200/my-index/_search?pretty

## Count

    curl http://localhost:9200/my-index/_count?pretty

## Mapping

    curl http://localhost:9200/my-index/_mapping?pretty

---

# Cheat Sheet Logstash

## Structure

    input {
    }

    filter {
    }

    output {
    }

## STDIN

    input {
      stdin {}
    }

## HTTP

    input {
      http {
        port => 8080
      }
    }

## TCP

    input {
      tcp {
        port => 5000
      }
    }

## File

    input {
      file {
        path => "/var/log/app.log"
        start_position => "beginning"
      }
    }

## Grok

    filter {
      grok {
        match => {
          "message" => "%{IP:client_ip}"
        }
      }
    }

## Date

    filter {
      date {
        match => [
          "timestamp",
          "ISO8601"
        ]
        target => "@timestamp"
      }
    }

## Mutate

    filter {
      mutate {
        add_field => {
          "environment" => "dev"
        }
      }
    }

## Elasticsearch Output

    output {
      elasticsearch {
        hosts => [
          "http://elasticsearch:9200"
        ]
        index => "application-logs"
      }
    }

## Debug

    output {
      stdout {
        codec => rubydebug
      }
    }

---

# Cheat Sheet Docker ELK

## Start

    docker compose up -d

## Stop

    docker compose down

## Stop + Delete Volumes

    docker compose down -v

## Restart

    docker compose restart

## Status

    docker compose ps

## Logs Elasticsearch

    docker compose logs elasticsearch

## Logs Logstash

    docker compose logs logstash

## Logs Kibana

    docker compose logs kibana

## Follow Logs

    docker compose logs -f

## Network

    docker network ls

## Volumes

    docker volume ls

---

# ELK Troubleshooting Checklist

## Elasticsearch

Vérifier :

    docker ps

    docker logs elasticsearch

    curl http://localhost:9200

    curl http://localhost:9200/_cluster/health?pretty

## Logstash

Vérifier :

    docker logs logstash

Vérifier :

    input
    filter
    output

Tester avec :

    stdout {
      codec => rubydebug
    }

## Kibana

Vérifier :

    docker logs kibana

Vérifier :

    ELASTICSEARCH_HOSTS

## Data

Vérifier :

    curl http://localhost:9200/_cat/indices?v

Puis :

    curl http://localhost:9200/<index>/_search?pretty

## Docker

Vérifier :

    docker compose ps

    docker network inspect elk

    docker volume ls

---

# Bonnes pratiques ELK

## Elasticsearch

- utiliser des mappings adaptés
- éviter les mappings inutiles
- surveiller le nombre de shards
- utiliser des index adaptés au volume de données
- utiliser des volumes persistants
- surveiller l'espace disque
- surveiller la JVM
- prévoir les sauvegardes

## Logstash

- séparer les pipelines
- utiliser des filtres ciblés
- utiliser Grok pour parser les logs
- tester les patterns
- éviter les pipelines inutilement complexes
- utiliser des Dead Letter Queues si nécessaire
- monitorer les pipelines

## Kibana

- créer des Data Views cohérents
- standardiser les dashboards
- utiliser des filtres
- utiliser des time ranges adaptés
- créer des dashboards orientés exploitation

## Docker

- utiliser des volumes
- utiliser des healthchecks
- limiter les ressources
- utiliser des réseaux dédiés
- éviter de stocker les données uniquement dans les containers
- gérer correctement les logs Docker

---

# Compétences acquises

À la fin du parcours, le stagiaire doit être capable de :

- expliquer l'architecture ELK
- déployer Elasticsearch
- déployer Logstash
- déployer Kibana
- utiliser Docker Compose
- utiliser l'API REST Elasticsearch
- créer des index
- créer des documents
- rechercher des documents
- comprendre les mappings
- comprendre les shards
- comprendre les replicas
- créer des Data Views Kibana
- créer des visualisations
- créer des dashboards
- configurer Logstash
- utiliser les inputs Logstash
- utiliser les filters Logstash
- utiliser les outputs Logstash
- utiliser Grok
- utiliser le Date filter
- utiliser Mutate
- utiliser GeoIP
- centraliser des logs Nginx
- centraliser des logs applicatifs
- analyser les erreurs
- analyser les performances
- diagnostiquer ELK
- gérer la persistance
- comprendre la sécurité ELK
- préparer une architecture production-like

---

# Architecture finale

                              Users
                                |
                                v
                              Kibana
                                |
                                v
                         Elasticsearch
                                ^
                                |
                            Logstash
                                ^
                                |
                    +-----------+-----------+
                    |           |           |
                    v           v           v
                  Nginx      Backend     Database
                    |           |           |
                    +-----------+-----------+
                                |
                               Logs

---

# Final Validation

Le projet final est réussi si :

    docker compose up -d

démarre correctement :

    Elasticsearch
    Logstash
    Kibana

Elasticsearch répond :

    curl http://localhost:9200

Le cluster est opérationnel :

    curl http://localhost:9200/_cluster/health?pretty

Les logs arrivent dans Elasticsearch :

    curl http://localhost:9200/_cat/indices?v

Les documents peuvent être recherchés :

    curl http://localhost:9200/<index>/_search?pretty

Kibana est accessible :

    http://localhost:5601

Un Data View est configuré.

Les logs sont parsés avec Grok.

Les timestamps sont correctement interprétés.

Les erreurs 4xx et 5xx sont identifiables.

Un dashboard complet est disponible.

Les données Elasticsearch persistent après redémarrage des containers.

Les problèmes de la stack peuvent être diagnostiqués avec les logs Docker et les APIs Elasticsearch.

---

# Fin du TP ELK

ELK permet de construire une plateforme complète de :

    Collecte
        |
        v
    Transformation
        |
        v
    Stockage
        |
        v
    Recherche
        |
        v
    Analyse
        |
        v
    Visualisation
        |
        v
    Monitoring

avec :

    Logstash
        +
    Elasticsearch
        +
    Kibana
        +
    Docker
        +
    Docker Compose