# Formation — DevOps : démarche et outils
## Guide formateur intégral — 2 jours à distance
**Préparation à la certification DevOps Foundation® (PeopleCert / DevOps Institute)**

> **Usage de ce document :** support de conduite de formation. Le texte entre guillemets peut être lu presque tel quel à l’oral. Les indications `[FORMATEUR]` sont des consignes d’animation. Les activités sont conçues pour une classe à distance (Teams, Zoom ou équivalent).  
> **Positionnement :** formation de sensibilisation et de compréhension des concepts DevOps, avec démonstrations et exercices guidés. Ce document n’est pas le support officiel PeopleCert et ne remplace pas les supports officiels remis par un organisme de formation agréé.

---

# 0. Préparation du formateur

## 0.1 Objectif général

À la fin des deux jours, les participants doivent pouvoir expliquer ce qu’est DevOps, pourquoi une organisation l’adopte, quels principes et pratiques le structurent, comment les équipes collaborent, comment une chaîne d’outils automatise la livraison, et comment mesurer l’amélioration. Ils doivent aussi savoir reconnaître les notions clés attendues dans le périmètre DevOps Foundation.

Le fil rouge sera une application fictive appelée **ShopEasy**, une petite application web de commande. L’équipe reçoit une demande métier, modifie le code, le versionne, le construit, le teste, fabrique une image de conteneur, la déploie dans un environnement, puis observe le service. Ce scénario permet de relier les notions au lieu de présenter une succession d’outils isolés.

## 0.2 Principes pédagogiques

- Environ **40 % d’apports et 60 % d’échanges, de mises en situation et de pratique**.
- Une séquence théorique est suivie d’une question, d’un mini-cas ou d’une manipulation.
- Ne pas transformer la formation Foundation en formation d’expertise sur GitLab, Docker, Kubernetes ou Ansible. Les outils servent à illustrer les pratiques et les principes.
- Faire verbaliser les participants : « Quel problème cela résout-il ? », « Quel retour obtient-on ? », « Quelle équipe en bénéficie ? ».
- À distance : alterner partage d’écran, chat, sondages, tableau blanc et salles de sous-groupes. Ne pas parler plus de 10 à 15 minutes sans interaction.

## 0.3 Matériel et préparation technique

Avant la session :
1. Envoyer le lien de visioconférence et demander aux participants de se connecter avec micro et caméra si possible.
2. Préparer un tableau blanc avec les colonnes : **Idée / Développement / Test / Livraison / Exploitation / Retour**.
3. Préparer un sondage de démarrage : rôle, expérience Git, CI/CD, conteneurs, cloud, automatisation.
4. Préparer une démonstration courte : dépôt Git, pipeline CI simple, image Docker et tableau de suivi/logs. Si l’environnement n’est pas disponible, utiliser les captures ou les extraits de commandes de ce document.
5. Préparer des groupes de 3 à 5 personnes pour les ateliers.
6. Garder un document partagé pour les réponses et les questions « parking lot ».

**Règle de sécurité pour les démonstrations :** ne jamais afficher de mot de passe, token, clé privée, adresse interne sensible ou donnée réelle de client. Utiliser des comptes et dépôts de démonstration.

## 0.4 Diagnostic d’entrée — script à lire

« Bonjour à toutes et à tous. Avant de commencer, je vous propose un rapide tour de table. L’objectif n’est pas de vous évaluer individuellement, mais d’adapter le niveau de détail et les exemples à votre expérience. En une minute, indiquez votre rôle, les outils que vous utilisez aujourd’hui et une automatisation que vous avez déjà rencontrée ou réalisée. »

Questions à poser dans le chat ou à l’oral :
- Quel est votre rôle : développement, exploitation, test/QA, sécurité, projet, management, architecture ou autre ?
- Avez-vous déjà utilisé Git ou un autre outil de gestion de versions ?
- Avez-vous déjà vu un pipeline CI/CD ?
- Avez-vous déjà utilisé Docker ou une plateforme de conteneurs ?
- Quelle est votre principale difficulté dans le passage du développement à la production ?
- Qu’attendez-vous de ces deux jours et de la certification ?

[FORMATEUR] Relever les mots-clés. Si le groupe est débutant, expliquer les termes avant les acronymes. Si le groupe est expérimenté, demander des exemples concrets et faire le lien avec les principes Foundation.

## 0.5 Agenda proposé

| Jour | Horaire indicatif | Séquence |
|---|---:|---|
| J1 | 09:00–09:30 | Accueil, diagnostic, objectifs |
| J1 | 09:30–10:30 | 1. Explorer DevOps |
| J1 | 10:30–10:45 | Pause |
| J1 | 10:45–12:00 | 2. Principes fondamentaux et Three Ways |
| J1 | 12:00–13:00 | Déjeuner |
| J1 | 13:00–14:30 | 3. Pratiques DevOps : Agile, Lean, CI, livraison, tests |
| J1 | 14:30–14:45 | Pause |
| J1 | 14:45–16:00 | 4. Culture, comportements, modèles opérationnels |
| J1 | 16:00–16:30 | Atelier fil rouge et synthèse |
| J2 | 09:00–09:15 | Réactivation des acquis |
| J2 | 09:15–10:30 | 5. Frameworks et pratiques de service |
| J2 | 10:30–10:45 | Pause |
| J2 | 10:45–12:00 | 6. Automatisation et toolchain |
| J2 | 12:00–13:00 | Déjeuner |
| J2 | 13:00–14:00 | 7. Mesure, métriques et reporting |
| J2 | 14:00–14:45 | 8. Partage, évolution et adoption à l’échelle |
| J2 | 14:45–15:00 | Pause |
| J2 | 15:00–16:00 | Atelier final : concevoir une démarche DevOps |
| J2 | 16:00–16:30 | Révision certification et quiz final |

Les horaires sont indicatifs. Adapter les pauses et la durée des échanges au rythme du groupe.

---

# JOUR 1 — Comprendre la démarche DevOps

# 1. Explorer DevOps

## 1.1 Introduction — script oral

« Nous allons commencer par une question simple : pourquoi parle-t-on autant de DevOps ? Ce n’est pas parce qu’un nouvel outil est apparu. DevOps répond à un problème organisationnel et opérationnel : comment livrer plus rapidement de la valeur aux utilisateurs, sans dégrader la qualité, la sécurité ni la stabilité du service ?

Pendant longtemps, les organisations ont séparé les équipes qui construisent les applications de celles qui les exploitent. Cette séparation peut créer des objectifs contradictoires. Le développement cherche à faire évoluer rapidement le produit. L’exploitation cherche à maintenir un service stable et prévisible. Les tests peuvent intervenir tardivement. La sécurité peut être sollicitée à la fin. Le résultat est souvent un passage de relais, avec des attentes différentes, des délais et des incompréhensions.

DevOps cherche à rapprocher ces activités. Il combine culture, pratiques, processus et automatisation pour améliorer le flux de valeur, la qualité et le retour d’information. »

## 1.2 Définition à transmettre

DevOps est une approche culturelle et organisationnelle qui favorise la collaboration entre le développement (Dev) et les opérations informatiques (Ops), en s’appuyant sur l’automatisation, le partage des responsabilités, des boucles de feedback courtes et l’amélioration continue, afin de fournir des services de meilleure qualité plus fréquemment et de manière plus fiable.

À retenir :
- DevOps n’est **pas uniquement un outil**.
- DevOps n’est **pas uniquement un poste** ou une équipe appelée « DevOps ».
- DevOps n’est **pas simplement mettre les développeurs et les exploitants dans la même équipe**.
- DevOps n’est **pas synonyme de CI/CD** : la CI/CD est un ensemble de pratiques qui contribuent à la démarche.
- DevOps ne supprime pas les exigences de gouvernance, de sécurité, de conformité ou de contrôle ; il cherche à les intégrer plus tôt et de façon fluide.

« Si une entreprise achète GitLab, Docker et Kubernetes mais conserve les mêmes silos, les mêmes validations tardives et les mêmes objectifs contradictoires, elle a modernisé sa boîte à outils, mais elle n’a pas nécessairement adopté DevOps. »

## 1.3 Pourquoi DevOps ?

Présenter les problèmes typiques :
1. Délais importants entre la demande et la mise à disposition.
2. Beaucoup de tâches manuelles et répétitives.
3. Défauts détectés tardivement.
4. Déploiements risqués, rares ou stressants.
5. Responsabilités fragmentées.
6. Peu de visibilité sur l’état réel du service.
7. Retours utilisateurs trop tardifs.
8. Incidents difficiles à diagnostiquer et à corriger.

Les objectifs recherchés :
- accélérer le délai de livraison ;
- améliorer la fréquence et la fiabilité des mises en production ;
- réduire les erreurs humaines par l’automatisation ;
- améliorer la qualité par des tests fréquents ;
- renforcer la collaboration et la transparence ;
- raccourcir le délai de détection et de résolution des incidents ;
- apprendre des échecs et améliorer le système.

« Attention : aller plus vite ne signifie pas supprimer les contrôles. L’objectif est de rendre les contrôles plus précoces, plus automatisés et plus reproductibles. Une livraison rapide mais instable n’est pas une réussite DevOps. »

## 1.4 Exemple concret : avant et après

**Situation avant DevOps :**
- Le métier demande une évolution.
- Le développement réalise plusieurs semaines de travail dans son environnement.
- Les tests sont regroupés à la fin.
- L’équipe exploitation reçoit un dossier de livraison.
- Les environnements ne sont pas identiques.
- Une dépendance ou une configuration manque.
- La mise en production est reportée ou échoue.
- Les équipes cherchent qui est responsable.

**Situation avec une démarche DevOps :**
- Les équipes clarifient ensemble le besoin et les critères d’acceptation.
- Le code est versionné et intégré régulièrement.
- Des tests automatiques s’exécutent à chaque changement pertinent.
- L’application est empaquetée de manière reproductible.
- Le déploiement est automatisé et contrôlé.
- Les configurations sont gérées et tracées.
- Les métriques et les logs permettent de suivre le service.
- Les retours d’exploitation et des utilisateurs alimentent les évolutions suivantes.

« La différence ne vient pas d’un bouton magique. Elle vient de la réduction des attentes, des transferts, des tâches manuelles et des retours tardifs. »

## 1.5 Valeur métier et valeur IT

Expliquer que DevOps vise un résultat métier, pas la multiplication des déploiements.

Exemples de valeur métier :
- rendre une fonctionnalité disponible au moment où elle est utile ;
- réduire le temps d’attente d’un client ;
- tester une hypothèse métier rapidement ;
- améliorer la satisfaction et la fidélisation ;
- réduire le coût des incidents et des changements ratés.

Exemples de valeur IT :
- réduire les erreurs de déploiement ;
- fiabiliser les environnements ;
- améliorer la traçabilité ;
- réduire les interventions manuelles ;
- détecter plus tôt les régressions ;
- améliorer la disponibilité et la capacité de récupération.

## 1.6 Atelier à distance — « DevOps ou pas DevOps ? »

Durée : 15 minutes. Faire voter dans le chat : **DevOps / Pas forcément / Cela dépend**, puis demander une justification.

1. « Nous avons acheté un outil CI/CD. Sommes-nous DevOps ? »
2. « Les développeurs et les exploitants partagent les responsabilités de production. Est-ce une pratique DevOps ? »
3. « Nous déployons dix fois par jour, mais nous provoquons régulièrement des incidents. Est-ce une réussite ? »
4. « Nous automatisons les tests et nous analysons les échecs pour améliorer le produit. Est-ce DevOps ? »
5. « Une équipe dédiée réalise toutes les opérations à la place des développeurs et de l’exploitation. Est-ce suffisant ? »

Correction :
1. Pas forcément : l’outil ne suffit pas.
2. Oui, c’est un comportement favorable, à accompagner d’autres pratiques.
3. Non : la fréquence seule ne suffit pas ; qualité et stabilité comptent.
4. Oui : automatisation, feedback et amélioration continue.
5. Pas nécessairement : une équipe spécialisée peut aider, mais elle ne doit pas devenir un nouveau silo.

## 1.7 Transition

« Nous avons vu le problème et l’intention. Nous allons maintenant découvrir les principes qui expliquent comment améliorer le flux de travail. Le référentiel DevOps Foundation met notamment l’accent sur les Three Ways, ou trois voies. »

---

# 2. Principes fondamentaux — The Three Ways

## 2.1 Présentation générale

Les Three Ways sont un modèle de pensée qui aide à comprendre les principes du flux de valeur DevOps.

1. **First Way — Flow :** accélérer le flux de travail, de la demande jusqu’à l’utilisateur.
2. **Second Way — Feedback :** créer des boucles de retour rapides et fréquentes.
3. **Third Way — Continual Learning and Experimentation :** développer l’apprentissage continu, l’expérimentation et l’amélioration.

« Ces trois voies ne sont pas trois étapes d’un projet. Ce sont trois principes qui doivent fonctionner ensemble. »

## 2.2 Première voie : Flow — le flux

Objectif : faire circuler le travail de manière fluide, du besoin métier jusqu’à la valeur livrée.

Principes :
- visualiser le travail ;
- limiter le travail en cours (WIP — Work In Progress) ;
- réduire les files d’attente et les transferts ;
- identifier les goulots d’étranglement ;
- automatiser les tâches répétitives ;
- découper les changements en lots plus petits ;
- rendre le flux mesurable.

Exemple :
« Imaginons que le développement termine 20 fonctionnalités, mais que les tests ne peuvent en traiter que 5 par semaine. Le problème n’est pas que les développeurs ne travaillent pas assez. Le flux est déséquilibré. Accumuler encore plus de développement augmente la file d’attente et retarde le feedback. »

Expliquer le **WIP** : quantité de travail commencée mais pas encore terminée. Trop de WIP entraîne du multitâche, des changements de contexte, des délais et des blocages.

Expliquer le **goulot d’étranglement** : étape qui limite le débit global du système. Améliorer une étape qui n’est pas le goulot peut ne pas améliorer le résultat global.

## 2.3 Théorie des contraintes

La Theory of Constraints (TOC) invite à identifier la contrainte principale du système, puis à concentrer les efforts sur elle.

Démarche simplifiée :
1. Identifier la contrainte.
2. Exploiter au mieux la contrainte existante.
3. Subordonner les autres activités à cette contrainte.
4. Augmenter la capacité de la contrainte si nécessaire.
5. Recommencer lorsque la contrainte se déplace.

Exemple à raconter :
« Si la validation de sécurité prend trois semaines parce qu’elle est réalisée uniquement à la fin, ajouter des développeurs ne résout pas le problème. Il faut comprendre pourquoi la validation est tardive, intégrer les contrôles plus tôt, automatiser ce qui peut l’être et réserver l’expertise humaine aux décisions qui le nécessitent. »

## 2.4 Deuxième voie : Feedback — le retour d’information

Objectif : détecter les problèmes tôt, comprendre rapidement les résultats et ajuster le travail.

Exemples de boucles de feedback :
- retour du compilateur ;
- tests unitaires et tests d’intégration ;
- analyse de qualité et de sécurité ;
- revue de code ;
- tests utilisateurs ;
- métriques applicatives ;
- alertes de supervision ;
- analyse post-incident ;
- retour du support et des clients.

« Plus le retour arrive tard, plus le coût de correction peut augmenter. Un défaut détecté quelques secondes après un commit est généralement plus simple à comprendre qu’un défaut découvert plusieurs semaines après une mise en production. »

Principes :
- rendre les résultats visibles ;
- automatiser les contrôles rapides ;
- alerter sur des symptômes exploitables ;
- partager les informations entre les équipes ;
- éviter de masquer les mauvaises nouvelles ;
- faire remonter les problèmes à leur source.

## 2.5 Troisième voie : Continual Learning and Experimentation

Objectif : construire une organisation qui apprend en permanence.

Pratiques :
- rétrospectives ;
- post-mortems sans recherche de coupable ;
- partage des connaissances ;
- expérimentation contrôlée ;
- amélioration des pratiques ;
- injection de défaillances dans un environnement maîtrisé ;
- formation et accompagnement ;
- documentation vivante.

« Dans une organisation apprenante, un incident n’est pas seulement un événement à clôturer. C’est une occasion de comprendre pourquoi le système a permis à cet incident de se produire et comment éviter qu’il se reproduise. »

## 2.6 Chaos Engineering

Définition : approche qui consiste à provoquer volontairement et de façon contrôlée des défaillances afin de vérifier la résilience d’un système.

Exemples :
- arrêter une instance d’application ;
- introduire une latence réseau ;
- rendre une dépendance temporairement indisponible ;
- simuler une saturation de ressources.

Précautions :
- définir une hypothèse ;
- limiter le périmètre ;
- prévenir les personnes concernées ;
- disposer d’un mécanisme d’arrêt ;
- surveiller les effets ;
- commencer dans un environnement maîtrisé ;
- ne jamais improviser une expérimentation risquée en production.

## 2.7 Learning Organization

Une organisation apprenante :
- encourage le partage ;
- traite les erreurs comme des occasions d’apprentissage ;
- favorise la transparence ;
- accepte l’expérimentation raisonnable ;
- transforme les enseignements en actions concrètes ;
- vérifie que les actions ont produit un effet.

## 2.8 Atelier — retrouver les Three Ways

Durée : 20 minutes. En sous-groupes, classer les situations dans Flow, Feedback ou Continual Learning. Certaines peuvent relever de plusieurs voies.

- Réduire le nombre de tickets commencés simultanément.
- Lancer automatiquement les tests après chaque intégration.
- Organiser une rétrospective après un incident.
- Afficher le temps d’attente de chaque étape du processus.
- Simuler la perte d’une instance pour vérifier le comportement du service.
- Partager un retour utilisateur directement avec l’équipe produit.

Correction :
- WIP et visualisation du flux : Flow.
- Tests automatiques : Feedback, et contribution au Flow.
- Rétrospective : Continual Learning.
- Temps d’attente : Flow et Feedback.
- Simulation de panne : Continual Learning et Feedback.
- Retour utilisateur : Feedback et apprentissage.

## 2.9 Questions de vérification

- Quelle voie cherche à optimiser le flux de valeur ? **La première voie.**
- Quelle voie insiste sur les boucles de retour rapides ? **La deuxième voie.**
- Quelle voie favorise l’apprentissage et l’expérimentation ? **La troisième voie.**
- Quel est le but de la Theory of Constraints ? **Identifier et traiter la contrainte qui limite le système.**
- Chaos Engineering signifie-t-il provoquer des pannes sans contrôle ? **Non, les expériences sont planifiées, limitées et observées.**

---

# 3. Pratiques DevOps : Agile, Lean, intégration, livraison et tests

## 3.1 Agile et DevOps

« Agile et DevOps sont complémentaires, mais ne désignent pas la même chose. Agile aide principalement à organiser le développement autour de livraisons incrémentales, de la collaboration et de l’adaptation au changement. DevOps étend cette logique jusqu’à la livraison, au déploiement, à l’exploitation et au feedback du service. »

Agile :
- travail par incréments ;
- priorisation par la valeur ;
- collaboration avec le client ;
- adaptation au changement ;
- feedback fréquent ;
- équipes pluridisciplinaires.

DevOps :
- collaboration Dev et Ops ;
- automatisation du cycle de livraison ;
- responsabilité partagée ;
- intégration et livraison fréquentes ;
- supervision et apprentissage en production.

Ne pas confondre Agile avec une méthode unique. Scrum et Kanban sont des cadres ou approches de travail qui peuvent être utilisés dans un contexte Agile.

## 3.2 Lean et DevOps

Lean cherche à maximiser la valeur pour le client en réduisant les gaspillages.

Exemples de gaspillages dans l’IT :
- attente d’une validation ;
- transfert entre équipes ;
- travail commencé mais non terminé ;
- fonctionnalités inutilisées ;
- corrections répétées ;
- tâches manuelles sans valeur ;
- défauts détectés tardivement ;
- réunions et rapports sans décision utile.

Principes Lean :
- définir la valeur du point de vue du client ;
- visualiser la chaîne de valeur ;
- favoriser le flux ;
- produire à partir de la demande ;
- rechercher l’amélioration continue.

« Lean ne signifie pas faire travailler les personnes plus vite en supprimant les pauses. Il s’agit d’améliorer le système de travail et de supprimer ce qui n’apporte pas de valeur. »

## 3.3 Gestion de versions — Git

Git est un système distribué de gestion de versions. Il permet de suivre l’évolution du code et des fichiers, de collaborer et de revenir à un état précédent.

Vocabulaire :
- **Repository / dépôt :** espace contenant le projet et son historique.
- **Commit :** enregistrement d’un ensemble de modifications.
- **Branch / branche :** ligne de développement indépendante.
- **Merge :** intégration de changements.
- **Pull/Merge Request :** proposition de changement soumise à revue.
- **Tag :** étiquette associée à une version ou un état du dépôt.

Commandes de démonstration :

```bash
git clone https://example.org/shopeasy.git
cd shopeasy
git status
git switch -c feature/discount-code
# modifier un fichier
git add .
git commit -m "Add discount code validation"
git push -u origin feature/discount-code
```

« Git ne fait pas à lui seul du DevOps. Il apporte une base essentielle : l’historique, la traçabilité et la collaboration autour des changements. »

Bonnes pratiques :
- commits petits et compréhensibles ;
- messages explicites ;
- branches adaptées à la stratégie de l’équipe ;
- revue de code ;
- protection des branches sensibles ;
- secrets exclus du dépôt ;
- tags de version.

## 3.4 Intégration continue — Continuous Integration (CI)

Définition : pratique consistant à intégrer fréquemment les changements dans une base commune, avec des vérifications automatiques permettant de détecter rapidement les problèmes.

Étapes possibles :
1. récupération du code ;
2. installation des dépendances ;
3. compilation ou construction ;
4. tests unitaires ;
5. analyse statique ;
6. publication des résultats et artefacts.

Bénéfices :
- conflits détectés plus tôt ;
- défauts identifiés rapidement ;
- qualité plus régulière ;
- intégration moins risquée ;
- feedback rapide.

« La CI n’est pas simplement un serveur qui exécute un script une fois par nuit. La pratique repose sur des intégrations fréquentes et un feedback rapide sur chaque changement. »

## 3.5 Livraison continue et déploiement continu

**Continuous Delivery — livraison continue :** le logiciel est maintenu dans un état permettant une mise en production fiable. Le déploiement en production peut rester soumis à une décision ou validation humaine.

**Continuous Deployment — déploiement continu :** chaque changement qui passe l’ensemble des contrôles définis peut être déployé automatiquement en production.

Différence essentielle :
- Delivery : prêt à être déployé, décision de mise en production éventuellement manuelle.
- Deployment : déploiement en production automatisé après validation des critères.

Ne pas confondre livraison continue et déploiement continu.

## 3.6 Pipeline de déploiement

Un pipeline représente une succession d’étapes automatisées qui vérifient, construisent, empaquettent et livrent une application.

Exemple :

```text
Commit
  |
  v
Build / Compilation
  |
  v
Tests unitaires
  |
  v
Analyse qualité et sécurité
  |
  v
Package / Artefact
  |
  v
Image conteneur
  |
  v
Déploiement environnement de test
  |
  v
Tests d'intégration / validation
  |
  v
Approbation éventuelle
  |
  v
Déploiement production
  |
  v
Monitoring et feedback
```

Chaque étape doit produire un résultat visible. En cas d’échec, le pipeline doit s’arrêter ou appliquer une politique explicite. Il faut éviter de promouvoir un artefact différent entre les environnements.

## 3.7 Tests continus

Les tests doivent être réalisés tôt et régulièrement.

Familles de tests :
- tests unitaires : vérifient une petite unité de code ;
- tests d’intégration : vérifient les interactions entre composants ;
- tests système ou end-to-end : vérifient un parcours complet ;
- tests de performance : mesurent comportement et capacité ;
- tests de sécurité : recherchent des vulnérabilités ;
- tests d’acceptation : vérifient les critères attendus par le métier.

Pyramide des tests :
- base large : nombreux tests unitaires rapides ;
- niveau intermédiaire : tests d’intégration ;
- sommet plus réduit : tests end-to-end, souvent plus coûteux et fragiles.

« L’idée n’est pas de tout tester uniquement à la fin. On cherche à obtenir le feedback le plus rapide possible au niveau approprié. »

## 3.8 Démonstration guidée d’un pipeline

[FORMATEUR] Partager un pipeline simple et commenter chaque bloc. Exemple pédagogique GitLab CI :

```yaml
stages:
  - build
  - test
  - package

build:
  stage: build
  script:
    - echo "Compilation de ShopEasy"
    - mkdir -p dist
    - echo "application-demo" > dist/app.txt
  artifacts:
    paths:
      - dist/

test:
  stage: test
  script:
    - echo "Execution des tests"
    - test -s dist/app.txt

package:
  stage: package
  script:
    - echo "Preparation du livrable"
```

À expliquer :
- `stages` définit l’ordre logique ;
- chaque job appartient à un stage ;
- `script` contient les commandes exécutées ;
- `artifacts` conserve un résultat produit par le job ;
- si un job échoue, le pipeline ne poursuit généralement pas les étapes dépendantes.

Préciser que cet exemple est volontairement minimal et ne constitue pas un pipeline de production.

## 3.9 Atelier — concevoir une CI

Durée : 25 minutes. En groupes, les participants conçoivent le pipeline d’une petite application web.

Consigne à lire :
« Votre équipe vient de modifier la fonction de calcul du prix d’une commande. Définissez les contrôles que vous souhaitez exécuter avant de livrer le changement. Classez-les dans l’ordre et précisez à quel moment une intervention humaine reste nécessaire. »

Résultat attendu :
1. récupération du code ;
2. build ;
3. tests unitaires ;
4. analyse qualité et sécurité ;
5. packaging ;
6. déploiement en test ;
7. tests d’intégration ou acceptation ;
8. approbation éventuelle ;
9. production ;
10. monitoring.

Débrief :
- Quels tests sont les plus rapides ?
- Quels contrôles peuvent être automatisés ?
- Quels contrôles nécessitent un jugement humain ?
- Que doit-on faire si un test échoue ?
- Comment sait-on quelle version est en production ?

---

# 4. Culture, comportements et modèles opérationnels

## 4.1 La culture DevOps

« La culture est le socle de DevOps. Les outils peuvent accélérer un processus, mais ils ne corrigent pas automatiquement le manque de confiance, les objectifs contradictoires ou l’absence de communication. »

Caractéristiques d’une culture favorable :
- collaboration ;
- confiance ;
- transparence ;
- responsabilité partagée ;
- apprentissage continu ;
- expérimentation ;
- feedback ;
- orientation client ;
- amélioration continue.

## 4.2 Silos et responsabilité partagée

Modèle traditionnel :
- développement : « J’ai terminé mon code. »
- test : « J’ai trouvé des défauts. »
- exploitation : « Je ne peux pas déployer ce qui m’a été transmis. »
- sécurité : « Vous nous avez sollicités trop tard. »

Approche DevOps :
- les équipes définissent ensemble les critères de qualité ;
- les exigences d’exploitation et de sécurité sont prises en compte dès la conception ;
- les développeurs comprennent les contraintes de production ;
- les opérations participent à l’amélioration du processus ;
- les résultats et les incidents sont partagés.

« Responsabilité partagée ne signifie pas que tout le monde fait tout. Cela signifie que les équipes comprennent l’impact de leurs décisions sur le service complet et coopèrent pour atteindre un objectif commun. »

## 4.3 Modèles d’organisation

Présenter plusieurs formes possibles :
- équipes produit pluridisciplinaires responsables d’un service ;
- équipe plateforme fournissant des capacités communes ;
- spécialistes (sécurité, réseau, base de données) intégrés ou sollicités comme facilitateurs ;
- équipe d’accompagnement/transformation aidant les équipes à adopter les pratiques.

Attention au piège du « silo DevOps » : créer une équipe qui reçoit toutes les demandes de déploiement et devient un nouveau point de passage peut reproduire le problème initial.

L’organisation doit être adaptée à la taille, au contexte réglementaire, aux compétences et à la criticité du service.

## 4.4 Blameless culture — culture sans recherche de coupable

Après un incident, la question utile n’est pas seulement « Qui a fait l’erreur ? », mais :
- quelles conditions ont rendu l’erreur possible ?
- quelles informations manquaient ?
- quels contrôles auraient pu détecter le problème ?
- le système rendait-il l’action risquée facile ?
- quelles améliorations éviteront une répétition ?

Un post-mortem sans blâme ne supprime pas la responsabilité. Il cherche à comprendre le système et à prévenir les incidents futurs.

## 4.5 Sécurité et DevSecOps

DevSecOps intègre la sécurité tout au long du cycle de vie :
- exigences de sécurité dès la conception ;
- analyse des dépendances ;
- analyse statique du code ;
- recherche de secrets ;
- analyse des images de conteneurs ;
- contrôle des configurations ;
- gestion des accès et des identités ;
- traçabilité et conformité ;
- surveillance des vulnérabilités après livraison.

Concept : **Shift Left**. Déplacer les contrôles vers les premières étapes du cycle, pour détecter plus tôt les défauts et vulnérabilités.

« Shift Left ne veut pas dire que la sécurité devient uniquement le travail des développeurs. Les spécialistes sécurité apportent leur expertise, définissent les politiques et aident à automatiser les contrôles. »

## 4.6 Cultural Debt

La dette culturelle correspond aux habitudes, comportements et modes de fonctionnement historiques qui empêchent l’évolution : silos, manque de confiance, rétention d’information, peur de l’échec, objectifs locaux contradictoires ou validation excessive.

Elle ne se résout pas par un nouvel outil. Elle nécessite du leadership, du dialogue, des objectifs communs, des changements progressifs et de la cohérence dans les comportements.

## 4.7 Atelier — incident sans coupable

Durée : 20 minutes.

Scénario :
« Une mise à jour de ShopEasy a été déployée. Une variable de configuration était absente dans l’environnement de production. L’application a redémarré en boucle pendant 12 minutes. Le support a reçu plusieurs réclamations. Le déploiement avait été réalisé manuellement et la procédure était dans un document qui n’était plus à jour. »

Questions :
1. Quels sont les impacts ?
2. Quelles conditions ont contribué à l’incident ?
3. Quels signaux auraient permis de détecter le problème plus tôt ?
4. Quelles actions préventives proposer ?
5. Comment éviter de chercher un coupable ?

Pistes de correction :
- configuration non versionnée ou non validée ;
- différence entre environnements ;
- absence de contrôle automatique des variables obligatoires ;
- déploiement manuel ;
- procédure obsolète ;
- absence de test de démarrage ou de smoke test ;
- alertes non adaptées.

Actions :
- gérer la configuration de manière contrôlée ;
- valider les paramètres avant déploiement ;
- automatiser le déploiement ;
- ajouter un test de santé ;
- mettre à jour la documentation ;
- définir un rollback ;
- partager l’apprentissage.

## 4.8 Synthèse du jour 1 — script oral

« Aujourd’hui, nous avons vu que DevOps est une démarche globale. Nous avons commencé par les problèmes de silos et de transferts, puis étudié les trois voies : fluidifier le travail, accélérer le feedback et apprendre en continu. Nous avons relié DevOps à Agile et Lean, puis abordé l’intégration continue, la livraison continue, les tests et la culture. Demain, nous allons voir comment les frameworks, les outils, les métriques et les pratiques d’adoption permettent de rendre cette démarche concrète et durable. »

---

# JOUR 2 — Mettre en œuvre, mesurer et faire évoluer DevOps

# 5. Frameworks métier et technologiques

## 5.1 Réactivation — 15 minutes

[FORMATEUR] Demander aux participants de répondre dans le chat :
- Les trois voies ?
- Différence entre Continuous Delivery et Continuous Deployment ?
- Pourquoi un outil seul ne suffit-il pas ?
- Que signifie Shift Left ?
- Que cherche-t-on à apprendre lors d’un post-mortem sans blâme ?

Faire corriger par le groupe, puis compléter.

## 5.2 DevOps, ITSM et gestion des services

ITSM (IT Service Management) regroupe les pratiques permettant de concevoir, fournir, gérer et améliorer les services informatiques.

DevOps et ITSM ne sont pas opposés. Ils peuvent être complémentaires :
- ITSM apporte des pratiques de gestion des services, des incidents, des changements et des niveaux de service ;
- DevOps cherche à fluidifier et automatiser les processus de bout en bout ;
- les deux visent la qualité et la valeur du service.

Exemples :
- gestion des incidents : restaurer rapidement le service et apprendre de l’incident ;
- gestion des changements : évaluer le risque et maîtriser les changements ;
- gestion des problèmes : identifier les causes récurrentes ;
- gestion des demandes : traiter les besoins de manière standardisée ;
- gestion des niveaux de service : définir les engagements et mesurer les résultats.

« DevOps ne signifie pas supprimer toutes les validations de changement. Il invite à adapter les contrôles au risque, à automatiser les changements standards et à rendre le processus plus rapide et plus fiable. »

## 5.3 Agile, Lean, ITSM : comment les articuler ?

- Agile : organiser l’évolution du produit et s’adapter au feedback.
- Lean : optimiser le flux de valeur et réduire les gaspillages.
- ITSM : assurer la gestion et la qualité des services.
- DevOps : rapprocher les personnes, les processus et les technologies du développement à l’exploitation.

Ces approches peuvent coexister dans une même organisation.

## 5.4 Value Stream Management (VSM)

Le Value Stream Management consiste à comprendre, visualiser et améliorer le flux de valeur depuis une demande jusqu’au résultat pour le client.

Exemple de chaîne :
Demande métier → priorisation → développement → revue → tests → livraison → déploiement → usage → feedback.

Mesures possibles :
- temps total entre demande et valeur livrée ;
- temps d’attente par étape ;
- temps de traitement réel ;
- taux de reprise ;
- points de blocage ;
- valeur obtenue par rapport à l’effort.

Expliquer la différence entre **Lead Time** et **Cycle Time** :
- Lead Time : durée totale entre la demande ou le début de la mesure définie et la livraison ;
- Cycle Time : durée pendant laquelle le travail est effectivement pris en charge et traité, selon la convention de mesure choisie.

Toujours préciser les bornes de mesure. Deux équipes peuvent utiliser les mêmes termes avec des définitions différentes.

## 5.5 SRE — Site Reliability Engineering

SRE applique des pratiques d’ingénierie logicielle à l’exploitation et à la fiabilité des services.

Concepts à connaître :
- **SLI (Service Level Indicator)** : indicateur mesurant un aspect du service, par exemple le taux de requêtes réussies.
- **SLO (Service Level Objective)** : objectif interne de niveau de service, par exemple 99,9 % de disponibilité sur une période.
- **SLA (Service Level Agreement)** : engagement formel vis-à-vis du client ou de l’utilisateur, avec des conséquences éventuelles en cas de non-respect.
- **Error Budget** : marge d’erreur acceptable associée à un SLO, utilisée pour arbitrer entre évolution et fiabilité.

Exemple :
Un SLO de disponibilité de 99,9 % signifie que l’organisation accepte une certaine quantité d’indisponibilité sur la période de mesure. Le budget d’erreur aide à décider si l’équipe peut continuer à accélérer les changements ou doit consacrer davantage d’efforts à la fiabilité.

Ne pas confondre :
- SLI = ce que l’on mesure ;
- SLO = la cible ;
- SLA = l’engagement contractuel ou formel.

## 5.6 Safety Culture et organisation apprenante

Une culture de sécurité/sûreté favorise le signalement des risques, la transparence et l’amélioration. Il faut distinguer :
- sécurité informatique (protection contre les menaces) ;
- sûreté ou sécurité opérationnelle selon le contexte ;
- culture de sécurité (comportements permettant de détecter et gérer les risques).

L’organisation apprenante s’appuie sur le partage des expériences, la formation, les retours d’expérience et la capacité à transformer les constats en changements.

## 5.7 Continuous Funding

Le financement continu vise à financer les produits, services ou flux de valeur de manière plus régulière, plutôt que de tout concentrer dans des projets ponctuels à durée fixe. Il permet de réorienter les moyens selon la valeur, les résultats et les priorités.

Ce modèle suppose une gouvernance adaptée, de la visibilité sur les résultats et une capacité à arbitrer en continu.

## 5.8 Platform Engineering

Le Platform Engineering consiste à fournir une plateforme interne qui simplifie le travail des équipes de développement : modèles de pipelines, environnements, services communs, déploiements, observabilité et garde-fous.

La plateforme doit être conçue comme un produit interne :
- connaître ses utilisateurs (équipes de développement) ;
- proposer une expérience simple ;
- documenter les parcours ;
- mesurer l’adoption et la satisfaction ;
- fournir des standards sans bloquer inutilement l’autonomie.

## 5.9 Microservices, cloud et conteneurs

**Cloud :** mise à disposition de ressources informatiques à la demande, avec différents modèles de service et de déploiement.

**Conteneur :** mécanisme d’empaquetage et d’isolation permettant de distribuer une application avec ses dépendances. Un conteneur partage le noyau de l’hôte ; ce n’est pas une machine virtuelle complète.

**Microservices :** architecture où une application est décomposée en services relativement autonomes, communiquant via des interfaces définies.

Points de vigilance :
- les microservices ajoutent des enjeux de réseau, de sécurité, de supervision et de cohérence des données ;
- les conteneurs ne rendent pas automatiquement une application scalable ou résiliente ;
- Kubernetes orchestre des conteneurs mais ne remplace ni l’architecture, ni les tests, ni la supervision.

---

# 6. Automatisation et architecture de la chaîne d’outils DevOps

## 6.1 Pourquoi automatiser ?

« L’automatisation vise à rendre les opérations répétables, prévisibles, traçables et moins dépendantes d’actions manuelles. Elle libère du temps pour les tâches qui nécessitent une analyse ou une décision humaine. »

À automatiser en priorité :
- tâches répétitives ;
- tâches fréquentes ;
- tâches sujettes aux erreurs ;
- tâches nécessitant une traçabilité ;
- contrôles rapides et objectifs ;
- déploiements reproductibles.

Ne pas automatiser aveuglément un processus inutile ou mal compris. Il faut d’abord simplifier et standardiser.

## 6.2 Infrastructure as Code (IaC)

L’Infrastructure as Code consiste à décrire l’infrastructure dans des fichiers versionnés et exécutables par des outils.

Bénéfices :
- reproductibilité ;
- traçabilité ;
- revue des changements ;
- cohérence entre environnements ;
- automatisation ;
- réduction des écarts de configuration.

Exemples d’outils :
- Terraform : provisionnement déclaratif de ressources ;
- Ansible : automatisation de configuration et d’orchestration ;
- outils cloud natifs : modèles d’infrastructure des fournisseurs.

Différence simple :
- Terraform décrit principalement l’état d’infrastructure souhaité et gère les ressources ;
- Ansible automatise fréquemment la configuration et les tâches sur les systèmes.

## 6.3 Configuration Management

La gestion de configuration vise à maintenir les systèmes dans un état défini et cohérent.

Exemples :
- installer un paquet ;
- créer un utilisateur ;
- configurer un service ;
- déployer un fichier ;
- démarrer ou activer un service.

La notion d’idempotence est importante : exécuter plusieurs fois une opération idempotente produit le même état final attendu, sans effets indésirables répétés.

## 6.4 Conteneurisation — Docker

Docker est un écosystème populaire pour construire et exécuter des conteneurs.

Vocabulaire :
- image : modèle immuable servant à créer un conteneur ;
- conteneur : instance en cours d’exécution d’une image ;
- Dockerfile : recette de construction d’une image ;
- registry : dépôt d’images ;
- volume : mécanisme de persistance des données ;
- réseau : communication entre conteneurs et avec l’extérieur.

Commandes illustratives :

```bash
docker build -t shopeasy:1.0 .
docker images
docker run -d --name shopeasy -p 8080:80 shopeasy:1.0
docker ps
docker logs shopeasy
docker stop shopeasy
docker rm shopeasy
```

« Une image identifiée par une version explicite facilite la traçabilité. En production, éviter de dépendre uniquement d’un tag mutable comme `latest`. »

## 6.5 Orchestration — Kubernetes

Kubernetes orchestre des charges de travail conteneurisées. Il aide notamment à :
- déclarer l’état souhaité ;
- maintenir le nombre de réplicas ;
- redémarrer ou remplacer des instances ;
- distribuer le trafic ;
- gérer des déploiements progressifs ;
- fournir des mécanismes de configuration et de découverte de services.

Notions de base :
- Pod : plus petite unité déployable ;
- Deployment : décrit et maintient un ensemble de Pods ;
- Service : fournit un point d’accès réseau stable ;
- ConfigMap : configuration non sensible ;
- Secret : données sensibles, à protéger selon les bonnes pratiques ;
- Namespace : séparation logique de ressources.

« Kubernetes ne transforme pas automatiquement une mauvaise application en application résiliente. Il fournit des mécanismes ; il faut les configurer, tester et superviser correctement. »

## 6.6 Exemple de chaîne d’outils

| Besoin | Exemples d’outils | Résultat attendu |
|---|---|---|
| Gestion de versions | Git, GitLab, GitHub | Historique et collaboration |
| CI/CD | Jenkins, GitLab CI, GitHub Actions | Pipeline automatisé |
| Build | Maven, Gradle, npm | Artefact applicatif |
| Qualité | SonarQube | Analyse du code |
| Sécurité | Trivy, scanners de dépendances | Détection de vulnérabilités |
| Conteneurs | Docker, Podman | Image exécutable |
| Registry | Harbor, GitLab Registry | Stockage des images |
| Provisionnement | Terraform | Infrastructure déclarée |
| Configuration | Ansible | Systèmes configurés |
| Orchestration | Kubernetes | Exécution et orchestration |
| Déploiement GitOps | Argo CD, Flux | Synchronisation depuis Git |
| Monitoring | Prometheus, Grafana | Métriques et tableaux de bord |
| Logs | Elastic Stack / OpenSearch | Recherche et analyse des événements |
| Collaboration | Teams, Slack, Mattermost | Communication et notifications |

Préciser : les outils sont des exemples, pas une liste obligatoire. Une chaîne cohérente et maîtrisée vaut mieux qu’un empilement de produits.

## 6.7 Démonstration — du commit à l’exécution

[FORMATEUR] Présenter le scénario suivant, en partage d’écran ou avec des captures :

1. Un développeur modifie une fonctionnalité.
2. Il crée un commit Git.
3. Le dépôt déclenche un pipeline.
4. Le pipeline compile et exécute les tests.
5. Une analyse qualité et sécurité est réalisée.
6. Une image de conteneur est construite.
7. L’image est publiée dans un registry.
8. Le déploiement en environnement de test est lancé.
9. Les tests de validation s’exécutent.
10. Après validation, la version est promue vers la production.
11. Les métriques, logs et alertes permettent de vérifier le fonctionnement.

Phrase à répéter :
« Le pipeline transporte un changement contrôlé à travers des étapes de vérification. Il ne doit pas être considéré comme une simple suite de commandes. Il matérialise une politique de qualité, de sécurité et de livraison. »

## 6.8 Gestion des artefacts et promotion

Un artefact est un résultat produit par le processus de build : binaire, archive, package ou image de conteneur.

Bonne pratique :
- construire une version identifiable ;
- conserver les résultats de tests ;
- publier l’artefact dans un dépôt adapté ;
- promouvoir le même artefact entre les environnements ;
- ne pas reconstruire arbitrairement une version différente pour la production ;
- associer les versions au commit et aux informations de build.

## 6.9 Stratégies de déploiement

- **Recreate :** arrêter l’ancienne version puis démarrer la nouvelle ; simple mais peut provoquer une interruption.
- **Rolling update :** remplacer progressivement les instances.
- **Blue/Green :** maintenir deux environnements et basculer le trafic après validation.
- **Canary :** exposer progressivement une petite partie du trafic à la nouvelle version.

Le choix dépend du risque, de l’architecture, de la capacité de retour arrière et des exigences de disponibilité.

## 6.10 Rollback et résilience

Rollback : retour à une version ou configuration précédente connue comme stable.

Un rollback doit être préparé et testé. Il ne suffit pas de dire « on reviendra en arrière ». Il faut connaître :
- la version précédente ;
- les changements de configuration ;
- les éventuelles migrations de base de données ;
- la compatibilité des données ;
- la procédure de retour ;
- les critères qui déclenchent le rollback.

Autres pratiques :
- sauvegardes vérifiées ;
- redondance ;
- health checks ;
- limitation de l’impact ;
- procédures de reprise ;
- tests de résilience.

## 6.11 ChatOps

ChatOps consiste à intégrer des informations ou actions opérationnelles dans un outil de communication d’équipe.

Exemples :
- notification d’un pipeline ;
- alerte de supervision ;
- consultation du statut d’un déploiement ;
- lancement contrôlé d’une opération ;
- partage d’un lien vers un incident.

Précautions :
- authentification ;
- autorisations ;
- journalisation ;
- validation des actions sensibles ;
- éviter de publier des secrets dans les conversations.

## 6.12 IA et automatisation

L’intelligence artificielle peut assister :
- l’analyse de logs ;
- la génération de tests ;
- la documentation ;
- la recherche de causes possibles ;
- l’analyse de tendances ;
- l’assistance au développement.

Mais :
- les résultats doivent être vérifiés ;
- les données sensibles ne doivent pas être envoyées dans un service non autorisé ;
- l’IA ne remplace pas la responsabilité humaine ;
- les suggestions ne doivent pas être exécutées en production sans contrôles adaptés.

## 6.13 Atelier — dessiner sa toolchain

Durée : 25 minutes.

Consigne :
« En groupe, dessinez une chaîne d’outils pour ShopEasy. Vous devez couvrir le code, les tests, la sécurité, le packaging, le déploiement et le monitoring. Pour chaque outil ou famille d’outils, indiquez le besoin couvert, l’entrée, la sortie et le feedback obtenu. Vous pouvez choisir les outils que vous connaissez. »

Livrable :
- un schéma de chaîne ;
- les points de contrôle ;
- les artefacts ;
- les retours vers l’équipe ;
- un risque et une mesure de maîtrise.

Débrief :
- L’outil choisi répond-il à un besoin précis ?
- Où se trouvent les contrôles qualité et sécurité ?
- Comment tracer la version déployée ?
- Comment détecter une anomalie ?
- Comment revenir à une version stable ?

---

# 7. Mesure, métriques et reporting

## 7.1 Pourquoi mesurer ?

« Sans mesure, nous risquons de confondre activité et résultat. Le nombre de commits, de tickets ou de déploiements ne suffit pas à démontrer que le service apporte davantage de valeur. »

Les métriques doivent aider à :
- comprendre le flux ;
- détecter les blocages ;
- évaluer la qualité ;
- mesurer la stabilité ;
- améliorer la collaboration ;
- prendre des décisions.

Éviter les métriques utilisées pour surveiller ou classer individuellement les personnes. Elles doivent servir à améliorer le système, pas à créer des comportements artificiels.

## 7.2 Les quatre métriques DORA

Les quatre métriques historiques DORA fréquemment présentées sont :

1. **Deployment Frequency** : fréquence des déploiements en production.
2. **Lead Time for Changes** : temps entre le changement engagé dans le processus et sa mise en production, selon la définition retenue.
3. **Change Failure Rate** : proportion des changements qui provoquent un incident ou nécessitent une correction urgente.
4. **Time to Restore Service** : temps nécessaire pour rétablir le service après une dégradation ou un incident.

Certaines publications récentes utilisent le terme **Failed Deployment Recovery Time** et font évoluer les définitions. Pour l’examen, se référer aux termes et définitions du support officiel fourni.

Message clé : les métriques doivent être considérées ensemble. Augmenter la fréquence de déploiement sans maîtriser le taux d’échec et la récupération n’est pas une amélioration globale.

## 7.3 Exemple chiffré

Une équipe réalise sur un mois :
- 20 déploiements en production ;
- 3 changements ayant provoqué un incident ;
- 2 heures en moyenne pour restaurer le service après un incident ;
- un délai médian de 2 jours entre le changement et sa mise en production.

Calcul du Change Failure Rate :
3 changements problématiques / 20 changements déployés × 100 = **15 %**.

Interprétation :
- 20 déploiements donnent une indication de fréquence ;
- 15 % de changements défaillants invite à analyser les causes ;
- 2 heures de restauration donnent une indication de capacité de récupération ;
- 2 jours de délai renseignent sur le flux de livraison.

Ne pas conclure qu’une équipe est performante uniquement parce qu’elle déploie souvent.

## 7.4 Autres indicateurs

Qualité :
- taux de tests réussis ;
- défauts détectés après livraison ;
- couverture de tests (à interpréter avec prudence) ;
- vulnérabilités ouvertes selon leur criticité et ancienneté.

Stabilité :
- disponibilité ;
- taux d’erreur ;
- latence ;
- incidents ;
- temps de restauration.

Flux :
- Lead Time ;
- Cycle Time ;
- temps d’attente ;
- WIP ;
- débit (throughput).

Valeur :
- adoption d’une fonctionnalité ;
- satisfaction utilisateur ;
- réduction d’un temps de traitement ;
- diminution des demandes au support ;
- impact sur un objectif métier.

Culture et collaboration :
- partage des connaissances ;
- qualité des rétrospectives ;
- perception des obstacles ;
- autonomie des équipes ;
- satisfaction vis-à-vis de la plateforme interne.

## 7.5 Monitoring et Observability

**Monitoring** : collecte et suivi de signaux définis pour savoir si un système fonctionne et détecter des situations connues.

**Observability** : capacité à comprendre l’état interne d’un système à partir des données qu’il produit.

Trois grandes catégories de signaux :
- **Metrics** : mesures numériques dans le temps (CPU, mémoire, taux d’erreur, latence).
- **Logs** : événements horodatés décrivant ce qui s’est passé.
- **Traces** : suivi du parcours d’une requête à travers plusieurs composants.

Exemple :
Un utilisateur signale que la commande est lente.
- les métriques indiquent une augmentation de la latence ;
- les traces montrent que le service de paiement prend 4 secondes ;
- les logs détaillent une erreur de connexion à une dépendance.

« Un tableau de bord ne doit pas être décoratif. Il doit aider à répondre à une question opérationnelle ou métier et permettre de prendre une décision. »

## 7.6 AIOps

AIOps applique des techniques d’intelligence artificielle et d’analyse avancée aux opérations IT : corrélation d’événements, détection d’anomalies, analyse de tendances et aide à la priorisation.

Limites :
- qualité et cohérence des données ;
- faux positifs ;
- explicabilité ;
- dépendance aux modèles ;
- nécessité de validation humaine pour les actions à risque.

## 7.7 Construire un tableau de bord utile

Un tableau de bord de service peut contenir :
- disponibilité et SLO ;
- taux d’erreur ;
- latence ;
- volume de requêtes ;
- incidents en cours ;
- fréquence de déploiement ;
- taux de changements défaillants ;
- temps de restauration ;
- état des pipelines.

Chaque indicateur doit avoir :
- un nom clair ;
- une définition ;
- une source ;
- une période ;
- un seuil ou objectif si pertinent ;
- un responsable de l’interprétation ;
- une action possible en cas d’écart.

## 7.8 Atelier — interpréter des métriques

Durée : 20 minutes.

Situation A :
- fréquence de déploiement : en hausse ;
- taux de changements défaillants : en hausse ;
- temps de restauration : stable.

Situation B :
- fréquence de déploiement : stable ;
- taux de changements défaillants : en baisse ;
- délai de livraison : en baisse.

Questions :
1. Quelle situation montre le progrès le plus équilibré ?
2. Quelles données supplémentaires demanderiez-vous ?
3. Quelles actions proposeriez-vous ?

Correction indicative :
- A montre une accélération accompagnée d’une dégradation de la qualité ; il faut analyser les causes.
- B semble montrer une amélioration plus équilibrée, mais il faut vérifier la valeur livrée, le périmètre, la satisfaction et la fiabilité.
- Toujours examiner les tendances, les définitions et le contexte.

---

# 8. Partager, accompagner et faire évoluer la démarche

## 8.1 DevOps à l’échelle de l’entreprise

« Une expérimentation réussie dans une équipe ne signifie pas que l’ensemble de l’organisation peut adopter exactement les mêmes pratiques sans adaptation. Le passage à l’échelle demande de travailler sur la culture, l’architecture, les compétences, la gouvernance, les plateformes et les modes de financement. »

Éléments clés :
- soutien visible du management ;
- objectifs communs ;
- vision orientée valeur ;
- implication des équipes ;
- formation et accompagnement ;
- plateformes et standards partagés ;
- mesure des résultats ;
- amélioration progressive.

## 8.2 Rôles et responsabilités

Les rôles peuvent varier selon l’organisation, mais on retrouve souvent :
- Product Owner / responsable produit : priorise la valeur et les besoins ;
- développeurs : conçoivent et réalisent le logiciel ;
- QA / testeurs : contribuent à la stratégie de qualité et aux tests ;
- opérations / SRE : contribuent à la fiabilité et à l’exploitabilité ;
- sécurité : définit les exigences et accompagne leur intégration ;
- plateforme : fournit des capacités techniques communes ;
- management / leadership : donne la direction, supprime les obstacles et soutient la culture.

L’objectif n’est pas de figer les personnes dans des frontières rigides. Les responsabilités doivent être explicites et coordonnées.

## 8.3 Leadership DevOps

Le leadership doit :
- expliquer le « pourquoi » ;
- donner des objectifs communs ;
- encourager la collaboration ;
- rendre les problèmes visibles ;
- protéger le temps d’amélioration ;
- soutenir l’apprentissage ;
- traiter les obstacles organisationnels ;
- valoriser les résultats collectifs plutôt que les silos.

## 8.4 Difficultés et risques d’adoption

Risques fréquents :
- croire que DevOps est un projet d’outillage ;
- imposer une organisation sans expliquer le sens ;
- automatiser un processus inefficace ;
- négliger la sécurité ;
- mesurer uniquement la vitesse ;
- créer une équipe DevOps isolée ;
- lancer trop de changements simultanément ;
- ne pas former les équipes ;
- manquer de soutien managérial ;
- ne pas traiter la dette technique et culturelle.

Facteurs clés de succès :
- commencer par un problème réel ;
- choisir un périmètre pilote ;
- obtenir un soutien managérial ;
- impliquer les personnes concernées ;
- définir une mesure de départ ;
- améliorer progressivement ;
- partager les résultats ;
- étendre ce qui fonctionne ;
- conserver une démarche d’apprentissage.

## 8.5 Comment démarrer ?

Proposer une démarche en 8 étapes :
1. Comprendre les objectifs métier et les irritants.
2. Cartographier le flux de valeur.
3. Identifier le principal goulot d’étranglement.
4. Définir une équipe pilote et un service représentatif.
5. Choisir quelques pratiques prioritaires.
6. Automatiser progressivement les contrôles répétitifs.
7. Mesurer avant/après et recueillir les retours.
8. Apprendre, ajuster et étendre.

« Il vaut mieux réussir une amélioration concrète de bout en bout que lancer dix chantiers simultanés sans résultat mesurable. »

## 8.6 Atelier final — construire une démarche DevOps

Durée : 45 minutes.

Contexte :
« ShopEasy est une application de commande. Les mises en production sont rares et stressantes. Les équipes découvrent parfois les problèmes de configuration au dernier moment. Les tests sont principalement manuels. Les incidents sont traités par l’exploitation, qui ne participe pas toujours aux décisions de conception. Le management souhaite réduire le délai de livraison sans augmenter les incidents. »

Travail en groupes :
1. Identifier trois problèmes.
2. Cartographier le flux actuel.
3. Identifier le goulot d’étranglement principal.
4. Proposer trois pratiques DevOps prioritaires.
5. Proposer une chaîne d’outils possible.
6. Définir quatre métriques.
7. Définir une première expérimentation sur 30 jours.
8. Identifier les risques et les moyens de les limiter.

Restitution : 3 minutes par groupe.

Grille de correction :
- problèmes reliés à des faits du scénario ;
- démarche orientée valeur ;
- prise en compte de Flow, Feedback et Learning ;
- tests et sécurité intégrés tôt ;
- automatisation pertinente ;
- supervision et feedback après livraison ;
- métriques équilibrées ;
- plan progressif et réaliste.

Exemple de proposition :
- versionner code et configuration ;
- intégrer des tests automatiques dans le pipeline ;
- automatiser le déploiement en environnement de test ;
- réaliser une validation de sécurité précoce ;
- ajouter des tests de santé et des alertes ;
- documenter un rollback ;
- mesurer Lead Time, fréquence de déploiement, taux d’échec et temps de restauration.

---

# 9. Préparation à l’examen DevOps Foundation

## 9.1 Présentation de l’examen

Selon la page officielle PeopleCert consultée pour DevOps Foundation :
- 40 questions ;
- questions à choix multiples ;
- durée : 60 minutes ;
- seuil de réussite : 65 % ;
- examen open book ;
- disponibilité en plusieurs langues, dont le français ;
- renouvellement de la certification tous les trois ans selon les modalités PeopleCert.

Vérifier les conditions applicables au voucher, à la session et au kit de formation au moment de l’inscription. Les règles administratives peuvent évoluer.

## 9.2 Domaines à réviser

Le périmètre officiel présente huit grands domaines :
1. Exploring DevOps.
2. Core DevOps Principles.
3. Key DevOps Practices.
4. Business and Technology Frameworks.
5. Culture, Behaviors and Operating Models.
6. Automation and Architecting DevOps Toolchains.
7. Measurement, Metrics and Reporting.
8. Sharing, Shadowing and Evolving.

Les thèmes mis en avant comprennent notamment les Three Ways, Theory of Constraints, Chaos Engineering, Learning Organisations, Continuous Testing, Integration, Delivery, Deployment, SRE, Resilience Engineering, DevSecOps, ChatOps, Monitoring, Observability, Value Stream Management, Platform Engineering, CI/CD, IaC, Cloud, Containers, Microservices, métriques et adoption à l’échelle.

## 9.3 Conseils de préparation

- Comprendre les définitions, pas seulement mémoriser les acronymes.
- Savoir distinguer les concepts proches : CI/CD, Delivery/Deployment, SLI/SLO/SLA, Monitoring/Observability.
- Lire attentivement les mots « principalement », « toujours », « uniquement » et « meilleur choix ».
- Éliminer les réponses qui réduisent DevOps à un outil ou à une équipe.
- Relier chaque question à un objectif : flux, feedback, apprentissage, valeur, qualité ou fiabilité.
- En open book, connaître l’organisation du support. Le temps reste limité : ne pas chercher chaque réponse depuis zéro.
- Se référer en priorité au support officiel et au blueprint correspondant à la version de l’examen passée.

## 9.4 Mini-examen blanc — 20 questions

**Consigne :** une seule meilleure réponse par question. Laisser 15 à 20 minutes, puis corriger en expliquant le raisonnement.

### Question 1
Quel est l’objectif principal de DevOps ?

A. Remplacer les équipes d’exploitation par des développeurs.  
B. Améliorer la collaboration et le flux de valeur afin de livrer des services de qualité plus rapidement et plus fiablement.  
C. Installer une plateforme Kubernetes dans chaque entreprise.  
D. Supprimer tous les contrôles avant production.

**Réponse : B.** DevOps est une démarche culturelle, organisationnelle et technique orientée valeur, collaboration, qualité et fiabilité.

### Question 2
DevOps est-il principalement un outil ?

A. Oui, un outil CI/CD.  
B. Oui, une plateforme de conteneurs.  
C. Non, c’est une approche combinant culture, pratiques, processus et automatisation.  
D. Oui, un système de ticketing.

**Réponse : C.**

### Question 3
Quelle est la première voie des Three Ways ?

A. Continual Learning.  
B. Feedback.  
C. Flow.  
D. Governance.

**Réponse : C.** La première voie vise le flux de valeur de bout en bout.

### Question 4
Quel est l’objectif de la deuxième voie ?

A. Augmenter les validations manuelles.  
B. Accélérer et amplifier les boucles de feedback.  
C. Réduire la communication.  
D. Limiter les tests.

**Réponse : B.**

### Question 5
La troisième voie met l’accent sur :

A. L’apprentissage et l’expérimentation continus.  
B. La réduction des équipes.  
C. Le gel des changements.  
D. Le remplacement de la supervision.

**Réponse : A.**

### Question 6
Que signifie WIP ?

A. Work In Production.  
B. Work In Progress.  
C. Workflow Integration Process.  
D. Web Infrastructure Platform.

**Réponse : B.** Il s’agit du travail commencé mais non terminé.

### Question 7
Quel est l’objectif de la Theory of Constraints ?

A. Ajouter des étapes de validation.  
B. Identifier et traiter la contrainte qui limite le système.  
C. Mesurer uniquement les coûts.  
D. Éliminer les tests.

**Réponse : B.**

### Question 8
Quelle affirmation décrit le mieux Chaos Engineering ?

A. Arrêter des systèmes au hasard.  
B. Tester de manière contrôlée la résilience en introduisant des défaillances planifiées.  
C. Supprimer les mécanismes de reprise.  
D. Tester uniquement le code source.

**Réponse : B.**

### Question 9
Quelle est la différence entre Continuous Delivery et Continuous Deployment ?

A. Il n’y en a aucune.  
B. Continuous Delivery maintient le logiciel prêt à être déployé ; Continuous Deployment automatise aussi le déploiement en production après les contrôles.  
C. Continuous Deployment ne comporte pas de tests.  
D. Continuous Delivery concerne uniquement les tests unitaires.

**Réponse : B.**

### Question 10
Quel est le rôle principal de l’intégration continue ?

A. Intégrer fréquemment les changements et exécuter des vérifications automatiques.  
B. Déployer manuellement une fois par an.  
C. Remplacer Git.  
D. Supprimer les revues de code.

**Réponse : A.**

### Question 11
Que signifie Shift Left ?

A. Déplacer les contrôles vers les premières étapes du cycle de développement.  
B. Reporter les tests à la fin.  
C. Supprimer les contrôles de sécurité.  
D. Déplacer l’application vers un autre serveur.

**Réponse : A.**

### Question 12
Quelle affirmation sur DevOps et ITSM est la plus juste ?

A. Ils sont incompatibles.  
B. DevOps supprime la gestion des incidents.  
C. Ils peuvent être complémentaires pour fournir et améliorer des services fiables.  
D. ITSM concerne uniquement le développement.

**Réponse : C.**

### Question 13
Que mesure un SLI ?

A. Un indicateur réel d’un aspect du service.  
B. Un engagement contractuel.  
C. Une cible de niveau de service.  
D. Un budget financier.

**Réponse : A.**

### Question 14
Que représente un SLO ?

A. Une mesure brute sans objectif.  
B. Un objectif de niveau de service.  
C. Un contrat fournisseur.  
D. Un outil de déploiement.

**Réponse : B.**

### Question 15
Qu’est-ce qu’un Error Budget ?

A. Le budget annuel des équipes.  
B. La marge d’erreur acceptable associée à un objectif de fiabilité.  
C. Le coût des erreurs de programmation.  
D. Le temps réservé aux réunions.

**Réponse : B.**

### Question 16
Quel est le rôle de l’Infrastructure as Code ?

A. Décrire et gérer l’infrastructure à l’aide de fichiers versionnés et automatisables.  
B. Écrire uniquement la documentation utilisateur.  
C. Remplacer tous les tests.  
D. Installer un IDE.

**Réponse : A.**

### Question 17
Quelle est la différence entre une image et un conteneur ?

A. Une image est un modèle ; un conteneur est une instance exécutée à partir de ce modèle.  
B. Un conteneur est un modèle et une image un serveur physique.  
C. Ce sont toujours des synonymes.  
D. Une image est uniquement un fichier de log.

**Réponse : A.**

### Question 18
Quel est l’objectif de l’observabilité ?

A. Afficher uniquement la consommation CPU.  
B. Comprendre l’état interne d’un système à partir des signaux qu’il produit.  
C. Remplacer les tests.  
D. Éviter la collecte de logs.

**Réponse : B.**

### Question 19
Pourquoi utiliser une culture sans recherche de coupable après un incident ?

A. Pour ne jamais attribuer de responsabilités.  
B. Pour éviter toute analyse.  
C. Pour comprendre les conditions systémiques et améliorer la prévention.  
D. Pour cacher l’incident.

**Réponse : C.**

### Question 20
Quelle est une bonne première étape pour démarrer une démarche DevOps ?

A. Acheter tous les outils du marché.  
B. Recruter une équipe appelée DevOps sans changer les processus.  
C. Comprendre les objectifs métier, les irritants et le flux de valeur actuel.  
D. Déployer Kubernetes immédiatement.

**Réponse : C.**

## 9.5 Barème indicatif du quiz

- 18 à 20 bonnes réponses : très bonne compréhension des fondamentaux.
- 15 à 17 : bonne base, revoir les distinctions entre notions.
- 12 à 14 : revoir les principes et les pratiques clés.
- Moins de 12 : reprendre les définitions et refaire le quiz après révision.

Ce quiz est pédagogique et ne constitue pas une reproduction de l’examen officiel.

---

# 10. Glossaire essentiel

| Terme | Définition courte |
|---|---|
| Agile | Approche itérative et adaptative centrée sur la valeur et la collaboration |
| AIOps | Usage de l’IA et de l’analyse avancée pour assister les opérations IT |
| Artifact | Résultat produit par un build |
| Blue/Green | Stratégie avec deux environnements et bascule du trafic |
| Canary | Déploiement progressif sur une partie du trafic |
| CI | Intégration fréquente avec vérifications automatisées |
| CD | Livraison continue ou déploiement continu selon le contexte |
| ChatOps | Intégration d’informations et d’actions opérationnelles dans le chat |
| Container | Unité d’exécution isolée basée sur une image |
| Continuous Deployment | Déploiement automatique en production après validation |
| Continuous Delivery | Logiciel maintenu dans un état déployable |
| Continuous Testing | Tests réalisés tout au long du cycle |
| Culture | Valeurs, comportements et habitudes partagés |
| DevSecOps | Intégration de la sécurité dans le cycle de livraison |
| DORA | Programme de recherche et ensemble de métriques sur la performance de livraison logicielle |
| IaC | Infrastructure as Code |
| ITSM | Gestion des services informatiques |
| Lead Time | Temps total selon des bornes de mesure définies |
| Lean | Approche visant la valeur et la réduction des gaspillages |
| Microservices | Architecture composée de services relativement autonomes |
| Monitoring | Suivi de signaux et détection de situations connues |
| Observability | Capacité à comprendre l’état d’un système à partir de ses sorties |
| Pipeline | Chaîne automatisée d’étapes de vérification et de livraison |
| Platform Engineering | Conception d’une plateforme interne destinée à faciliter le travail des équipes |
| SLI | Service Level Indicator |
| SLA | Service Level Agreement |
| SLO | Service Level Objective |
| SRE | Site Reliability Engineering |
| Three Ways | Flow, Feedback, Continual Learning and Experimentation |
| TOC | Theory of Constraints |
| VSM | Value Stream Management |
| WIP | Work In Progress |

---

# 11. Conclusion — script de clôture

« Nous arrivons à la fin de ces deux journées. Le message essentiel à retenir est que DevOps n’est pas un produit que l’on installe ni une équipe que l’on crée. C’est une démarche d’amélioration du système de livraison de valeur.

Les trois voies nous donnent une grille de lecture : fluidifier le travail, obtenir du feedback rapidement, apprendre et expérimenter en continu. Les pratiques comme l’intégration continue, les tests continus, la livraison continue, l’automatisation, l’Infrastructure as Code, le monitoring et l’observabilité rendent cette démarche concrète. La culture, la collaboration, la sécurité et la mesure permettent de la rendre durable.

Pour réussir une transformation, commencez par un problème réel, rendez le flux visible, choisissez une amélioration mesurable, impliquez les personnes concernées et apprenez du résultat. Ne cherchez pas à tout automatiser ou à déployer tous les outils en même temps.

Pour votre préparation à DevOps Foundation, révisez les définitions, les distinctions entre concepts proches et surtout la logique derrière chaque pratique. L’objectif n’est pas de réciter une liste d’outils : c’est de comprendre pourquoi une organisation adopte ces pratiques et quels résultats elle cherche à obtenir. Merci pour votre participation. »

---

# 12. Références et vérifications

Références publiques consultées pour construire ce guide :
- PeopleCert — DevOps Foundation : https://www.peoplecert.org/browse-certifications/devops/DevOps-13/devops-foundation-2457
- DevOps Institute — DevOps Foundation : https://www.devopsinstitute.com/certifications/devops-foundation/
- Syllabus DevOps Foundation (document public) : https://www.oxfordcollegeoftechnology.com/wp-content/uploads/2025/02/DevOps-Syllabus.pdf

**Important :** le référentiel, les pondérations, les conditions d’examen et les supports peuvent évoluer. Avant la formation et avant l’examen, vérifier la version du blueprint et les règles publiées par PeopleCert pour la certification effectivement réservée. Les exemples ShopEasy, ateliers, pipelines et questions de ce guide sont originaux et pédagogiques ; ils ne sont pas des questions officielles.
