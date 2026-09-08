# GitLab CI/CD — Déployer Nginx avec un GitLab Runner Docker dans GitHub Codespaces

## Objectif

Utiliser un GitLab Runner avec l'executor Docker installé dans un GitHub Codespace pour créer automatiquement un conteneur Nginx à partir d'un pipeline GitLab CI/CD.

Architecture :

    GitLab
       |
       v
    GitLab Runner
    GitHub Codespace
    Docker Executor
       |
       v
    docker:27-cli
       |
       | /var/run/docker.sock
       v
    Docker daemon du Codespace
       |
       v
    nginx-demo


## 1. Vérifier Docker dans le Codespace

Vérifier Docker :

    docker --version

Vérifier le Docker daemon :

    docker ps

Vérifier le Docker socket :

    ls -l /var/run/docker.sock

Tester Docker :

    docker run --rm hello-world


## 2. Vérifier la configuration du GitLab Runner

Rechercher le fichier de configuration :

    sudo find / -name config.toml 2>/dev/null | grep gitlab

La configuration du Runner utilisé dans le Codespace se trouve généralement ici :

    /home/codespace/.gitlab-runner/config.toml

Afficher la configuration :

    cat /home/codespace/.gitlab-runner/config.toml


## 3. Configurer le Docker executor

Éditer la configuration :

    nano /home/codespace/.gitlab-runner/config.toml

La section Docker doit contenir :

    [runners.docker]
      tls_verify = false
      image = "docker:27-cli"
      privileged = false
      disable_entrypoint_overwrite = false
      oom_kill_disable = false
      disable_cache = false
      volumes = [
        "/cache",
        "/var/run/docker.sock:/var/run/docker.sock"
      ]
      volume_keep = false
      shm_size = 0
      network_mtu = 0

Le point important est le montage du Docker socket :

    "/var/run/docker.sock:/var/run/docker.sock"

Cela permet au conteneur du job GitLab CI d'accéder au Docker daemon du Codespace.


## 4. Redémarrer le GitLab Runner

Vérifier le processus :

    ps aux | grep '[g]itlab-runner'

Si le Runner est lancé manuellement :

    gitlab-runner run \
      --config /home/codespace/.gitlab-runner/config.toml


## 5. Créer le fichier .gitlab-ci.yml

À la racine du projet :

    touch .gitlab-ci.yml

Contenu :

    stages:
      - deploy

    deploy_nginx:
      stage: deploy

      image: docker:27-cli

      variables:
        DOCKER_HOST: "unix:///var/run/docker.sock"

      script:
        - echo "=== Docker version ==="
        - docker --version

        - echo "=== Docker info ==="
        - docker info

        - echo "=== Pull Nginx ==="
        - docker pull nginx:latest

        - echo "=== Remove old container ==="
        - docker rm -f nginx-demo 2>/dev/null || true

        - echo "=== Start Nginx ==="
        - docker run -d --name nginx-demo -p 8080:80 nginx:latest

        - echo "=== Containers ==="
        - docker ps


## 6. Ajouter et pousser le fichier

Ajouter le fichier :

    git add .gitlab-ci.yml

Créer le commit :

    git commit -m "Add GitLab CI Nginx deployment"

Envoyer vers GitLab :

    git push origin main


## 7. Vérifier le pipeline GitLab

Dans GitLab :

    Project
      -> Build
         -> Pipelines

Le job :

    deploy_nginx

doit être exécuté par le Runner du Codespace.


## 8. Vérifier le conteneur Nginx

Dans le GitHub Codespace :

    docker ps

Le conteneur doit apparaître :

    nginx-demo

avec le port :

    0.0.0.0:8080->80/tcp


## 9. Tester Nginx

Depuis le Codespace :

    curl http://localhost:8080

Afficher les logs :

    docker logs nginx-demo

Afficher les informations du conteneur :

    docker inspect nginx-demo


## 10. Commandes Docker utiles

Lister les conteneurs :

    docker ps

Lister tous les conteneurs :

    docker ps -a

Arrêter Nginx :

    docker stop nginx-demo

Démarrer Nginx :

    docker start nginx-demo

Supprimer Nginx :

    docker rm -f nginx-demo

Afficher les logs :

    docker logs nginx-demo


## 11. Pipeline avec test HTTP

Une version plus complète peut également vérifier que Nginx répond :

    stages:
      - deploy
      - test

    deploy_nginx:
      stage: deploy

      image: docker:27-cli

      variables:
        DOCKER_HOST: "unix:///var/run/docker.sock"

      script:
        - docker --version
        - docker info
        - docker pull nginx:latest
        - docker rm -f nginx-demo 2>/dev/null || true
        - docker run -d --name nginx-demo -p 8080:80 nginx:latest
        - docker ps

    test_nginx:
      stage: test

      image: curlimages/curl:latest

      script:
        - curl http://host.docker.internal:8080


## 12. Architecture finale

                         GitLab
                            |
                            | git push
                            v
                    GitLab CI/CD Pipeline
                            |
                            v
                    GitLab Runner
                  GitHub Codespace
                            |
                     Docker executor
                            |
                            v
                  +------------------+
                  | docker:27-cli    |
                  |                  |
                  | Docker CLI       |
                  +--------+---------+
                           |
                           | /var/run/docker.sock
                           v
                  +------------------+
                  | Docker daemon    |
                  | GitHub Codespace |
                  +--------+---------+
                           |
                           v
                  +------------------+
                  |   nginx-demo     |
                  |   nginx:latest   |
                  |                  |
                  |      :80         |
                  +--------+---------+
                           |
                       Port 8080


## 13. Résultat attendu

Le pipeline réalise automatiquement les opérations suivantes :

    1. Utiliser docker:27-cli
    2. Se connecter au Docker daemon du Codespace
    3. Télécharger nginx:latest
    4. Supprimer l'ancien conteneur nginx-demo
    5. Créer nginx-demo
    6. Exposer le port 8080
    7. Vérifier le conteneur

Vérification finale :

    docker ps

Résultat attendu :

    CONTAINER ID   IMAGE          STATUS          PORTS
    xxxxxxxxxxxx   nginx:latest   Up ...          0.0.0.0:8080->80/tcp

Le déploiement Nginx est alors réalisé automatiquement par GitLab CI/CD sur le Docker daemon du GitHub Codespace.
