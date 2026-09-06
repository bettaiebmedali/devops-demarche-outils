# TP — Construire une chaîne CI/CD complète avec GitLab CI

## 🎯 Objectif du TP

Dans ce TP, vous allez construire progressivement une chaîne **CI/CD complète avec GitLab CI**.

L'objectif est de partir d'un pipeline très simple et d'ajouter progressivement :

- Build
- Tests
- Artifacts
- Cache
- Variables GitLab
- Rules
- Environments
- Docker
- GitLab Container Registry
- Security scanning
- Déploiement DEV
- Déploiement PROD avec validation manuelle

À la fin du TP, vous disposerez d'un pipeline similaire à celui utilisé dans un projet DevOps réel.

---

# 1. Architecture du TP

L'architecture cible est la suivante :

```text
                         Developer
                             │
                             │ git push
                             ▼
                    ┌─────────────────┐
                    │     GitLab      │
                    │   Repository    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   GitLab CI/CD  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
          ┌───────┐      ┌───────┐      ┌────────┐
          │ Build │ ───► │ Tests │ ───► │ Quality│
          └───────┘      └───────┘      └────┬───┘
                                             │
                                             ▼
                                      ┌─────────────┐
                                      │Docker Build │
                                      └──────┬──────┘
                                             │
                                             ▼
                                      ┌─────────────┐
                                      │Security Scan│
                                      └──────┬──────┘
                                             │
                                             ▼
                                      ┌─────────────┐
                                      │Docker Registry│
                                      └──────┬──────┘
                                             │
                              ┌──────────────┴─────────────┐
                              │                            │
                              ▼                            ▼
                       ┌────────────┐               ┌────────────┐
                       │    DEV     │               │    PROD    │
                       │ Automatic  │               │   Manual   │
                       └────────────┘               └────────────┘
```

---

# 2. Prérequis

Pour réaliser ce TP, vous devez disposer de :

- Un compte GitLab
- Un projet GitLab
- Git
- Un GitLab Runner
- Docker
- Une connaissance basique de Linux
- Une connaissance basique de Git

Vérifier les installations :

    git --version

    docker --version

    docker compose version

---

# 3. Création du projet GitLab

Créer un nouveau projet GitLab :

```text
Nom du projet :
gitlab-ci-demo
```

Cloner le projet :

    git clone https://gitlab.com/<USERNAME>/gitlab-ci-demo.git

    cd gitlab-ci-demo

Créer la structure suivante :

    gitlab-ci-demo/
    │
    ├── src/
    │   └── app.py
    │
    ├── tests/
    │   └── test_app.py
    │
    ├── Dockerfile
    │
    ├── requirements.txt
    │
    └── .gitlab-ci.yml

---

# 4. Création de l'application

Créer le fichier :

    src/app.py

Contenu :

    from flask import Flask

    app = Flask(__name__)

    @app.route("/")
    def hello():
        return "Hello GitLab CI!"

    @app.route("/health")
    def health():
        return "OK"

    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=8080)

---

# 5. Dépendances Python

Créer :

    requirements.txt

Contenu :

    flask
    pytest

Installer les dépendances localement :

    pip install -r requirements.txt

---

# 6. Premier test

Créer :

    tests/test_app.py

Contenu :

    from src.app import app

    def test_home():
        client = app.test_client()

        response = client.get("/")

        assert response.status_code == 200
        assert response.data == b"Hello GitLab CI!"

    def test_health():
        client = app.test_client()

        response = client.get("/health")

        assert response.status_code == 200
        assert response.data == b"OK"

Tester localement :

    pytest

Le résultat attendu est similaire à :

    2 passed

---

# 7. Premier pipeline GitLab CI

Créer :

    .gitlab-ci.yml

Version minimale :

    stages:
      - test

    test:
      stage: test
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - pytest

Committer :

    git add .

    git commit -m "Add first GitLab CI pipeline"

    git push

Aller dans :

    GitLab
      → Build
      → Pipelines

Vérifier que le pipeline s'exécute correctement.

---

# 8. Comprendre un pipeline GitLab CI

Un pipeline est composé de :

```text
Pipeline
   │
   ├── Stage
   │     ├── Job
   │     └── Job
   │
   ├── Stage
   │     └── Job
   │
   └── Stage
         └── Job
```

Exemple :

    stages:
      - build
      - test
      - deploy

Les jobs appartenant à un même stage peuvent être exécutés en parallèle.

Les stages sont exécutés séquentiellement.

---

# 9. Ajouter un stage Build

Modifier :

    .gitlab-ci.yml

    stages:
      - build
      - test

    build:
      stage: build
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - echo "Build terminé"

    test:
      stage: test
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - pytest

Commit :

    git add .gitlab-ci.yml

    git commit -m "Add build stage"

    git push

Pipeline attendu :

```text
build
  │
  ▼
test
```

---

# 10. Utiliser les artifacts

L'objectif est maintenant de générer un résultat lors du Build et de le transmettre au stage suivant.

Modifier le job `build` :

    build:
      stage: build
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - mkdir build
        - cp -r src build/
        - cp requirements.txt build/

      artifacts:
        paths:
          - build/

Les artifacts permettent de conserver des fichiers produits par un job.

---

# 11. Utiliser les artifacts dans les tests

Modifier le job `test` :

    test:
      stage: test
      image: python:3.12

      dependencies:
        - build

      script:
        - pip install -r requirements.txt
        - pytest

Observer le pipeline.

Le job `test` récupère maintenant les artifacts du job `build`.

---

# 12. Générer un rapport de test

Modifier le job de test :

    test:
      stage: test
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - pytest --junitxml=report.xml

      artifacts:
        when: always
        reports:
          junit: report.xml

Le rapport de tests peut maintenant être exploité par GitLab.

---

# 13. Ajouter un cache

L'installation des dépendances peut prendre du temps.

Nous allons utiliser le cache.

    test:
      stage: test
      image: python:3.12

      cache:
        paths:
          - .cache/pip

      variables:
        PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"

      script:
        - pip install -r requirements.txt
        - pytest

Le cache permet d'accélérer les pipelines suivants.

---

# 14. Découvrir les variables GitLab

GitLab fournit automatiquement de nombreuses variables.

Exemples :

    $CI_PROJECT_NAME

    $CI_COMMIT_SHA

    $CI_COMMIT_SHORT_SHA

    $CI_COMMIT_BRANCH

    $CI_COMMIT_MESSAGE

    $CI_PIPELINE_ID

Ajouter un job :

    information:
      stage: build
      image: alpine:latest

      script:
        - echo "Projet : $CI_PROJECT_NAME"
        - echo "Commit : $CI_COMMIT_SHORT_SHA"
        - echo "Pipeline : $CI_PIPELINE_ID"
        - echo "Branche : $CI_COMMIT_BRANCH"

---

# 15. Variables personnalisées

Dans GitLab :

    Settings
      → CI/CD
      → Variables

Créer :

    APP_ENV = development

Puis :

    information:
      stage: build
      image: alpine:latest

      script:
        - echo "Environment : $APP_ENV"

Ne jamais mettre directement les mots de passe ou secrets dans `.gitlab-ci.yml`.

---

# 16. Variables protégées

Créer par exemple :

    PROD_API_URL

Configurer la variable comme :

    Protected

Elle ne sera disponible que dans les contextes autorisés.

Utilisation :

    deploy_prod:
      script:
        - echo "Deploy vers $PROD_API_URL"

---

# 17. Rules

Nous voulons maintenant différencier les pipelines selon le contexte.

Exemple :

    test:
      stage: test
      image: python:3.12

      script:
        - pip install -r requirements.txt
        - pytest

      rules:
        - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
        - if: '$CI_COMMIT_BRANCH == "main"'

Le job sera exécuté pour :

- Merge Request
- branche `main`

---

# 18. Pipeline pour les Merge Requests

Ajouter :

    quality:
      stage: test
      image: python:3.12

      script:
        - echo "Quality check"
        - python -m compileall src

      rules:
        - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

Tester en créant une branche :

    git checkout -b feature/test-ci

Modifier l'application.

Committer :

    git add .

    git commit -m "Test CI"

    git push -u origin feature/test-ci

Créer une Merge Request.

Observer le pipeline.

---

# 19. Créer le Dockerfile

Créer :

    Dockerfile

Contenu :

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY src ./src

    EXPOSE 8080

    CMD ["python", "src/app.py"]

Construire localement :

    docker build -t gitlab-ci-demo .

Lancer :

    docker run -d \
      --name gitlab-ci-demo \
      -p 8080:8080 \
      gitlab-ci-demo

Tester :

    curl http://localhost:8080

Résultat :

    Hello GitLab CI!

---

# 20. Ajouter le Docker Build au pipeline

Ajouter un stage :

    stages:
      - build
      - test
      - docker

Ajouter :

    docker_build:
      stage: docker

      image: docker:27

      services:
        - docker:27-dind

      variables:
        DOCKER_TLS_CERTDIR: "/certs"

      script:
        - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA .
        - echo "Docker image construite"

Cette étape construit une image Docker.

---

# 21. GitLab Container Registry

GitLab fournit un Container Registry associé au projet.

Les variables suivantes sont disponibles :

    $CI_REGISTRY

    $CI_REGISTRY_IMAGE

    $CI_REGISTRY_USER

    $CI_REGISTRY_PASSWORD

Modifier le job :

    docker_build:
      stage: docker

      image: docker:27

      services:
        - docker:27-dind

      variables:
        DOCKER_TLS_CERTDIR: "/certs"

      script:
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
        - docker build -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" .
        - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

Après le pipeline :

    Deploy
      → Container Registry

Vérifier que l'image est disponible.

---

# 22. Tagger l'image avec plusieurs tags

Nous voulons avoir :

    <commit-sha>

et :

    latest

Exemple :

    docker_build:
      stage: docker

      image: docker:27

      services:
        - docker:27-dind

      variables:
        DOCKER_TLS_CERTDIR: "/certs"

      script:
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

        - docker build \
            -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" \
            -t "$CI_REGISTRY_IMAGE:latest" .

        - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
        - docker push "$CI_REGISTRY_IMAGE:latest"

---

# 23. Security Scan avec Trivy

Nous allons scanner l'image Docker.

Ajouter un job :

    security_scan:
      stage: docker

      image:
        name: aquasec/trivy:latest
        entrypoint: [""]

      script:
        - trivy image --severity HIGH,CRITICAL "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

Selon la configuration du Runner et du Registry, l'authentification au Registry peut être nécessaire.

Objectif :

```text
Docker Build
      │
      ▼
Trivy Scan
      │
      ├── OK
      │
      └── Vulnerability
             │
             ▼
          Pipeline FAILED
```

---

# 24. Ajouter un Environment DEV

Créer :

    deploy_dev:
      stage: deploy

      script:
        - echo "Déploiement en DEV"
        - echo "Image : $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

      environment:
        name: development

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Ajouter le stage :

    stages:
      - build
      - test
      - docker
      - deploy

Dans GitLab :

    Operate
      → Environments

Vous devriez voir :

    development

---

# 25. Déploiement automatique DEV

Le pipeline devient :

```text
Build
  │
  ▼
Test
  │
  ▼
Docker Build
  │
  ▼
Security Scan
  │
  ▼
Deploy DEV
```

Le déploiement DEV est automatique.

---

# 26. Ajouter le déploiement PROD

Créer :

    deploy_prod:
      stage: deploy

      script:
        - echo "Déploiement PRODUCTION"
        - echo "Image : $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

      environment:
        name: production

      when: manual

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Le job apparaît maintenant comme une action manuelle dans GitLab.

---

# 27. Pipeline complet

Le pipeline final doit ressembler à :

```text
                         Git Push
                            │
                            ▼
                       ┌─────────┐
                       │  Build  │
                       └────┬────┘
                            │
                            ▼
                       ┌─────────┐
                       │  Test   │
                       └────┬────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   Quality   │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │Docker Build │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │Trivy Scan   │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │Registry     │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ Deploy DEV  │
                     │ Automatic   │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ Deploy PROD │
                     │   Manual    │
                     └─────────────┘
```

---

# 28. Pipeline final

Le fichier `.gitlab-ci.yml` doit maintenant être proche de :

    stages:
      - build
      - test
      - docker
      - deploy

    variables:
      PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"
      DOCKER_TLS_CERTDIR: "/certs"

    cache:
      paths:
        - .cache/pip

    build:
      stage: build

      image: python:3.12

      script:
        - pip install -r requirements.txt
        - mkdir -p build
        - cp -r src build/
        - cp requirements.txt build/

      artifacts:
        paths:
          - build/

    test:
      stage: test

      image: python:3.12

      script:
        - pip install -r requirements.txt
        - pytest --junitxml=report.xml

      artifacts:
        when: always

        reports:
          junit: report.xml

    quality:
      stage: test

      image: python:3.12

      script:
        - python -m compileall src

    docker_build:
      stage: docker

      image: docker:27

      services:
        - docker:27-dind

      script:
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

        - docker build \
            -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" \
            -t "$CI_REGISTRY_IMAGE:latest" .

        - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

        - docker push "$CI_REGISTRY_IMAGE:latest"

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

    security_scan:
      stage: docker

      image:
        name: aquasec/trivy:latest
        entrypoint: [""]

      script:
        - trivy image --severity HIGH,CRITICAL "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

    deploy_dev:
      stage: deploy

      script:
        - echo "Deploy DEV"
        - echo "Image = $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

      environment:
        name: development

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

    deploy_prod:
      stage: deploy

      script:
        - echo "Deploy PROD"
        - echo "Image = $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

      environment:
        name: production

      when: manual

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

---

# 29. Challenge 1 — Pipeline Merge Request

Modifier le pipeline afin que :

- les tests soient exécutés sur chaque Merge Request
- le Docker Build ne soit pas exécuté sur les branches feature
- le Docker Build soit exécuté uniquement sur `main`

Objectif :

```text
Feature branch
      │
      ▼
   Build
      │
      ▼
   Tests
      │
      ▼
 Quality

        Merge Request
              │
              ▼
             main
              │
              ▼
        Docker Build
              │
              ▼
        Security Scan
              │
              ▼
          Deploy DEV
```

---

# 30. Challenge 2 — Version de l'image

Modifier le pipeline pour utiliser :

    $CI_COMMIT_SHORT_SHA

comme version Docker.

Exemple :

    gitlab-ci-demo:a83f91c2

Ne jamais utiliser uniquement `latest` pour identifier une version de production.

---

# 31. Challenge 3 — Rollback

Supposons que la version actuelle soit :

    gitlab-ci-demo:a83f91c2

Une nouvelle version est déployée :

    gitlab-ci-demo:bc72e912

Mais la nouvelle version contient un bug.

Créer un job :

    rollback_prod

qui permet de revenir manuellement à une version précédente.

Le job doit utiliser une variable :

    ROLLBACK_VERSION

Exemple :

    rollback_prod:
      stage: deploy

      script:
        - echo "Rollback vers $ROLLBACK_VERSION"

      environment:
        name: production

      when: manual

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

---

# 32. Challenge 4 — Validation manuelle

Modifier le pipeline afin que :

- DEV soit automatique
- PROD soit manuel
- rollback soit manuel

Résultat :

```text
                 main
                  │
                  ▼
                Build
                  │
                  ▼
                Test
                  │
                  ▼
             Docker Build
                  │
                  ▼
             Security Scan
                  │
                  ▼
              Deploy DEV
               AUTOMATIC
                  │
                  ▼
              Deploy PROD
                MANUAL
                  │
             ┌────┴────┐
             │         │
             ▼         ▼
         Success     Rollback
                      MANUAL
```

---

# 33. Challenge 5 — Environments

Créer trois environnements :

    development
    staging
    production

Règles :

    feature/*
        ↓
    development

    develop
        ↓
    staging

    main
        ↓
    production

Mettre en place les `rules:` correspondantes.

---

# 34. Challenge 6 — Docker Compose

Créer :

    docker-compose.yml

Avec :

    services:

      app:
        image: ${APP_IMAGE}
        ports:
          - "8080:8080"

Tester :

    APP_IMAGE=gitlab-ci-demo:latest docker compose up

---

# 35. Challenge 7 — Déploiement réel local

Mettre en place une machine de déploiement.

Architecture :

```text
GitLab
   │
   │ CI/CD
   ▼
GitLab Runner
   │
   │ docker pull
   ▼
Docker Host
   │
   ▼
┌──────────────────┐
│   Application    │
│                  │
│   :8080          │
└──────────────────┘
```

Le job DEV doit :

1. récupérer l'image Docker
2. arrêter l'ancienne version
3. supprimer l'ancien container
4. démarrer la nouvelle version
5. vérifier que l'application répond

Exemple :

    docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

    docker stop app || true

    docker rm app || true

    docker run -d \
      --name app \
      -p 8080:8080 \
      $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

Tester :

    curl http://localhost:8080

---

# 36. Challenge 8 — Health Check

Ajouter un health check dans le Dockerfile :

    HEALTHCHECK \
      --interval=30s \
      --timeout=5s \
      --retries=3 \
      CMD wget -qO- http://localhost:8080/health || exit 1

Reconstruire l'image.

Vérifier :

    docker ps

Puis :

    docker inspect <container>

---

# 37. Challenge 9 — Sécurité des secrets

Identifier les mauvaises pratiques suivantes :

    password: MyPassword123

    api_key: abcdef123456

    docker login -u admin -p password

Modifier le pipeline afin d'utiliser :

    $CI_REGISTRY_USER

    $CI_REGISTRY_PASSWORD

et les variables GitLab CI/CD pour les secrets applicatifs.

---

# 38. Challenge 10 — Optimisation

Analyser le pipeline et identifier :

- les étapes pouvant être parallélisées
- les étapes pouvant utiliser le cache
- les artifacts inutiles
- les images Docker trop lourdes
- les installations répétitives
- les jobs pouvant utiliser `rules`

Objectif :

Réduire le temps total du pipeline.

---

# 39. Challenge final

## Mission

Vous êtes l'équipe DevOps d'une entreprise.

Les développeurs travaillent sur une application Python.

Chaque développeur travaille sur une branche :

    feature/*

Le code doit passer par une Merge Request avant d'arriver sur `main`.

Vous devez construire une chaîne CI/CD complète.

---

## Contraintes

Le pipeline doit contenir les stages suivants :

    build
    test
    quality
    docker
    security
    deploy

---

## Fonctionnement attendu

### Feature branch

Lorsqu'un développeur pousse une branche :

    feature/login

Le pipeline doit exécuter :

```text
Build
  │
  ▼
Tests
  │
  ▼
Quality
```

---

### Merge Request

Lorsqu'une Merge Request est créée :

```text
Build
  │
  ▼
Tests
  │
  ▼
Quality
```

Le pipeline ne doit pas déployer.

---

### Main

Après merge dans `main` :

```text
Build
  │
  ▼
Tests
  │
  ▼
Quality
  │
  ▼
Docker Build
  │
  ▼
Security Scan
  │
  ▼
Push Registry
  │
  ▼
Deploy DEV
```

---

### Production

La production doit nécessiter une validation humaine :

```text
Deploy DEV
    │
    ▼
Deploy PROD
   MANUAL
```

---

# 40. Critères de validation

Le TP est réussi si :

- [ ] Le repository GitLab fonctionne
- [ ] Le GitLab Runner fonctionne
- [ ] Le pipeline démarre automatiquement
- [ ] Le stage Build fonctionne
- [ ] Les tests sont exécutés
- [ ] Les tests apparaissent dans GitLab
- [ ] Les artifacts sont générés
- [ ] Le cache est utilisé
- [ ] Les variables GitLab sont utilisées
- [ ] Les secrets ne sont pas stockés dans Git
- [ ] Les `rules` sont correctement configurées
- [ ] L'image Docker est construite
- [ ] L'image est publiée dans le Container Registry
- [ ] L'image est taggée avec le SHA du commit
- [ ] Le scan de sécurité est exécuté
- [ ] L'environnement DEV existe
- [ ] Le déploiement DEV est automatique
- [ ] L'environnement PROD existe
- [ ] Le déploiement PROD est manuel
- [ ] Un rollback manuel est possible

---

# 41. Architecture finale

```text
                         DEVELOPER
                             │
                             │ git push
                             ▼
                    ┌─────────────────┐
                    │     GitLab      │
                    │   Repository    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   GitLab CI/CD  │
                    └────────┬────────┘
                             │
                             ▼
                       ┌───────────┐
                       │   BUILD   │
                       └─────┬─────┘
                             │
                             ▼
                       ┌───────────┐
                       │   TEST    │
                       └─────┬─────┘
                             │
                             ▼
                       ┌───────────┐
                       │  QUALITY  │
                       └─────┬─────┘
                             │
                             ▼
                       ┌───────────┐
                       │   DOCKER  │
                       └─────┬─────┘
                             │
                             ▼
                       ┌───────────┐
                       │  TRIVY    │
                       │  SECURITY │
                       └─────┬─────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ GitLab Container  │
                    │     Registry      │
                    └────────┬─────────┘
                             │
                             ▼
                       ┌───────────┐
                       │    DEV    │
                       │ AUTOMATIC │
                       └─────┬─────┘
                             │
                             ▼
                       ┌───────────┐
                       │   PROD    │
                       │   MANUAL  │
                       └─────┬─────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
                 SUCCESS           ROLLBACK
                                    MANUAL
```

---

# 42. Questions de réflexion

À la fin du TP, répondre aux questions suivantes.

### Question 1

Quelle est la différence entre :

    artifacts

et :

    cache

### Question 2

Pourquoi utiliser :

    $CI_COMMIT_SHORT_SHA

pour versionner une image Docker ?

### Question 3

Pourquoi ne faut-il pas mettre un mot de passe directement dans :

    .gitlab-ci.yml

### Question 4

Quelle est la différence entre :

    stages

et :

    jobs

### Question 5

À quoi servent les :

    rules

### Question 6

Quelle est la différence entre :

    when: manual

et :

    rules:

### Question 7

Pourquoi scanner une image Docker avant de la déployer ?

### Question 8

Pourquoi garder plusieurs versions d'une image Docker ?

### Question 9

Comment mettre en œuvre un vrai rollback ?

### Question 10

Quelle est la différence entre :

    CI

    Continuous Delivery

    Continuous Deployment

---

# 43. Extension Kubernetes

Pour aller plus loin, remplacer le déploiement Docker local par Kubernetes.

Architecture :

```text
GitLab
   │
   ▼
GitLab CI
   │
   ├── Build
   ├── Test
   ├── Docker
   ├── Security
   │
   ▼
Container Registry
   │
   ▼
Kubernetes
   │
   ├── Namespace DEV
   │
   └── Namespace PROD
```

Le pipeline devra alors :

    docker build

    docker push

    kubectl apply

et éventuellement :

    kubectl rollout status

    kubectl rollout undo

---

# 44. Extension GitOps

Pour aller encore plus loin :

```text
Developer
    │
    ▼
GitLab Application Repository
    │
    ▼
GitLab CI
    │
    ▼
Container Registry
    │
    ▼
GitOps Repository
    │
    ▼
Argo CD
    │
    ▼
Kubernetes
```

Dans cette architecture :

- GitLab CI construit l'application
- GitLab CI construit l'image
- l'image est publiée dans le Registry
- le repository GitOps contient la configuration Kubernetes
- Argo CD synchronise Kubernetes
- Kubernetes déploie l'application

---

# 45. Compétences acquises

À la fin de ce TP, le participant doit être capable de :

- comprendre l'architecture GitLab CI/CD
- créer un pipeline `.gitlab-ci.yml`
- définir des stages
- définir des jobs
- utiliser des images Docker
- utiliser les variables GitLab
- utiliser les artifacts
- utiliser le cache
- configurer des règles d'exécution
- gérer les Merge Requests
- construire une image Docker
- utiliser le GitLab Container Registry
- versionner les images Docker
- intégrer un security scan
- gérer des environments
- réaliser un déploiement automatique
- réaliser un déploiement manuel
- mettre en place un rollback
- comprendre l'intégration GitLab CI + Docker
- préparer une intégration GitLab CI + Kubernetes
- comprendre le rôle de GitOps

---

# 46. Cheat Sheet GitLab CI

## Structure minimale

    stages:
      - build
      - test

    build:
      stage: build
      script:
        - echo "Build"

    test:
      stage: test
      script:
        - echo "Test"

---

## Variables

    echo "$CI_COMMIT_SHA"

    echo "$CI_COMMIT_SHORT_SHA"

    echo "$CI_PROJECT_NAME"

    echo "$CI_PIPELINE_ID"

---

## Artifacts

    artifacts:
      paths:
        - build/

---

## Cache

    cache:
      paths:
        - .cache/

---

## Rules

    rules:
      - if: '$CI_COMMIT_BRANCH == "main"'

---

## Manual job

    when: manual

---

## Environment

    environment:
      name: production

---

## Docker Registry

    docker login \
      -u "$CI_REGISTRY_USER" \
      -p "$CI_REGISTRY_PASSWORD" \
      "$CI_REGISTRY"

---

## Docker Build

    docker build \
      -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" .

---

## Docker Push

    docker push \
      "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

---

# 47. Résultat attendu

À la fin du TP, le participant doit être capable de regarder un pipeline GitLab et de comprendre immédiatement :

```text
             CODE
               │
               ▼
             BUILD
               │
               ▼
             TEST
               │
               ▼
            QUALITY
               │
               ▼
        DOCKER IMAGE
               │
               ▼
          SECURITY
               │
               ▼
           REGISTRY
               │
               ▼
             DEV
               │
               ▼
             PROD
             MANUAL
```

Le participant aura ainsi construit une première chaîne **CI/CD DevSecOps complète avec GitLab CI**, en partant d'un simple `git push` jusqu'au déploiement contrôlé en production.