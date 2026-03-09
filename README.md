# Home-Lab Infrastructure

This repository contains the configuration for a self-hosted home-lab infrastructure using Docker Compose.

## Architecture

The infrastructure is designed to be modular and scalable, managed via `docker compose`.

### Core Services
- **Nginx Proxy Manager (NPM):** Gateway for all HTTP/HTTPS traffic. Handles SSL certificates and reverse proxying.
- **WireGuard:** VPN access (client/server) to securely connect to the lab from anywhere.
- **Teleport:** Secure access plane for SSH and application access.
- **Portainer:** Web-based container management UI.
- **Beszel:** Lightweight monitoring hub and agent.

### Applications
- **GitLab CE:** Complete DevOps platform (Source Code, CI/CD, Registry).
- **GitLab Runner:** CI/CD runner for executing pipelines.
- **Docmost:** Documentation platform.
- **Nextcloud:** File synchronization and sharing.
- **MinIO:** S3-compatible object storage.

### Databases & Caching
- **Postgres:** Primary relational database (shared).
- **MariaDB:** Database for NPM and Nextcloud.
- **Redis:** In-memory data structure store (cache).

### Management Tools
- **phpMyAdmin:** Web interface for MariaDB.
- **pgAdmin:** Web interface for PostgreSQL.
- **RedisInsight:** GUI for Redis.

## Getting Started

### Prerequisites
- Docker & Docker Compose
- Make
- SSH keys (for host access)

### Configuration
1. Copy the example environment file:
   ```bash
   cp configs/local.env configs/prod.env
   ```
2. Edit `configs/prod.env` and set secure passwords and domain names.

### WireGuard Setup

If your server is behind a NAT without a public IP, you can configure WireGuard to connect to a VPS or use it as a server.

**Option 1: Client Mode (Connect to VPS)**
Place your `wg0.conf` file in `ci/volumes/wireguard/`. This configuration will be used by the WireGuard container.

**Option 2: Server Mode (Environment Variables)**
Configure the WireGuard server settings in `configs/prod.env` (e.g., `WG_HOST`, `WG_PASSWORD`).

### Host SSH Setup

To prepare the host machine with necessary SSH access and tools:
1. Place your public SSH key in `ssh/ci.pub`.
2. Run the setup script:
   ```bash
   make setup-host-ssh
   ```
   This will install `openssh-server`, `resolvconf`, and add the key to `~/.ssh/authorized_keys`.

### Usage

Use the `Makefile` to manage the stack.

**Start the infrastructure (Production):**
```bash
make up ENV_TYPE=prod
```

**Start locally (Development):**
```bash
make up ENV_TYPE=local
```

**Stop the infrastructure:**
```bash
make down
```

**View logs:**
```bash
make logs
```

## Directory Structure
- `ci/`: Docker Compose files and volume mounts.
- `configs/`: Environment variables.
- `docs/`: Detailed documentation.
- `make/`: Makefile includes (if any).
- `shared/`: Shared application code (future use).
- `ssh/`: SSH keys for host access setup.

## Network
All services are connected to the `homelab` bridge network.
- **NPM** exposes ports 80/443.
- **WireGuard** exposes port 51820/udp.
- **Teleport** exposes its ports (configured in volume).
- **GitLab** exposes SSH (8192), HTTP (8190), Registry (5000).

## Backup
Data is persisted in `ci/volumes/`. Ensure this directory is backed up regularly.
