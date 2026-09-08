# TP — Robot Framework dans un container Docker

## 🎯 Objectif

Dans ce TP, vous allez utiliser **Robot Framework dans un container Docker** pour tester une application **Nginx exécutée dans un autre container Docker**.

L'objectif est de comprendre comment :

- créer un réseau Docker ;
- lancer une application dans un container ;
- exécuter Robot Framework dans un autre container ;
- permettre aux containers de communiquer ;
- automatiser un test HTTP avec Robot Framework ;
- vérifier le résultat d'un test automatisé ;
- observer le comportement lorsque l'application est arrêtée.

> 💡 Aucun `Dockerfile` et aucun `docker-compose` ne sont utilisés dans ce TP.

---

# 1. Architecture du TP

À la fin du TP, nous aurons deux containers :

```text
                         Docker Network
                           robot-net
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
       ┌─────────────────┐          ┌──────────────────┐
       │   Container     │          │    Container     │
       │      web        │          │      robot       │
       │                 │          │                  │
       │      Nginx      │◄─────────│ Robot Framework  │
       │                 │   HTTP   │                  │
       └─────────────────┘          └──────────────────┘
```

Robot Framework va envoyer une requête HTTP vers :

```text
http://web
```

Le nom `web` correspond au nom du container Nginx.

---

# 2. Prérequis

Vérifier que Docker est installé :

```bash
docker --version
```

Vérifier que Docker fonctionne :

```bash
docker run --rm hello-world
```

---

# 3. Créer le réseau Docker

Créer un réseau dédié aux deux containers :

```bash
docker network create robot-net
```

Vérifier :

```bash
docker network ls
```

Vous devez retrouver :

```text
robot-net
```

---

# 4. Lancer le serveur Nginx

Nous allons maintenant lancer Nginx dans un container.

```bash
docker run -d \
  --name web \
  --network robot-net \
  nginx
```

Vérifier que le container fonctionne :

```bash
docker ps
```

Vous devez voir un container nommé :

```text
web
```

---

# 5. Tester Nginx

Afficher les informations du container :

```bash
docker inspect web
```

Afficher les logs :

```bash
docker logs web
```

Nous pouvons également tester Nginx directement depuis un autre container.

Lancer temporairement un container avec `curl` :

```bash
docker run --rm \
  --network robot-net \
  curlimages/curl \
  http://web
```

Vous devez obtenir une réponse contenant :

```html
<title>Welcome to nginx!</title>
```

ou :

```text
Welcome to nginx!
```

> 💡 Remarque : nous n'avons pas besoin de connaître l'adresse IP du container `web`.
>
> Docker fournit automatiquement une résolution DNS entre les containers présents sur le même réseau.

---

# 6. Préparer le projet Robot Framework

Créer un répertoire de travail :

```bash
mkdir robot-demo
cd robot-demo
```

Créer un répertoire pour les tests :

```bash
mkdir tests
```

L'arborescence doit être :

```text
robot-demo/
└── tests/
```

---

# 7. Créer le test Robot Framework

Créer le fichier :

```bash
nano tests/test.robot
```

Ajouter le contenu suivant :

```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Tester Nginx
    Create Session    nginx    http://web
    ${response}=    GET On Session    nginx    /
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.text}    Welcome to nginx!
```

Sauvegarder le fichier.

---

# 8. Comprendre le test

Le fichier Robot contient :

```robot
*** Settings ***
Library    RequestsLibrary
```

Cette ligne charge la bibliothèque permettant d'effectuer des requêtes HTTP.

---

La ligne :

```robot
Create Session    nginx    http://web
```

crée une session HTTP vers :

```text
http://web
```

`web` correspond au nom du container Nginx.

---

La ligne :

```robot
${response}=    GET On Session    nginx    /
```

effectue une requête HTTP :

```text
GET /
```

---

La ligne :

```robot
Should Be Equal As Integers    ${response.status_code}    200
```

vérifie que le serveur retourne :

```text
HTTP 200 OK
```

---

Enfin :

```robot
Should Contain    ${response.text}    Welcome to nginx!
```

vérifie que la réponse contient :

```text
Welcome to nginx!
```

---

# 9. Exécuter Robot Framework dans Docker

Nous allons maintenant exécuter Robot Framework **dans un container**.

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

Robot Framework va :

1. démarrer dans un container ;
2. accéder au réseau `robot-net` ;
3. lire notre fichier `test.robot` ;
4. contacter le container `web` ;
5. envoyer une requête HTTP ;
6. vérifier la réponse de Nginx ;
7. afficher le résultat du test.

---

# 10. Résultat attendu

Le test doit être en succès.

Vous devriez obtenir un résultat similaire à :

```text
==============================================================================
Tests
==============================================================================
Tester Nginx                                                     | PASS |
------------------------------------------------------------------------------
Tests                                                             | PASS |
1 test, 1 passed, 0 failed
==============================================================================
```

🎉 Félicitations !

Vous venez d'exécuter un test Robot Framework **entièrement dans un container Docker**.

---

# 11. Vérifier les containers

Pendant que Nginx fonctionne :

```bash
docker ps
```

Vous devez avoir :

```text
web
```

Le container Robot n'apparaît pas forcément dans `docker ps` car nous avons utilisé :

```bash
--rm
```

Le container Robot est supprimé automatiquement après l'exécution.

---

# 12. Comprendre `--rm`

Nous avons utilisé :

```bash
docker run --rm
```

Cela signifie :

> Supprimer automatiquement le container après son arrêt.

Ainsi, chaque exécution de Robot démarre avec un container propre.

---

# 13. Comprendre le volume

Nous avons utilisé :

```bash
-v $(pwd)/tests:/opt/robotframework/tests
```

Cela permet de partager le répertoire local :

```text
./tests
```

avec le container Robot :

```text
/opt/robotframework/tests
```

Ainsi, le fichier :

```text
tests/test.robot
```

est accessible depuis le container.

---

# 14. Comprendre le réseau Docker

Les deux containers utilisent :

```text
robot-net
```

Le container Nginx a été lancé avec :

```bash
--network robot-net
```

Le container Robot est également lancé avec :

```bash
--network robot-net
```

Grâce à cela, Robot peut accéder à Nginx avec :

```text
http://web
```

sans utiliser :

```text
localhost
```

et sans connaître l'adresse IP du container.

---

# 15. Expérience : arrêter l'application

Arrêter Nginx :

```bash
docker stop web
```

Vérifier :

```bash
docker ps
```

Le container `web` ne doit plus apparaître.

---

# 16. Relancer le test

Exécuter à nouveau :

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

Cette fois, le test doit échouer.

Pourquoi ?

Parce que Robot Framework essaie toujours d'accéder à :

```text
http://web
```

mais le serveur Nginx est arrêté.

---

# 17. Redémarrer Nginx

Redémarrer le container :

```bash
docker start web
```

Vérifier :

```bash
docker ps
```

Puis relancer le test :

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

Le test doit à nouveau être :

```text
PASS
```

---

# 18. Challenge 1 — Tester le code HTTP

Modifier le test pour vérifier uniquement que le serveur répond avec :

```text
200
```

Le test doit ressembler à :

```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Verifier Le Code HTTP
    Create Session    nginx    http://web
    ${response}=    GET On Session    nginx    /
    Should Be Equal As Integers    ${response.status_code}    200
```

Exécuter :

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

---

# 19. Challenge 2 — Provoquer volontairement un échec

Modifier :

```robot
Should Contain    ${response.text}    Welcome to nginx!
```

en :

```robot
Should Contain    ${response.text}    Bienvenue dans mon application!
```

Relancer le test.

Observer le résultat :

```text
FAIL
```

Robot Framework indique précisément quelle vérification n'a pas été satisfaite.

Remettre ensuite :

```robot
Should Contain    ${response.text}    Welcome to nginx!
```

et vérifier que le test repasse.

---

# 20. Challenge 3 — Ajouter un deuxième test

Ajouter un deuxième cas de test :

```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Verifier Le Code HTTP
    Create Session    nginx    http://web
    ${response}=    GET On Session    nginx    /
    Should Be Equal As Integers    ${response.status_code}    200

Verifier La Page Nginx
    Create Session    nginx    http://web
    ${response}=    GET On Session    nginx    /
    Should Contain    ${response.text}    Welcome to nginx!
```

Exécuter :

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

Vous devez obtenir :

```text
2 tests, 2 passed, 0 failed
```

---

# 21. Challenge 4 — Modifier l'application

L'objectif est maintenant de personnaliser la page Nginx.

Créer un fichier :

```bash
nano index.html
```

Mettre :

```html
<!DOCTYPE html>
<html>
<head>
    <title>Application DevOps</title>
</head>
<body>
    <h1>Bienvenue dans mon application</h1>
    <p>Cette application est exécutée avec Docker.</p>
</body>
</html>
```

Supprimer le container actuel :

```bash
docker rm -f web
```

Relancer Nginx avec notre page :

```bash
docker run -d \
  --name web \
  --network robot-net \
  -v $(pwd)/index.html:/usr/share/nginx/html/index.html:ro \
  nginx
```

Tester :

```bash
docker run --rm \
  --network robot-net \
  curlimages/curl \
  http://web
```

---

# 22. Adapter le test Robot

Modifier :

```bash
nano tests/test.robot
```

Utiliser :

```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
Verifier Mon Application
    Create Session    application    http://web
    ${response}=    GET On Session    application    /
    Should Be Equal As Integers    ${response.status_code}    200
    Should Contain    ${response.text}    Bienvenue dans mon application
    Should Contain    ${response.text}    Cette application est exécutée avec Docker.
```

Relancer :

```bash
docker run --rm \
  --network robot-net \
  -v $(pwd)/tests:/opt/robotframework/tests \
  ppodgorsek/robot-framework:latest
```

Résultat attendu :

```text
1 test, 1 passed, 0 failed
```

---

# 23. Nettoyage

À la fin du TP :

Arrêter et supprimer le container Nginx :

```bash
docker rm -f web
```

Supprimer le réseau :

```bash
docker network rm robot-net
```

Vérifier :

```bash
docker ps -a
```

Puis :

```bash
docker network ls
```

---

# 🎯 Bilan du TP

Dans ce TP, nous avons utilisé :

```text
Docker
   │
   ├── Container Nginx
   │       └── Application web
   │
   └── Container Robot Framework
           └── Tests automatisés
```

Nous avons appris à :

- créer un réseau Docker ;
- connecter plusieurs containers ;
- utiliser le nom d'un container comme adresse réseau ;
- exécuter Robot Framework dans un container ;
- monter un répertoire avec `-v` ;
- automatiser un test HTTP ;
- vérifier un code HTTP ;
- vérifier le contenu d'une réponse ;
- provoquer un échec de test ;
- interpréter le résultat `PASS` / `FAIL`.

## 💡 Message clé

> **Docker fournit l'environnement d'exécution, tandis que Robot Framework automatise les tests.**

Et surtout :

```text
Robot Framework n'est pas installé sur la machine.

              ↓

Robot Framework tourne dans un container Docker.

              ↓

Il teste une application qui tourne
dans un autre container Docker.
```
