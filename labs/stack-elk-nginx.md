# Lab - Stack ELK avec Nginx

## Prérequis
Tu as déjà cloné le projet elasticsearch-logstash-kibana de awesome-compose sur ton Ubuntu et le stack ELK est fonctionnel.

```bash
git clone https://github.com/docker/awesome-compose.git
cd awesome-compose
```

Maintenant, tu veux intégrer Nginx dans ce stack pour récupérer et visualiser les logs Nginx.

## Étapes détaillées

### 1. Démarrer Nginx avec un volume partagé pour les logs
Nous allons créer un conteneur Nginx et partager les logs avec Logstash pour qu’il puisse les ingérer.

a) Créer un volume pour les logs Nginx (sur l'hôte) :
```bash
mkdir -p /path/to/logs/nginx
```

b) Démarrer Nginx avec un volume partagé :
```bash
docker run -d --name nginx -p 8080:80 -v /path/to/logs/nginx:/var/log/nginx nginx
```

### 2. Créer un fichier de configuration Logstash
Créer `logstash.conf` localement :
```bash
nano /path/to/your/awesome-compose/elasticsearch-logstash-kibana/logstash/pipeline/logstash.conf
```

Contenu :
```conf
input {
  file {
    path => "/var/log/nginx/access.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "nginx-logs"
  }
  stdout { codec => rubydebug }
}
```

### 3. Configurer Docker Compose pour Logstash
Modifier `docker-compose.yml` en ajoutant les volumes sous le service `logstash` :

```yaml
logstash:
  image: docker.elastic.co/logstash/logstash:7.17.0
  volumes:
    - ./logstash/pipeline/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    - /path/to/logs/nginx:/var/log/nginx
  ports:
    - "5044:5044"
  networks:
    - elk:
```

### 4. Démarrer les services ELK et Nginx
```bash
docker-compose up -d
```

### 5. Accéder à Kibana et configurer l'index pattern
Accède à Kibana via http://localhost:5601.

- Créer un index pattern : `nginx-logs-*`
- Associer un champ de type date, comme `@timestamp`

### 6. Tester la collecte de logs
Génère des logs Nginx :
```bash
curl http://localhost:8080
```

### 7. Visualiser les logs dans Kibana
Dans Kibana, va dans **Discover** et choisis l'index `nginx-logs-*`.
