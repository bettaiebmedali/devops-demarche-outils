# k8s-demo
# 🧑‍🏫 Kubernetes – Cours DevOps Entreprise
## 🎯 Du Pod à l’Ingress (Lab guidé + exercices + corrigés)

---

# 📌 1. Objectifs pédagogiques

À la fin de ce cours, le participant sera capable de :

- Comprendre les objets de base Kubernetes
- Déployer des applications via YAML
- Gérer la scalabilité avec ReplicaSet et Deployment
- Appliquer des Rolling Updates et Rollbacks
- Exposer des services via ClusterIP et Ingress
- Tester la communication inter-pods

---

# 🧱 2. Architecture étudiée

```
Ingress
  ↓
Service (ClusterIP)
  ↓
Deployment
  ↓
ReplicaSet
  ↓
Pods
```

---

# ⚙️ 3. Prérequis

## Outils

- kubectl
- Minikube / K3s / MicroK8s
- Docker

## Initialisation cluster

```bash
minikube start
minikube addons enable ingress
kubectl get nodes
```

---

# 🧪 LAB 1 — Création d’un Pod (CLI)

## 🎯 Objectif

Créer un Pod NGINX rapidement via CLI.

## 🧑‍💻 Commande

```bash
kubectl run nginx-pod --image=nginx:1.25 --port=80
```

## 🔍 Vérification

```bash
kubectl get pods
kubectl describe pod nginx-pod
```

## 🌐 Accès

```bash
kubectl port-forward nginx-pod 8080:80
```

👉 http://localhost:8080

---

## 🧪 Exercice 1

Créer un Pod nommé `web-pod` avec image `httpd`.

### ✔️ Correction

```bash
kubectl run web-pod --image=httpd --port=80
```

---

# 🧪 LAB 2 — Pod via YAML

## 🎯 Objectif

Comprendre la déclaration déclarative Kubernetes.

## 📄 pod.yml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod-yaml
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```

## 🚀 Déploiement

```bash
kubectl apply -f pod.yml
```

---

## 🧪 Exercice 2

Modifier l’image pour `nginx:1.26`.

### ✔️ Correction

```yaml
image: nginx:1.26
```

---

# 🧪 LAB 3 — ReplicaSet

## 🎯 Objectif

Maintenir 3 instances identiques d’un Pod.

## 📄 replicaset.yml

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-rs
  template:
    metadata:
      labels:
        app: nginx-rs
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

## 🚀 Déploiement

```bash
kubectl apply -f replicaset.yml
kubectl get pods
```

---

## 🧪 Exercice 3

Supprimer un pod et observer la recréation automatique.

```bash
kubectl delete pod <pod-name>
```

---

# 🧪 LAB 4 — Deployment + Rolling Update

## 🎯 Objectif

Gérer les mises à jour sans interruption.

## 📄 deployment.yml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: nginx-deploy
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

## 🚀 Déploiement

```bash
kubectl apply -f deployment.yml
```

---

## 🔄 Rolling Update

Modifier :

```yaml
image: nginx:1.26
```

Appliquer :

```bash
kubectl apply -f deployment.yml
kubectl rollout status deployment nginx-deployment
```

---

## ⏪ Rollback

```bash
kubectl rollout undo deployment nginx-deployment
```

---

## 🧪 Exercice 4

Forcer une mise à jour vers `nginx:1.27`.

---

# 🧪 LAB 5 — Service (ClusterIP)

## 🎯 Objectif

Exposer les Pods dans le cluster.

## 📄 service.yml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx-deploy
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

## 🚀 Déploiement

```bash
kubectl apply -f service.yml
kubectl get svc
```

---

## 🧪 Exercice 5

Changer le service en NodePort.

### ✔️ Correction

```yaml
type: NodePort
```

---

# 🧪 LAB 6 — Communication Inter-Pods

## 🎯 Objectif

Tester DNS interne Kubernetes.

## 🧑‍💻 Client temporaire

```bash
kubectl run client --image=busybox -it --rm -- sh
```

## 📡 Test

```bash
wget -O- http://nginx-service
```

---

## 🧪 Exercice 6

Tester `nslookup nginx-service`.

---

# 🧪 LAB 7 — Ingress

## 🎯 Objectif

Exposer une application vers l’extérieur.

## ⚙️ Activation

```bash
minikube addons enable ingress
```

---

## 📄 ingress.yml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
    - host: nginx.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

## 🚀 Déploiement

```bash
kubectl apply -f ingress.yml
minikube ip
```

---

## 🌐 Configuration

Ajouter :

```
<MINIKUBE_IP> nginx.local
```

Accès :

```
http://nginx.local
```

---

## 🧪 Exercice 7

Créer un second service et router via `/app2`.

---

# 📊 8. Résumé pédagogique

| Objet | Rôle |
|------|------|
| Pod | Instance d’application |
| ReplicaSet | Réplication |
| Deployment | Gestion versionnée |
| Service | Exposition interne |
| Ingress | Exposition externe |

---

# 🧹 9. Cleanup

```bash
kubectl delete -f .
```

---

# 🧪 10. Exercices avancés (niveau entreprise)

- Ajouter ConfigMap
- Ajouter Secrets
- Ajouter probes (liveness/readiness)
- Ajouter autoscaling (HPA)
- Déployer 2 applications + routing Ingress path-based
- Transformer en Helm Chart
- Ajouter pipeline GitLab CI/CD

---

# 🎓 Fin du cours