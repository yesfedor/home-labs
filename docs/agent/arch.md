# System Architecture

## Overview
The infrastructure is a self-hosted home-lab managed via Docker Compose, designed to be modular and scalable.

## Components

### Core Infrastructure
- **Nginx Proxy Manager (NPM)**: Reverse proxy and SSL termination. Acts as the main entry point for HTTP/HTTPS traffic.
- **WireGuard**: VPN solution for secure remote access. Can operate in Client mode (connecting to a VPS) or Server mode.
- **Teleport**: Secure access plane for SSH and internal web applications, providing audit logs and role-based access control.
- **Portainer**: Web-based UI for managing Docker containers and stacks.
- **Beszel**: Lightweight system monitoring hub and agent.

### Applications
- **GitLab CE**: Complete DevOps platform for source code management, CI/CD, and Container Registry.
- **GitLab Runner**: Executes CI/CD pipelines triggered by GitLab.
- **Docmost**: Collaborative documentation platform.
- **Nextcloud**: File synchronization, sharing, and collaboration suite.
- **MinIO**: S3-compatible object storage server.

### Data Layer (Shared Services)
- **PostgreSQL**: Primary relational database (used by Docmost, etc.).
- **MariaDB**: Alternative relational database (used by NPM, Nextcloud).
- **Redis**: Shared in-memory data structure store for caching and message brokering.

### Management UIs
- **phpMyAdmin**: Web interface for MariaDB.
- **pgAdmin**: Web interface for PostgreSQL.
- **RedisInsight**: GUI for Redis.

## Network
All services reside in a single Docker bridge network named `homelab`.

### Traffic Flow
1.  **Public Web Access**:
    `Internet` -> `Nginx Proxy Manager (80/443)` -> `Service Container (Internal Port)`
2.  **VPN Access**:
    `Client` -> `WireGuard (51820/udp)` -> `Homelab Network`
3.  **Secure Tunneling**:
    `User` -> `Teleport Proxy` -> `Internal Service / SSH`

## Storage
All persistent data is stored on the host machine in the `ci/volumes/` directory.
This centralized storage strategy simplifies backup and recovery operations.

**Volume Structure:**
- `ci/volumes/postgres/`
- `ci/volumes/mariadb/`
- `ci/volumes/redis/`
- `ci/volumes/gitlab/`
- `ci/volumes/nextcloud/`
- ...and others.
