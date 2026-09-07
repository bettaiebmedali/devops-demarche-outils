# 🚀 Démo complète GitLab CI/CD — Du simple au complet

Ce document présente une démonstration progressive de GitLab CI/CD, en partant d'un pipeline minimal et en arrivant progressivement à une chaîne CI/CD complète.

L'objectif est de couvrir :

- `.gitlab-ci.yml`
- Pipeline
- Jobs
- Stages
- GitLab Runner
- Images Docker
- Build
- Tests
- Lint
- Artifacts
- Cache
- Variables
- Secrets
- Variables prédéfinies
- Branches
- Merge Requests
- `rules`
- `needs`
- Parallélisme
- Security
- Docker
- GitLab Container Registry
- Environments
- Déploiement DEV
- Déploiement PROD
- Déploiement manuel
- CI Lint
- GitLab Pages
- Bonnes pratiques CI/CD

---

# 1. Objectif de la démonstration

Nous allons construire progressivement cette architecture :

                         Git Push
                            │
                            ▼
                    ┌──────────────┐
                    │     BUILD    │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       ┌─────────────┐           ┌─────────────┐
       │ UNIT TESTS  │           │    LINT     │
       └──────┬──────┘           └──────┬──────┘
              │                         │
              └────────────┬────────────┘
                           ▼
                    ┌──────────────┐
                    │   SECURITY   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    PACKAGE   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ DOCKER BUILD │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    REGISTRY  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  DEPLOY DEV  │
                    └──────┬───────┘
                           │
                           ▼
                       Validation
                           │
                           ▼
                       [ MANUAL ]
                           │
                           ▼
                    ┌──────────────┐
                    │ DEPLOY PROD  │
                    └──────────────┘

---

# 2. Projet de démonstration

Nous allons utiliser une petite application Python.

Structure :

    demo-gitlab-ci/
    ├── .gitlab-ci.yml
    ├── .gitignore
    ├── Dockerfile
    ├── requirements.txt
    ├── app/
    │   ├── __init__.py
    │   └── app.py
    ├── tests/
    │   ├── __init__.py
    │   └── test_app.py
    └── docs/
        └── index.html

---

# 3. Créer l'application

Fichier :

    app/app.py

Contenu :

    def add(a, b):
        return a + b


    def multiply(a, b):
        return a * b

---

# 4. Ajouter les tests

Fichier :

    tests/test_app.py

Contenu :

    from app.app import add, multiply


    def test_add():
        assert add(2, 3) == 5


    def test_multiply():
        assert multiply(2, 3) == 6

---

# 5. Dépendances Python

Fichier :

    requirements.txt

Contenu :

    pytest

---

# 6. Gitignore

Fichier :

    .gitignore

Contenu :

    __pycache__/
    .pytest_cache/
    .cache/
    .venv/
    *.pyc

---

# 7. Initialiser Git

Commandes :

    git init
    git add .
    git commit -m "Initial project"

Ajouter le repository GitLab :

    git remote add origin <URL_DU_PROJET_GITLAB>
    git branch -M main
    git push -u origin main

---

# 8. Niveau 1 — Premier pipeline

Créer le fichier :

    .gitlab-ci.yml

Commencer volontairement avec quelque chose de très simple :

    test:
      script:
        - echo "Hello GitLab CI"

Faire :

    git add .gitlab-ci.yml
    git commit -m "Add first GitLab CI pipeline"
    git push

Dans GitLab :

    Build
    └── Pipelines

Nous devons obtenir :

    test ✓

À ce stade, expliquer :

- `.gitlab-ci.yml`
- Pipeline
- Job
- Runner
- Script

---

# 9. Comprendre Pipeline, Job et Stage

Un pipeline est composé de jobs.

Exemple :

    Pipeline
    │
    ├── Job 1
    ├── Job 2
    └── Job 3

Les jobs sont organisés dans des stages.

    Pipeline
    │
    ├── Build
    │   └── build
    │
    ├── Test
    │   ├── unit_tests
    │   └── lint
    │
    └── Deploy
        └── deploy

---

# 10. Niveau 2 — Ajouter les stages

Modifier `.gitlab-ci.yml` :

    stages:
      - build
      - test
      - deploy


    build:
      stage: build
      script:
        - echo "Building application"


    test:
      stage: test
      script:
        - echo "Running tests"


    deploy:
      stage: deploy
      script:
        - echo "Deploying application"

Le pipeline devient :

    BUILD
      │
      ▼
    TEST
      │
      ▼
    DEPLOY

Les stages s'exécutent dans l'ordre.

Les jobs appartenant au même stage peuvent généralement s'exécuter en parallèle.

---

# 11. Niveau 3 — Utiliser une image Docker

Notre application est en Python.

Utiliser :

    image: python:3.12

Exemple :

    image: python:3.12

    stages:
      - test


    test:
      stage: test
      script:
        - python --version
        - pip --version
        - pip install -r requirements.txt
        - pytest

---

# 12. Comprendre l'erreur ruby:3.1

Si nous utilisons :

    image: ruby:3.1

et :

    pip install -r requirements.txt

nous obtenons :

    /usr/bin/bash: pip: command not found

Pourquoi ?

Parce que l'image :

    ruby:3.1

est destinée à Ruby et ne fournit pas l'environnement Python attendu.

Pour notre projet :

    python:3.12

fournit :

    Python
    pip

Le message pédagogique est :

    GitLab CI utilise l'image définie dans image:
    Cette image détermine l'environnement dans lequel le job est exécuté.

---

# 13. Niveau 4 — Vrais tests Python

Configuration :

    image: python:3.12

    stages:
      - test


    test:
      stage: test
      script:
        - pip install -r requirements.txt
        - pytest -v

Résultat attendu :

    tests/test_app.py::test_add PASSED
    tests/test_app.py::test_multiply PASSED

---

# 14. Démontrer un pipeline qui échoue

Modifier temporairement :

    def test_add():
        assert add(2, 3) == 10

Le pipeline doit échouer.

Résultat :

    build ✓
    test ✗

Expliquer :

    GitLab CI détecte automatiquement l'erreur.

Puis remettre :

    assert add(2, 3) == 5

Refaire un push.

Résultat :

    build ✓
    test ✓

---

# 15. Niveau 5 — Ajouter un vrai BUILD

Configuration :

    image: python:3.12

    stages:
      - build
      - test


    build:
      stage: build
      script:
        - mkdir -p build
        - cp -r app build/app
        - cp requirements.txt build/
        - echo "Build completed"


    test:
      stage: test
      script:
        - pip install -r requirements.txt
        - pytest

---

# 16. Niveau 6 — Artifacts

Les fichiers créés dans un job ne sont pas automatiquement conservés.

Pour conserver le résultat du build :

    build:
      stage: build

      script:
        - mkdir -p build
        - cp -r app build/app
        - cp requirements.txt build/
        - echo "Build completed"

      artifacts:
        paths:
          - build/

GitLab conserve alors :

    build/
    ├── app/
    └── requirements.txt

---

# 17. Comprendre les artifacts

Un artifact permet de conserver ou transmettre un résultat produit par un job.

Exemple :

    BUILD
      │
      │ artifact
      ▼
    TEST

Exemples d'artifacts :

- build/
- fichiers `.zip`
- fichiers `.tar.gz`
- rapports de tests
- fichiers générés
- packages
- binaires

---

# 18. Ajouter un fichier de version

Configuration :

    build:
      stage: build

      script:
        - mkdir -p build
        - cp -r app build/app
        - cp requirements.txt build/
        - echo "Commit: $CI_COMMIT_SHORT_SHA" > build/version.txt
        - cat build/version.txt

      artifacts:
        paths:
          - build/

Le fichier produit :

    build/version.txt

Exemple :

    Commit: 7f83a91b

---

# 19. Niveau 7 — Tests avec rapport JUnit

Configuration :

    unit_tests:
      stage: test

      script:
        - pip install -r requirements.txt
        - pytest --junitxml=test-results.xml

      artifacts:
        when: always
        reports:
          junit: test-results.xml

GitLab peut alors exploiter le rapport de tests.

---

# 20. Niveau 8 — Ajouter le Lint

Installer `flake8` :

    lint:
      stage: test

      script:
        - pip install flake8
        - flake8 app tests

Le stage devient :

    TEST
    ├── unit_tests
    └── lint

Ces jobs peuvent être exécutés en parallèle.

---

# 21. Niveau 9 — Parallélisme

Exemple :

    stages:
      - test


    unit_tests:
      stage: test
      script:
        - echo "Unit tests"


    lint:
      stage: test
      script:
        - echo "Lint"


    security:
      stage: test
      script:
        - echo "Security"

Conceptuellement :

             TEST
        ┌──────┼──────┐
        ▼      ▼      ▼
      pytest  lint  security

Cela permet de réduire le temps total du pipeline.

---

# 22. Niveau 10 — Cache

Pour Python :

    variables:
      PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"


    cache:
      paths:
        - .cache/pip/

Le cache permet de réutiliser les dépendances téléchargées.

Différence importante :

    Artifact
    └── Résultat du job

    Cache
    └── Optimisation pour les prochains jobs/pipelines

---

# 23. Niveau 11 — Variables CI/CD

Définir des variables globales :

    variables:
      APP_NAME: "demo-gitlab-ci"
      APP_VERSION: "1.0"

Utilisation :

    info:
      stage: test

      script:
        - echo "Application = $APP_NAME"
        - echo "Version = $APP_VERSION"

---

# 24. Niveau 12 — Variables GitLab

Dans GitLab :

    Settings
    └── CI/CD
        └── Variables

Créer par exemple :

    ENVIRONMENT=development

Puis :

    deploy:
      script:
        - echo "Deploy to $ENVIRONMENT"

Cela permet de stocker des valeurs hors du repository.

---

# 25. Niveau 13 — Secrets

Ne jamais faire :

    variables:
      PASSWORD: "MyPassword123"

Ne jamais mettre directement les mots de passe dans `.gitlab-ci.yml`.

Utiliser plutôt :

    Settings
    └── CI/CD
        └── Variables

Exemple :

    DEPLOY_PASSWORD

Puis :

    deploy:
      script:
        - ./deploy.sh "$DEPLOY_PASSWORD"

Pour les secrets importants, utiliser lorsque nécessaire :

- Masked
- Protected
- Environment scope

Pour la démonstration, utiliser uniquement des valeurs fictives.

---

# 26. Niveau 14 — Variables prédéfinies GitLab

GitLab fournit automatiquement des variables.

Exemple :

    info:
      stage: test

      script:
        - echo "Project      : $CI_PROJECT_NAME"
        - echo "Branch       : $CI_COMMIT_BRANCH"
        - echo "Commit       : $CI_COMMIT_SHA"
        - echo "Short SHA    : $CI_COMMIT_SHORT_SHA"
        - echo "Pipeline ID  : $CI_PIPELINE_ID"
        - echo "Job ID       : $CI_JOB_ID"

Ces variables permettent de connaître le contexte d'exécution du job.

---

# 27. Niveau 15 — Branches

Workflow :

    main
     │
     ├── feature/login
     ├── feature/payment
     └── feature/api

Sur une branche feature, nous voulons généralement :

    Build
    Test
    Security

mais pas automatiquement :

    Production

---

# 28. Niveau 16 — Rules

Déploiement uniquement sur `main` :

    deploy:
      stage: deploy

      script:
        - echo "Deploying..."

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Résultat :

    feature/login
        │
        └── deploy ❌

    main
        │
        └── deploy ✓

---

# 29. Niveau 17 — Merge Requests

Créer une branche :

    git checkout -b feature/login

Faire une modification puis :

    git add .
    git commit -m "Add login feature"
    git push -u origin feature/login

Créer ensuite une Merge Request vers `main`.

Exemple de job :

    mr_tests:
      stage: test

      script:
        - pip install -r requirements.txt
        - pytest

      rules:
        - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

Workflow :

    Feature branch
          │
          ▼
    Merge Request
          │
          ▼
       Pipeline
          │
          ├── Build
          ├── Test
          ├── Lint
          └── Security
          │
          ▼
      Code Review
          │
          ▼
       Merge main

---

# 30. Niveau 18 — `needs`

Sans `needs` :

    BUILD
      │
      ▼
    TEST
      │
      ▼
    PACKAGE

Avec `needs` :

    package:
      stage: package

      needs:
        - build
        - unit_tests

      script:
        - echo "Creating package"

`needs` permet de définir précisément les dépendances entre jobs et d'optimiser le temps du pipeline.

---

# 31. Niveau 19 — Security

Ajouter un contrôle des dépendances Python avec `pip-audit` :

    security:
      stage: security

      script:
        - pip install pip-audit
        - pip-audit -r requirements.txt

Pipeline :

    BUILD
      │
      ▼
    TEST
      │
      ├── unit_tests
      └── lint
      │
      ▼
    SECURITY
      │
      └── pip-audit

---

# 32. `allow_failure`

Pour une démonstration :

    security:
      stage: security

      script:
        - pip install pip-audit
        - pip-audit -r requirements.txt

      allow_failure: true

Cela signifie que le job peut échouer sans faire échouer complètement le pipeline.

Attention : cela ne signifie pas que la vulnérabilité est corrigée.

En production, il faut définir une politique de sécurité adaptée.

---

# 33. Niveau 20 — Dockerfile

Créer :

    Dockerfile

Contenu :

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .

    RUN pip install --no-cache-dir -r requirements.txt

    COPY app/ app/

    CMD ["python", "-m", "app.app"]

---

# 34. Niveau 21 — Docker Build

Un job Docker peut être ajouté :

    docker_build:
      stage: package

      image: docker:27

      services:
        - docker:27-dind

      script:
        - docker build -t demo-app .

Attention :

Le runner doit être correctement configuré pour permettre l'utilisation de Docker-in-Docker.

---

# 35. Niveau 22 — GitLab Container Registry

GitLab permet de stocker les images Docker.

Architecture :

    GitLab Project
    │
    └── Container Registry
        │
        └── demo-gitlab-ci
            ├── latest
            ├── 1.0.0
            └── commit-sha

Variables utiles :

    CI_REGISTRY
    CI_REGISTRY_IMAGE
    CI_REGISTRY_USER
    CI_REGISTRY_PASSWORD

---

# 36. Niveau 23 — Push de l'image Docker

Exemple :

    docker_build:
      stage: package

      image: docker:27

      services:
        - docker:27-dind

      script:
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

        - docker build \
            -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" \
            .

        - docker push \
            "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"

Workflow :

    Application
        │
        ▼
    Docker Build
        │
        ▼
    Docker Image
        │
        ▼
    Container Registry

---

# 37. Niveau 24 — Tag `latest`

Sur `main`, nous pouvons publier `latest` :

    docker_build:
      stage: package

      image: docker:27

      services:
        - docker:27-dind

      script:
        - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"

        - docker build \
            -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" \
            -t "$CI_REGISTRY_IMAGE:latest" \
            .

        - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
        - docker push "$CI_REGISTRY_IMAGE:latest"

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

---

# 38. Niveau 25 — Environments

Créer l'environnement DEV :

    deploy_dev:
      stage: deploy

      script:
        - echo "Deploying to DEV"

      environment:
        name: development

GitLab peut alors suivre les déploiements de cet environnement.

Architecture :

    Pipeline
       │
       ▼
    development
       │
       └── Deployment

---

# 39. Niveau 26 — Déploiement DEV

Exemple :

    deploy_dev:
      stage: deploy

      script:
        - echo "Deploying $CI_COMMIT_SHORT_SHA to DEV"
        - echo "Deployment DEV OK"

      environment:
        name: development

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Workflow :

    main
      │
      ▼
    Build
      │
      ▼
    Test
      │
      ▼
    Package
      │
      ▼
    Deploy DEV

---

# 40. Niveau 27 — Production

Créer l'environnement production :

    deploy_prod:
      stage: deploy

      script:
        - echo "Deploying to PRODUCTION"

      environment:
        name: production

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

---

# 41. Niveau 28 — Déploiement manuel

Pour protéger la production :

    deploy_prod:
      stage: deploy

      script:
        - echo "Deploying to PRODUCTION"

      environment:
        name: production

      when: manual

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Dans GitLab :

    deploy_prod
        │
        └── ▶ Play

Le déploiement démarre uniquement après validation manuelle.

---

# 42. Workflow DEV → PROD

    Git Push
       │
       ▼
    Build
       │
       ▼
    Tests
       │
       ▼
    Security
       │
       ▼
    Package
       │
       ▼
    Deploy DEV
       │
       ▼
    Validation
       │
       ▼
    [ MANUAL ]
       │
       ▼
    Deploy PROD

C'est un scénario très adapté à une démonstration CI/CD.

---

# 43. Niveau 29 — CI Lint

Une erreur YAML peut empêcher le pipeline de fonctionner.

Exemple incorrect :

    test
      stage: test

Correct :

    test:
      stage: test

Utiliser le CI/CD YAML editor / CI Lint de GitLab pour valider la configuration.

Démonstration :

    Erreur YAML
        │
        ▼
    CI Lint
        │
        ▼
    ❌ Invalid configuration

Puis :

    Correction
        │
        ▼
    CI Lint
        │
        ▼
    ✅ Valid configuration

---

# 44. Niveau 30 — GitLab Pages

Créer :

    docs/index.html

Contenu :

    <!DOCTYPE html>
    <html>
    <head>
        <title>GitLab CI Demo</title>
    </head>
    <body>
        <h1>GitLab CI/CD Demo</h1>
        <p>Pipeline successfully executed.</p>
    </body>
    </html>

L'objectif est de montrer qu'un pipeline peut également publier un site statique.

Selon la version/configuration de GitLab utilisée, le job Pages peut être adapté à la configuration Pages de l'instance.

---

# 45. Pipeline final

Voici une version complète pour notre démonstration Python :

    image: python:3.12


    variables:
      APP_NAME: "demo-gitlab-ci"
      PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"


    cache:
      paths:
        - .cache/pip/


    stages:
      - build
      - test
      - security
      - package
      - deploy_dev
      - deploy_prod


    build:
      stage: build

      script:
        - echo "================================"
        - echo "BUILD"
        - echo "================================"
        - python --version
        - pip --version
        - mkdir -p build
        - cp -r app build/app
        - cp requirements.txt build/
        - echo "Commit : $CI_COMMIT_SHORT_SHA" > build/version.txt
        - echo "Project : $CI_PROJECT_NAME" >> build/version.txt
        - cat build/version.txt

      artifacts:
        name: "$CI_PROJECT_NAME-$CI_COMMIT_SHORT_SHA"
        paths:
          - build/
        expire_in: 1 week


    unit_tests:
      stage: test

      script:
        - echo "================================"
        - echo "UNIT TESTS"
        - echo "================================"
        - pip install -r requirements.txt
        - pytest -v --junitxml=test-results.xml

      artifacts:
        when: always
        reports:
          junit: test-results.xml
        paths:
          - test-results.xml
        expire_in: 1 week


    lint:
      stage: test

      script:
        - echo "================================"
        - echo "LINT"
        - echo "================================"
        - pip install flake8
        - flake8 app tests


    security:
      stage: security

      script:
        - echo "================================"
        - echo "SECURITY"
        - echo "================================"
        - pip install pip-audit
        - pip-audit -r requirements.txt

      allow_failure: true


    package:
      stage: package

      needs:
        - build
        - unit_tests

      script:
        - echo "================================"
        - echo "PACKAGE"
        - echo "================================"
        - mkdir -p package
        - cp -r build/app package/
        - cp build/version.txt package/
        - tar -czf "$APP_NAME-$CI_COMMIT_SHORT_SHA.tar.gz" package/

      artifacts:
        name: "$APP_NAME-$CI_COMMIT_SHORT_SHA"
        paths:
          - "*.tar.gz"
        expire_in: 1 week


    deploy_dev:
      stage: deploy_dev

      needs:
        - package

      script:
        - echo "================================"
        - echo "DEPLOY DEVELOPMENT"
        - echo "================================"
        - echo "Application : $APP_NAME"
        - echo "Commit      : $CI_COMMIT_SHORT_SHA"
        - echo "Branch      : $CI_COMMIT_BRANCH"
        - echo "Deployment DEV..."
        - mkdir -p deployment
        - echo "$CI_COMMIT_SHORT_SHA" > deployment/version.txt
        - echo "DEV deployment OK"

      environment:
        name: development

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'


    deploy_prod:
      stage: deploy_prod

      needs:
        - package

      script:
        - echo "================================"
        - echo "DEPLOY PRODUCTION"
        - echo "================================"
        - echo "Application : $APP_NAME"
        - echo "Commit      : $CI_COMMIT_SHORT_SHA"
        - echo "Deployment PRODUCTION..."
        - mkdir -p deployment
        - echo "$CI_COMMIT_SHORT_SHA" > deployment/version.txt
        - echo "PRODUCTION deployment OK"

      environment:
        name: production

      when: manual

      rules:
        - if: '$CI_COMMIT_BRANCH == "main"'

Important :

Ce pipeline simule les déploiements avec des commandes `echo`.

Il ne déploie pas réellement une application sur un serveur.

Pour un vrai déploiement, les commandes `deploy_dev` et `deploy_prod` doivent être remplacées par les commandes de déploiement correspondant à l'infrastructure utilisée :

- VM
- Docker
- Kubernetes
- AWS
- Azure
- GCP
- OpenShift
- etc.

---

# 46. Architecture finale

                         Developer
                             │
                             │ git push
                             ▼
                        ┌─────────┐
                        │ GitLab  │
                        └────┬────┘
                             │
                             ▼
                        ┌─────────┐
                        │ Runner  │
                        └────┬────┘
                             │
                             ▼
                      ┌─────────────┐
                      │    BUILD    │
                      └──────┬──────┘
                             │
                             ▼
                 ┌─────────────────────┐
                 │        TEST         │
                 │                     │
                 │ pytest              │
                 │ flake8              │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      SECURITY       │
                 │                     │
                 │ pip-audit           │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │      PACKAGE        │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │   DOCKER / REGISTRY │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │     DEPLOY DEV      │
                 └──────────┬──────────┘
                            │
                            ▼
                        Validation
                            │
                            ▼
                        [ MANUAL ]
                            │
                            ▼
                 ┌─────────────────────┐
                 │    DEPLOY PROD      │
                 └─────────────────────┘

---

# 47. Scénario de démonstration LIVE

Pour une présentation, ne commencez surtout pas directement avec le pipeline final.

Construisez-le progressivement.

## Étape 1 — Hello World

Commencer par :

    test:
      script:
        - echo "Hello GitLab CI"

Présenter :

- Pipeline
- Job
- Runner
- Script

---

## Étape 2 — Ajouter les stages

Ajouter :

    build
    test
    deploy

Présenter :

- Stage
- Ordre d'exécution
- Jobs

---

## Étape 3 — Ajouter l'image Docker

Utiliser :

    image: python:3.12

Présenter :

- Image Docker
- Environnement d'exécution
- Runner

Faire éventuellement l'erreur :

    image: ruby:3.1

Puis :

    pip install ...

et montrer :

    pip: command not found

Corriger avec :

    image: python:3.12

---

## Étape 4 — Ajouter les tests

Ajouter :

    pytest

Puis casser volontairement un test.

Montrer :

    ❌ Pipeline failed

Corriger le test.

Montrer :

    ✅ Pipeline passed

---

## Étape 5 — Ajouter les artifacts

Créer :

    build/version.txt

Puis :

    artifacts:
      paths:
        - build/

Montrer le téléchargement de l'artifact dans GitLab.

---

## Étape 6 — Ajouter le cache

Ajouter :

    cache:
      paths:
        - .cache/pip/

Expliquer :

    Artifact = résultat
    Cache = optimisation

---

## Étape 7 — Ajouter le Lint

Ajouter :

    flake8

Montrer :

    TEST
    ├── pytest
    └── flake8

Expliquer le parallélisme.

---

## Étape 8 — Ajouter les variables

Montrer :

    CI_PROJECT_NAME
    CI_COMMIT_BRANCH
    CI_COMMIT_SHA
    CI_PIPELINE_ID

Puis créer une variable GitLab.

---

## Étape 9 — Ajouter les secrets

Créer une variable GitLab :

    DEPLOY_PASSWORD

Expliquer :

- Masked
- Protected
- Secret management

Ne jamais afficher une vraie valeur sensible.

---

## Étape 10 — Ajouter les Rules

Créer :

    feature/demo-ci

Puis :

    main

Montrer que le comportement peut être différent selon la branche.

---

## Étape 11 — Merge Request

Créer une Merge Request :

    feature/demo-ci → main

Montrer :

    Merge Request
          │
          ▼
       Pipeline
          │
          ├── Build
          ├── Test
          ├── Lint
          └── Security
          │
          ▼
       Review
          │
          ▼
       Merge

---

## Étape 12 — Security

Ajouter :

    pip-audit

Montrer :

    SECURITY
       │
       └── pip-audit

---

## Étape 13 — Docker

Créer le Dockerfile.

Construire l'image :

    docker build

Montrer :

    Application
        │
        ▼
    Docker Build
        │
        ▼
    Docker Image

---

## Étape 14 — Container Registry

Montrer :

    GitLab
    └── Container Registry
        └── demo-app

Puis :

    docker push

---

## Étape 15 — Environment DEV

Créer :

    development

Puis :

    deploy_dev

Montrer :

    Pipeline
       │
       ▼
    development
       │
       └── Deployment

---

## Étape 16 — Production

Créer :

    production

Ajouter :

    when: manual

Montrer dans GitLab :

    deploy_prod
        │
        └── ▶ Play

Cliquer sur Play.

---

# 48. Concepts à retenir

| Concept | Rôle |
|---|---|
| `.gitlab-ci.yml` | Configuration CI/CD |
| Pipeline | Ensemble du processus CI/CD |
| Job | Tâche exécutée |
| Stage | Groupe logique de jobs |
| Runner | Machine qui exécute les jobs |
| `image` | Environnement Docker du job |
| `script` | Commandes exécutées |
| Artifact | Résultat conservé |
| Cache | Optimisation |
| Variable | Configuration dynamique |
| Secret | Information sensible |
| `rules` | Conditions d'exécution |
| `needs` | Dépendances entre jobs |
| Merge Request | Validation avant merge |
| Environment | Cible de déploiement |
| `when: manual` | Déclenchement manuel |
| Container Registry | Stockage des images Docker |
| Security | Contrôles de sécurité |
| CI Lint | Validation du YAML |
| Pages | Publication d'un site statique |

---

# 49. CI vs CD

## Continuous Integration

La CI concerne principalement :

    Git Push
       │
       ▼
    Build
       │
       ▼
    Tests
       │
       ▼
    Lint
       │
       ▼
    Security

Objectif :

    Détecter rapidement les problèmes.

---

## Continuous Delivery

La livraison continue ajoute :

    Build
      │
      ▼
    Test
      │
      ▼
    Package
      │
      ▼
    Deploy DEV
      │
      ▼
    Validation
      │
      ▼
    Production

Objectif :

    Avoir une version prête à être déployée.

---

## Continuous Deployment

Avec le Continuous Deployment :

    Git Push
       │
       ▼
    Build
       │
       ▼
    Test
       │
       ▼
    Security
       │
       ▼
    Deploy
       │
       ▼
    Production

Le déploiement peut être entièrement automatique si les conditions et contrôles sont satisfaits.

---

# 50. Message final de la démonstration

Le message principal à transmettre est :

    Git Push
       ↓
    Build
       ↓
    Test
       ↓
    Quality
       ↓
    Security
       ↓
    Package
       ↓
    Container
       ↓
    Registry
       ↓
    DEV
       ↓
    Validation
       ↓
    Production

GitLab CI/CD permet donc d'automatiser progressivement le cycle de vie d'une application.

On commence avec :

    echo "Hello GitLab"

Puis on construit progressivement :

    Pipeline
      ↓
    Stages
      ↓
    Tests
      ↓
    Artifacts
      ↓
    Cache
      ↓
    Variables
      ↓
    Rules
      ↓
    Merge Requests
      ↓
    Security
      ↓
    Docker
      ↓
    Registry
      ↓
    Environments
      ↓
    DEV
      ↓
    PROD

La meilleure démonstration consiste à ajouter chaque fonctionnalité une par une et à expliquer le problème qu'elle résout.

Ainsi, l'audience comprend non seulement comment écrire `.gitlab-ci.yml`, mais surtout pourquoi chaque fonctionnalité existe.
