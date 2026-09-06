# Docker Labs

## Prerequisites

Before starting the labs, make sure Docker is installed and working:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

The labs are designed to work with:

- Ubuntu / Linux
- WSL2
- Docker Desktop
- Docker Engine

---

# Lab 1 — Basic Container Management

## Objective

Learn how to manage Docker containers using the main Docker commands.

## 1. Launch an Interactive Container

Start an Ubuntu container interactively:

```bash
docker run -it --name my-ubuntu ubuntu bash
```

Inside the container:

```bash
cat /etc/os-release
hostname
whoami
```

Exit the container:

```bash
exit
```

## 2. Check Running Containers

```bash
docker ps
```

Display all containers, including stopped containers:

```bash
docker ps -a
```

## 3. View Logs of a Container

Start an Nginx container:

```bash
docker run -d --name nginx-container -p 8080:80 nginx
```

Check the container:

```bash
docker ps
```

View logs:

```bash
docker logs nginx-container
```

Open:

```text
http://localhost:8080
```

Follow logs in real time:

```bash
docker logs -f nginx-container
```

## 4. Inspect a Container

```bash
docker inspect nginx-container
```

Try to identify:

- Container IP address
- Network
- Mounted volumes
- Environment variables
- Port mappings
- Container state

## 5. Execute a Command Inside a Container

```bash
docker exec nginx-container nginx -v
```

Open a shell:

```bash
docker exec -it nginx-container bash
```

Check the filesystem:

```bash
ls -la /usr/share/nginx/html
```

Exit:

```bash
exit
```

## 6. Stop, Restart and Kill a Container

```bash
docker stop nginx-container
```

Start it again:

```bash
docker start nginx-container
```

Restart it:

```bash
docker restart nginx-container
```

Forcefully stop it:

```bash
docker kill nginx-container
```

## 7. Remove a Container

```bash
docker rm nginx-container
```

If the container is still running:

```bash
docker rm -f nginx-container
```

## Verification

```bash
docker ps -a
```

The `nginx-container` container should no longer exist.

## Challenge

Create a container named `web-test` using Nginx and expose it on port `8090`.

Requirements:

- Container name: `web-test`
- Image: `nginx`
- Host port: `8090`
- Verify that Nginx is accessible
- Display its logs
- Inspect the container
- Stop and remove it

---

# Lab 2 — Image and Dockerfile Management

## Objective

Learn how to create custom Docker images using a Dockerfile.

## 1. Create the Project

```bash
mkdir docker-lab2
cd docker-lab2
```

## 2. Create a Dockerfile

Create a file named `Dockerfile`:

```dockerfile
FROM alpine:latest

RUN apk add --no-cache python3

CMD ["python3", "--version"]
```

## 3. Build the Image

```bash
docker build -t my-python-alpine .
```

## 4. List Images

```bash
docker images
```

## 5. Launch a Container

```bash
docker run --name python-container my-python-alpine
```

## 6. Inspect the Image

```bash
docker inspect my-python-alpine
```

## 7. Display Image History

```bash
docker history my-python-alpine
```

This command allows you to see the different layers created during the image build.

## Verification

```bash
docker run --rm my-python-alpine
```

Expected result:

```text
Python 3.x.x
```

## Cleanup

```bash
docker rm python-container
docker rmi my-python-alpine
```

---

# Lab 3 — Volume Management

## Objective

Learn how Docker volumes provide persistent storage.

## 1. Create a Volume

```bash
docker volume create my-volume
```

## 2. Inspect the Volume

```bash
docker volume inspect my-volume
```

## 3. Mount the Volume to Nginx

```bash
docker run -d \
  -p 8080:80 \
  --name nginx-volume \
  --mount source=my-volume,target=/usr/share/nginx/html \
  nginx
```

## 4. Create Web Content

```bash
docker exec nginx-volume sh -c \
'echo "<h1>Hello, Docker Volume</h1>" > /usr/share/nginx/html/index.html'
```

Open:

```text
http://localhost:8080
```

## 5. Verify Persistence

Remove the container:

```bash
docker rm -f nginx-volume
```

Create another container using the same volume:

```bash
docker run -d \
  -p 8080:80 \
  --name nginx-volume2 \
  --mount source=my-volume,target=/usr/share/nginx/html \
  nginx
```

Open:

```text
http://localhost:8080
```

The previous page should still be available.

## Verification

```bash
docker volume inspect my-volume
```

## Cleanup

```bash
docker rm -f nginx-volume2
docker volume rm my-volume
```

## Challenge

Create a volume called `website-data` and use it with an Nginx container.

The HTML page must survive container deletion and recreation.

---

# Lab 4 — Docker Network Management

## Objective

Learn how containers communicate using Docker networks.

## 1. Create a Network

```bash
docker network create my-network
```

## 2. Launch MySQL

```bash
docker run -d \
  --name db \
  --network my-network \
  -e MYSQL_ROOT_PASSWORD=root \
  mysql
```

## 3. Launch phpMyAdmin

```bash
docker run -d \
  --name pma \
  --network my-network \
  -p 8081:80 \
  -e PMA_HOST=db \
  phpmyadmin/phpmyadmin
```

## 4. Access phpMyAdmin

Open:

```text
http://localhost:8081
```

Use:

```text
Server: db
Username: root
Password: root
```

## 5. Inspect the Network

```bash
docker network inspect my-network
```

## 6. Test DNS Resolution

Enter the phpMyAdmin container:

```bash
docker exec -it pma sh
```

Depending on the image, networking utilities may not be installed.

The important concept is that Docker provides internal DNS resolution, allowing the service to be reached by its container name:

```text
db
```

## Cleanup

```bash
docker rm -f pma db
docker network rm my-network
```

---

# Lab 5 — Docker Compose

## Objective

Automate the deployment of multiple containers using Docker Compose.

## 1. Create the Project

```bash
mkdir docker-compose-lab
cd docker-compose-lab
```

## 2. Create compose.yaml

```yaml
services:

  db:
    image: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - my-network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8080:80"
    environment:
      PMA_HOST: db
    networks:
      - my-network

volumes:
  db_data:

networks:
  my-network:
```

## 3. Start the Application

```bash
docker compose up -d
```

## 4. Check Services

```bash
docker compose ps
```

## 5. Display Logs

```bash
docker compose logs
```

For a specific service:

```bash
docker compose logs db
```

Follow logs:

```bash
docker compose logs -f
```

## 6. Stop the Application

```bash
docker compose down
```

## 7. Remove Volumes

```bash
docker compose down -v
```

## Challenge

Modify the Compose application to:

- change the host port
- add a persistent volume
- add a custom network
- configure phpMyAdmin using `PMA_HOST`
- verify communication between the two services

---

# Lab 6 — Advanced Dockerfile

## Objective

Build a custom web application image using advanced Dockerfile instructions.

## Scenario

You are developing a small Python web application that must be packaged into a Docker image.

## 1. Create the Project

```bash
mkdir docker-python-app
cd docker-python-app
```

## 2. Create app.py

```python
from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        message = os.getenv("APP_MESSAGE", "Hello from Docker")

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()

        response = f"""
        <html>
            <body>
                <h1>{message}</h1>
                <p>Application running inside Docker</p>
            </body>
        </html>
        """

        self.wfile.write(response.encode())

server = HTTPServer(("0.0.0.0", 8000), Handler)

print("Server listening on port 8000")

server.serve_forever()
```

## 3. Create the Dockerfile

```dockerfile
FROM python:3.12-alpine

WORKDIR /app

ENV APP_MESSAGE="Hello from Docker"

COPY app.py .

EXPOSE 8000

CMD ["python", "app.py"]
```

## 4. Create .dockerignore

```text
.git
.gitignore
__pycache__
*.pyc
README.md
```

## 5. Build the Image

```bash
docker build -t docker-python-app .
```

## 6. Run the Application

```bash
docker run -d \
  --name python-web \
  -p 8000:8000 \
  docker-python-app
```

Open:

```text
http://localhost:8000
```

## 7. Override the Environment Variable

```bash
docker rm -f python-web
```

```bash
docker run -d \
  --name python-web \
  -p 8000:8000 \
  -e APP_MESSAGE="Hello from DevOps Training" \
  docker-python-app
```

## Verification

```bash
docker logs python-web
```

```bash
curl http://localhost:8000
```

## Challenge

Modify the application so that it displays:

- application name
- hostname of the container
- environment name
- current application version

Use Docker environment variables to configure these values.

## Cleanup

```bash
docker rm -f python-web
docker rmi docker-python-app
```

---

# Lab 7 — Multi-stage Docker Build

## Objective

Understand how multi-stage builds reduce Docker image size.

## Scenario

You have a Node.js application. The application requires Node.js during the build phase, but the final runtime should contain only the generated static files.

## 1. Create the Project

```bash
mkdir docker-multistage
cd docker-multistage
```

Create `package.json`:

```json
{
  "scripts": {
    "build": "mkdir -p dist && echo '<h1>Hello from Multi-stage Docker</h1>' > dist/index.html"
  }
}
```

## 2. Create the Dockerfile

```dockerfile
FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json .

RUN npm run build


FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
```

## 3. Build

```bash
docker build -t multistage-demo .
```

## 4. Run

```bash
docker run -d \
  --name multistage-web \
  -p 8080:80 \
  multistage-demo
```

Open:

```text
http://localhost:8080
```

## 5. Inspect Image Size

```bash
docker images multistage-demo
```

## Challenge

Create a second Dockerfile without multi-stage builds.

Build both images and compare:

```bash
docker images
```

Explain why the multi-stage image is smaller.

## Cleanup

```bash
docker rm -f multistage-web
docker rmi multistage-demo
```

---

# Lab 8 — Advanced Docker Networking

## Objective

Understand network isolation and communication between containers.

## Scenario

You have three components:

```text
Frontend
   |
   v
Backend
   |
   v
Database
```

The frontend must communicate with the backend.

The backend must communicate with the database.

The frontend should not directly access the database.

## 1. Create Two Networks

```bash
docker network create frontend-network
```

```bash
docker network create backend-network
```

## 2. Create a Database

```bash
docker run -d \
  --name database \
  --network backend-network \
  -e MYSQL_ROOT_PASSWORD=root \
  mysql
```

## 3. Create a Backend Container

```bash
docker run -d \
  --name backend \
  --network backend-network \
  nginx
```

Connect the backend to the frontend network:

```bash
docker network connect frontend-network backend
```

The backend now belongs to two networks.

## 4. Create a Frontend

```bash
docker run -d \
  --name frontend \
  --network frontend-network \
  nginx
```

## 5. Inspect Networks

```bash
docker network inspect frontend-network
```

```bash
docker network inspect backend-network
```

Architecture:

```text
frontend
   |
frontend-network
   |
backend
   |
backend-network
   |
database
```

## Verification

Check network membership:

```bash
docker inspect frontend
```

```bash
docker inspect backend
```

```bash
docker inspect database
```

## Challenge

Modify the architecture so that:

- frontend cannot access database
- backend can access database
- frontend can access backend
- backend belongs to both networks

Explain why Docker's network isolation provides this architecture.

## Cleanup

```bash
docker rm -f frontend backend database
docker network rm frontend-network backend-network
```

---

# Lab 9 — Advanced Docker Compose

## Objective

Deploy a complete multi-service application using Docker Compose.

## Architecture

```text
                  +-------------+
                  |   Nginx     |
                  |  Frontend   |
                  +------+------+
                         |
                         v
                  +-------------+
                  |   Backend   |
                  +------+------+
                         |
                         v
                  +-------------+
                  |   MySQL     |
                  +-------------+
```

## 1. Create the Project

```bash
mkdir compose-advanced
cd compose-advanced
```

## 2. Create .env

```text
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=application
APP_PORT=8080
```

## 3. Create compose.yaml

```yaml
services:

  db:
    image: mysql:8.4
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - backend-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: nginx:alpine
    networks:
      - frontend-network
      - backend-network
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

  frontend:
    image: nginx:alpine
    ports:
      - "${APP_PORT}:80"
    networks:
      - frontend-network
    depends_on:
      - backend
    restart: unless-stopped

volumes:
  mysql_data:

networks:
  frontend-network:
  backend-network:
```

## 4. Start the Application

```bash
docker compose up -d
```

## 5. Check Services

```bash
docker compose ps
```

## 6. Check Health Status

```bash
docker inspect compose-advanced-db-1
```

Look for:

```text
Health
```

## Challenge

Add:

- a Redis service
- a dedicated Redis volume
- a healthcheck
- an environment variable
- a new backend dependency

---

# Lab 10 — Healthchecks and Service Dependencies

## Objective

Understand how healthchecks can be used to control service startup.

## Scenario

The backend must not start before the database is ready.

## 1. Create compose.yaml

```yaml
services:

  database:
    image: mysql:8.4
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: app
    healthcheck:
      test:
        [
          "CMD",
          "mysqladmin",
          "ping",
          "-h",
          "localhost",
          "-uroot",
          "-proot"
        ]
      interval: 5s
      timeout: 5s
      retries: 10

  backend:
    image: nginx:alpine
    depends_on:
      database:
        condition: service_healthy
```

## 2. Start

```bash
docker compose up -d
```

## 3. Observe the Startup

```bash
docker compose ps
```

```bash
docker compose logs -f
```

## Challenge

Modify the healthcheck parameters:

- interval
- timeout
- retries

Observe their effect on startup behavior.

---

# Lab 11 — Docker Resource Management

## Objective

Learn how to control and monitor CPU and memory consumption.

## 1. Start a Container with Memory Limit

```bash
docker run -d \
  --name limited-container \
  --memory="128m" \
  nginx
```

## 2. Start a Container with CPU Limit

```bash
docker run -d \
  --name cpu-limited \
  --cpus="0.5" \
  nginx
```

## 3. Monitor Containers

```bash
docker stats
```

Monitor one container:

```bash
docker stats limited-container
```

## 4. Inspect Resource Configuration

```bash
docker inspect limited-container
```

## 5. Configure Restart Policy

```bash
docker run -d \
  --name restart-demo \
  --restart unless-stopped \
  nginx
```

Inspect:

```bash
docker inspect restart-demo
```

## Challenge

Create a container with:

- 256 MB RAM
- 1 CPU
- `unless-stopped` restart policy

Then monitor it using:

```bash
docker stats
```

---

# Lab 12 — Docker Logs and Troubleshooting

## Objective

Practice troubleshooting a containerized application.

## Scenario

A production web application is unavailable.

The container is running, but users cannot access the application.

## 1. Deploy the Broken Application

```bash
docker run -d \
  --name broken-web \
  -p 8080:80 \
  nginx
```

Now intentionally stop the container:

```bash
docker stop broken-web
```

The application is unavailable.

## 2. Start the Investigation

Use only diagnostic commands first.

```bash
docker ps
```

```bash
docker ps -a
```

```bash
docker logs broken-web
```

```bash
docker inspect broken-web
```

## 3. Restart the Service

```bash
docker start broken-web
```

Check:

```bash
docker ps
```

## 4. Inspect the Application

```bash
docker exec broken-web nginx -t
```

## 5. Monitor Events

Open a terminal:

```bash
docker events
```

In another terminal:

```bash
docker restart broken-web
```

Observe the Docker events.

## Challenge

Create a troubleshooting scenario containing at least three problems:

- wrong port
- stopped container
- incorrect network
- missing volume

The student must diagnose the problems without recreating the entire environment.

---

# Lab 13 — Docker Security

## Objective

Learn basic techniques for improving container security.

## 1. Run a Container as Root

```bash
docker run --rm nginx:alpine id
```

Observe the user.

## 2. Create a Non-root Dockerfile

```dockerfile
FROM alpine:latest

RUN adduser -D appuser

USER appuser

CMD ["sh", "-c", "id && sleep 3600"]
```

Build:

```bash
docker build -t nonroot-demo .
```

Run:

```bash
docker run --rm nonroot-demo
```

## 3. Read-only Filesystem

```bash
docker run --rm \
  --read-only \
  nginx:alpine
```

## 4. Drop Linux Capabilities

```bash
docker run --rm \
  --cap-drop=ALL \
  nginx:alpine
```

## 5. Combine Security Options

```bash
docker run --rm \
  --read-only \
  --cap-drop=ALL \
  nginx:alpine
```

## Challenge

Create a secure application container with:

- non-root user
- read-only filesystem
- dropped capabilities
- only required network access

Explain which security properties have been improved.

---

# Lab 14 — Private Docker Registry

## Objective

Learn how to create and use a local Docker registry.

## 1. Start the Registry

```bash
docker run -d \
  --name local-registry \
  -p 5000:5000 \
  registry:2
```

Verify:

```bash
curl http://localhost:5000/v2/
```

Expected:

```text
{}
```

## 2. Build an Image

```bash
docker build -t my-application .
```

## 3. Tag the Image

```bash
docker tag my-application localhost:5000/my-application:v1
```

## 4. Push the Image

```bash
docker push localhost:5000/my-application:v1
```

## 5. Remove the Local Image

```bash
docker rmi localhost:5000/my-application:v1
```

## 6. Pull the Image

```bash
docker pull localhost:5000/my-application:v1
```

## 7. Run the Pulled Image

```bash
docker run --rm localhost:5000/my-application:v1
```

## Verification

```bash
curl http://localhost:5000/v2/_catalog
```

## Cleanup

```bash
docker rm -f local-registry
```

---

# Lab 15 — Docker Compose + Private Registry

## Objective

Deploy an application using an image stored in a private registry.

## 1. Push an Image

```bash
docker tag my-application localhost:5000/my-application:v1
```

```bash
docker push localhost:5000/my-application:v1
```

## 2. Create compose.yaml

```yaml
services:

  application:
    image: localhost:5000/my-application:v1
    ports:
      - "8080:8080"
    restart: unless-stopped
```

## 3. Start

```bash
docker compose up -d
```

## 4. Verify

```bash
docker compose ps
```

```bash
docker compose logs
```

## Challenge

Create version `v2` of the image.

Push it to the registry.

Modify Compose to deploy `v2`.

---

# Lab 16 — Reverse Proxy with Nginx

## Objective

Deploy several applications behind an Nginx reverse proxy.

## Architecture

```text
                  Browser
                     |
                     v
              +-------------+
              |    Nginx    |
              | Reverse Proxy|
              +------+------+
                     |
              +------+------+
              |             |
              v             v
           app1            app2
```

## 1. Create the Project

```bash
mkdir reverse-proxy
cd reverse-proxy
```

## 2. Create compose.yaml

```yaml
services:

  proxy:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - proxy-network

  app1:
    image: nginx:alpine
    networks:
      - proxy-network

  app2:
    image: nginx:alpine
    networks:
      - proxy-network

networks:
  proxy-network:
```

## 3. Create nginx.conf

```nginx
events {}

http {

    server {
        listen 80;

        location /app1/ {
            proxy_pass http://app1/;
        }

        location /app2/ {
            proxy_pass http://app2/;
        }
    }
}
```

## 4. Start

```bash
docker compose up -d
```

## 5. Test

Open:

```text
http://localhost:8080/app1/
```

Then:

```text
http://localhost:8080/app2/
```

## Challenge

Modify the configuration to use hostnames:

```text
app1.localhost
app2.localhost
```

The reverse proxy must route requests according to the hostname.

---

# Lab 17 — Complete Docker Application

## Objective

Build a complete multi-container application.

## Target Architecture

```text
                    Client
                      |
                      v
                +-----------+
                |   Nginx   |
                |   Proxy   |
                +-----+-----+
                      |
                      v
                +-----------+
                |  Backend  |
                |    API    |
                +-----+-----+
                      |
                      v
                +-----------+
                | Database  |
                +-----------+
```

## Requirements

The application must contain:

### Reverse Proxy

- Nginx
- exposed on port `8080`
- only public entry point

### Backend

- custom Docker image
- custom Dockerfile
- environment variables
- non-root user

### Database

- MySQL or PostgreSQL
- persistent volume
- healthcheck

### Networking

Use two networks:

```text
frontend-network
backend-network
```

Expected architecture:

```text
Internet
   |
   v
Proxy
   |
frontend-network
   |
Backend
   |
backend-network
   |
Database
```

## Constraints

The database must not expose a port on the host.

The backend must not expose a port on the host.

Only Nginx is accessible from the host.

## Required Files

```text
project/
├── compose.yaml
├── .env
├── .dockerignore
├── backend/
│   ├── Dockerfile
│   └── application source
└── nginx/
    └── nginx.conf
```

## Required Docker Features

The solution must use:

- Dockerfile
- `.dockerignore`
- Compose
- custom networks
- volumes
- healthchecks
- environment variables
- restart policies
- non-root container
- reverse proxy

## Verification

The student must demonstrate:

```bash
docker compose ps
```

```bash
docker compose logs
```

```bash
docker network ls
```

```bash
docker volume ls
```

```bash
docker stats
```

The application must remain functional after restarting the containers.

## Challenge

Delete the backend container manually:

```bash
docker rm -f <backend-container>
```

Then verify that Compose can recreate it:

```bash
docker compose up -d
```

Verify that the database data remains available.

---

# Lab 18 — Troubleshooting Challenge

## Objective

Diagnose and fix a broken Docker environment.

## Scenario

You are the DevOps engineer responsible for a production application.

The application contains:

```text
Nginx
Backend
Database
```

Users report:

```text
The application is unavailable.
```

The environment has been intentionally misconfigured.

## Symptoms

You receive the following information:

1. Nginx is running.
2. Backend is running.
3. Database container repeatedly restarts.
4. The application cannot reach the backend.
5. Database data appears to have disappeared.
6. The public HTTP port does not respond.

## Rules

Do not immediately recreate everything.

Use diagnostic commands first:

```bash
docker ps
```

```bash
docker ps -a
```

```bash
docker logs <container>
```

```bash
docker inspect <container>
```

```bash
docker network ls
```

```bash
docker network inspect <network>
```

```bash
docker volume ls
```

```bash
docker volume inspect <volume>
```

```bash
docker stats
```

```bash
docker events
```

## Challenge

Identify and fix at least five problems.

Possible problems include:

- incorrect port mapping
- incorrect network
- incorrect service name
- incorrect environment variable
- missing volume
- database configuration error
- container restart loop
- incorrect reverse proxy configuration

## Deliverable

Create a short incident report:

```text
Problem:
Root cause:
Diagnostic commands:
Fix:
Verification:
Preventive action:
```

---

# Lab 19 — Final DevOps Challenge

## Objective

Build a complete Docker environment independently.

This exercise intentionally provides no direct commands.

## Scenario

Your company wants to containerize a small web platform.

The platform contains:

```text
                   Users
                     |
                     v
              +-------------+
              |    Nginx    |
              | Reverse Proxy|
              +------+------+
                     |
                     v
              +-------------+
              |   Backend   |
              |     API     |
              +------+------+
                     |
                     v
              +-------------+
              | PostgreSQL  |
              +-------------+
```

## Functional Requirements

The platform must:

- expose HTTP through Nginx
- forward requests to the backend
- allow the backend to communicate with PostgreSQL
- persist database data
- restart automatically after failure
- expose application configuration through environment variables
- verify database availability using a healthcheck

## Security Requirements

The student must:

- run the backend as a non-root user
- avoid exposing PostgreSQL to the host
- avoid exposing the backend directly to the host
- use read-only configuration mounts where appropriate
- minimize unnecessary privileges

## Networking Requirements

Create:

```text
frontend-network
backend-network
```

Expected architecture:

```text
                  Host
                   |
                Port 8080
                   |
                   v
                Nginx
                   |
           frontend-network
                   |
                   v
                Backend
                   |
            backend-network
                   |
                   v
              PostgreSQL
```

## Persistence Requirements

PostgreSQL must use a named Docker volume.

The database must retain its data after:

```bash
docker compose down
```

The database data should only be removed when explicitly requested.

## Image Requirements

The backend must use a custom Dockerfile.

The Dockerfile must contain:

- appropriate base image
- `WORKDIR`
- `COPY`
- environment configuration
- non-root user
- `EXPOSE`
- `CMD` or `ENTRYPOINT`

The project must contain:

```text
.dockerignore
```

## Compose Requirements

The Compose file must contain:

- services
- networks
- volumes
- environment variables
- healthcheck
- dependency management
- restart policies

## Registry Requirement

Build the backend image and publish it to the local registry created in Lab 14.

Example naming convention:

```text
localhost:5000/company/backend:v1
```

The final Compose deployment must use the registry image.

## Validation

The following commands should provide useful information:

```bash
docker compose ps
```

```bash
docker compose logs
```

```bash
docker images
```

```bash
docker network ls
```

```bash
docker volume ls
```

```bash
docker stats
```

The following should work:

```bash
curl http://localhost:8080
```

## Failure Simulation

Simulate a backend failure:

```bash
docker compose stop backend
```

Verify the impact.

Restart it:

```bash
docker compose start backend
```

Then simulate a complete Compose restart:

```bash
docker compose down
docker compose up -d
```

Verify that the database data remains available.

---

# Correction Formateur — Final Challenge

## Expected Project Structure

```text
docker-final-project/
├── compose.yaml
├── .env
├── .dockerignore
├── backend/
│   ├── Dockerfile
│   └── app.py
└── nginx/
    └── nginx.conf
```

## Backend Dockerfile

Example solution:

```dockerfile
FROM python:3.12-alpine

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY app.py .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
```

## Backend Application

```python
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import socket

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        hostname = socket.gethostname()
        environment = os.getenv("APP_ENV", "development")

        response = f"""
        <html>
        <body>
            <h1>Docker Final Challenge</h1>
            <p>Environment: {environment}</p>
            <p>Hostname: {hostname}</p>
        </body>
        </html>
        """

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(response.encode())

server = HTTPServer(("0.0.0.0", 8000), Handler)

print("Backend listening on port 8000")

server.serve_forever()
```

## Nginx Configuration

```nginx
events {}

http {

    upstream backend {
        server backend:8000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
        }
    }
}
```

## Environment File

```text
APP_ENV=training
POSTGRES_DB=training
POSTGRES_USER=training
POSTGRES_PASSWORD=training
```

## Compose Solution

```yaml
services:

  proxy:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - frontend-network
    depends_on:
      - backend
    restart: unless-stopped

  backend:
    image: localhost:5000/company/backend:v1
    environment:
      APP_ENV: ${APP_ENV}
    networks:
      - frontend-network
      - backend-network
    depends_on:
      database:
        condition: service_healthy
    restart: unless-stopped

  database:
    image: postgres:18-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - backend-network
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
        ]
      interval: 5s
      timeout: 5s
      retries: 10
    restart: unless-stopped

volumes:
  postgres-data:

networks:
  frontend-network:
  backend-network:
```

## Verification

Start the application:

```bash
docker compose up -d
```

Check:

```bash
docker compose ps
```

Test:

```bash
curl http://localhost:8080
```

Check networks:

```bash
docker network inspect docker-final-project_frontend-network
```

```bash
docker network inspect docker-final-project_backend-network
```

Check volumes:

```bash
docker volume ls
```

Check database health:

```bash
docker inspect <database-container>
```

---

# Docker Cheat Sheet

## Containers

### Run a container

```bash
docker run nginx
```

### Run in background

```bash
docker run -d nginx
```

### Run interactively

```bash
docker run -it ubuntu bash
```

### List running containers

```bash
docker ps
```

### List all containers

```bash
docker ps -a
```

### Start

```bash
docker start <container>
```

### Stop

```bash
docker stop <container>
```

### Restart

```bash
docker restart <container>
```

### Remove

```bash
docker rm <container>
```

### Force remove

```bash
docker rm -f <container>
```

### Execute command

```bash
docker exec <container> <command>
```

### Open shell

```bash
docker exec -it <container> sh
```

### View logs

```bash
docker logs <container>
```

### Follow logs

```bash
docker logs -f <container>
```

### Inspect

```bash
docker inspect <container>
```

### Resource monitoring

```bash
docker stats
```

---

# Images

## List images

```bash
docker images
```

## Build

```bash
docker build -t my-image .
```

## Remove

```bash
docker rmi my-image
```

## Inspect

```bash
docker inspect my-image
```

## Image history

```bash
docker history my-image
```

## Pull

```bash
docker pull nginx
```

## Tag

```bash
docker tag my-image localhost:5000/my-image:v1
```

## Push

```bash
docker push localhost:5000/my-image:v1
```

---

# Volumes

## Create

```bash
docker volume create my-volume
```

## List

```bash
docker volume ls
```

## Inspect

```bash
docker volume inspect my-volume
```

## Remove

```bash
docker volume rm my-volume
```

---

# Networks

## Create

```bash
docker network create my-network
```

## List

```bash
docker network ls
```

## Inspect

```bash
docker network inspect my-network
```

## Connect a container

```bash
docker network connect my-network my-container
```

## Disconnect

```bash
docker network disconnect my-network my-container
```

## Remove

```bash
docker network rm my-network
```

---

# Docker Compose

## Start

```bash
docker compose up -d
```

## Build and start

```bash
docker compose up -d --build
```

## List services

```bash
docker compose ps
```

## Logs

```bash
docker compose logs
```

## Follow logs

```bash
docker compose logs -f
```

## Service logs

```bash
docker compose logs backend
```

## Stop

```bash
docker compose stop
```

## Restart

```bash
docker compose restart
```

## Stop and remove containers

```bash
docker compose down
```

## Stop and remove containers + volumes

```bash
docker compose down -v
```

## Rebuild

```bash
docker compose build
```

---

# Docker Registry

## Start local registry

```bash
docker run -d \
  --name registry \
  -p 5000:5000 \
  registry:2
```

## Tag

```bash
docker tag my-image localhost:5000/my-image:v1
```

## Push

```bash
docker push localhost:5000/my-image:v1
```

## Pull

```bash
docker pull localhost:5000/my-image:v1
```

## List repositories

```bash
curl http://localhost:5000/v2/_catalog
```

---

# Debugging

## Containers

```bash
docker ps -a
```

## Logs

```bash
docker logs <container>
```

## Inspect

```bash
docker inspect <container>
```

## Execute commands

```bash
docker exec -it <container> sh
```

## Resource consumption

```bash
docker stats
```

## Network information

```bash
docker network inspect <network>
```

## Volume information

```bash
docker volume inspect <volume>
```

## Docker events

```bash
docker events
```

## Disk usage

```bash
docker system df
```

---

# Cleanup

## Remove stopped containers

```bash
docker container prune
```

## Remove unused images

```bash
docker image prune
```

## Remove unused volumes

```bash
docker volume prune
```

## Remove unused networks

```bash
docker network prune
```

## General cleanup

```bash
docker system prune
```

## Aggressive cleanup

```bash
docker system prune -a
```

Use the aggressive cleanup command carefully because it can remove unused images that you may want to keep.

---

# Final Challenge — Docker DevOps Project

## Mission

Build and operate a production-like Docker environment from scratch.

The final platform must contain:

```text
                         Client
                           |
                           v
                    +-------------+
                    |    Nginx    |
                    |    Proxy    |
                    +------+------+
                           |
                    frontend-network
                           |
                           v
                    +-------------+
                    |   Backend   |
                    |     API     |
                    +------+------+
                           |
                    backend-network
                           |
                           v
                    +-------------+
                    | PostgreSQL  |
                    +-------------+
                           |
                           v
                    postgres-data
```

## Requirements

### Containerization

The project must include:

- custom Dockerfile
- `.dockerignore`
- optimized image
- non-root user

### Networking

The project must include:

- frontend network
- backend network
- network isolation

### Storage

The database must use:

- named volume
- persistent data

### Configuration

Configuration must be externalized using:

- `.env`
- environment variables

### Availability

The project must include:

- healthcheck
- dependency management
- restart policies

### Reverse Proxy

Nginx must:

- be the only exposed application service
- forward traffic to the backend
- use Docker DNS to resolve the backend

### Registry

The backend image must be:

1. built locally
2. tagged
3. pushed to the local registry
4. removed locally
5. pulled again
6. deployed using Compose

### Troubleshooting

The student must demonstrate troubleshooting by intentionally creating and fixing:

- a wrong port
- a wrong network
- a wrong environment variable
- a stopped container
- a database startup problem

## Final Validation Checklist

```text
[ ] Dockerfile created
[ ] .dockerignore created
[ ] Custom image built
[ ] Image optimized
[ ] Non-root user configured
[ ] Nginx reverse proxy working
[ ] Backend working
[ ] Database working
[ ] Database volume configured
[ ] Data persistence verified
[ ] Two Docker networks configured
[ ] Network isolation verified
[ ] Environment variables configured
[ ] Healthcheck configured
[ ] depends_on configured
[ ] Restart policy configured
[ ] Image pushed to local registry
[ ] Image pulled from registry
[ ] Compose deployment working
[ ] Logs inspected
[ ] Resources monitored
[ ] Failure scenarios tested
[ ] Troubleshooting completed
```

## Expected Skills After Completing the Labs

At the end of these exercises, the trainee should be able to:

- create and manage containers
- work with Docker images
- write Dockerfiles
- optimize Docker images
- use multi-stage builds
- manage volumes
- configure Docker networks
- use Docker Compose
- configure healthchecks
- manage service dependencies
- limit container resources
- troubleshoot containers
- apply basic container security
- operate a private Docker registry
- configure reverse proxies
- build multi-container applications
- persist application data
- diagnose Docker networking problems
- deploy images from a registry
- design a production-like Docker environment