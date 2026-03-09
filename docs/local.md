# Local Development Environment Setup

This guide describes how to deploy the Home-Lab infrastructure locally for development and testing purposes.

## Prerequisites

- **Docker Desktop** or **Docker Engine** + **Docker Compose** installed.
- **Make** utility (optional but recommended).
- **Git**.

## Quick Start

1. **Clone the Repository:**
   ```bash
   git clone <repo_url> home-labs
   cd home-labs
   ```

2. **Configure Environment:**
   The `configs/local.env` file is already pre-configured with default credentials for local development.
   
   *Check the file content:*
   ```bash
   cat configs/local.env
   ```
   *Note: In local mode, services use simple passwords like `admin`, `root`, `npm`, etc.*

3. **Start the Stack:**
   Run the following command to start all services in detached mode:
   ```bash
   make up ENV_TYPE=local
   ```
   *Or using docker-compose directly:*
   ```bash
   docker compose -f ci/docker-compose.yml -f ci/docker-compose.local.yml --env-file configs/local.env up -d
   ```

4. **Verify Deployment:**
   Check running containers:
   ```bash
   make ps
   ```

## Accessing Services

In the local environment, ports are exposed directly to `localhost`.

| Service | URL | Credentials (Default) |
|---------|-----|-----------------------|
| **Nginx Proxy Manager** | http://localhost:81 | `admin@example.com` / `changeme` |
| **Portainer** | http://localhost:9000 | Set on first login |
| **Beszel** | http://localhost:8090 | Create account on first login |
| **GitLab** | http://localhost:8190 | `root` / `gitlab_root_password` (or check logs) |
| **Docmost** | http://localhost:3000 | Create account on first login |
| **MinIO Console** | http://localhost:9001 | `admin` / `minio_password` |
| **MinIO API** | http://localhost:9000 | - |
| **phpMyAdmin** | http://localhost:8081 | Server: `mariadb`, User: `npm`, Pass: `npm` |
| **pgAdmin** | http://localhost:5050 | `admin@iny.su` / `admin` |
| **RedisInsight** | http://localhost:5540 | Host: `redis`, Pass: `redis` |

## Database Access

Ports are exposed locally for direct connection via your favorite IDE or client (DBeaver, DataGrip, etc.):

- **Postgres:** `localhost:5432`
  - User: `postgres`
  - Pass: `postgres`
- **MariaDB:** `localhost:3306`
  - User: `npm`
  - Pass: `npm`
- **Redis:** `localhost:6379`
  - Pass: `redis`

## Stopping and Cleanup

**Stop services:**
```bash
make down
```

**Stop and remove volumes (Reset Data):**
```bash
make clean-volumes ENV_TYPE=local
```
*Warning: This will delete all data in `ci/volumes/`!*

## Troubleshooting

- **Port Conflicts:** Ensure ports 80, 443, 3000, 5432, 3306, 6379, 8080, 8090, 9000 are free on your host.
- **Logs:** View logs for a specific service:
  ```bash
  docker compose -f ci/docker-compose.yml -f ci/docker-compose.local.yml --env-file configs/local.env logs -f <service_name>
  ```
