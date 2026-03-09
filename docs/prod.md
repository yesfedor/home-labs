# Production Deployment Guide

This guide details the steps to deploy the Home-Lab infrastructure in a production environment.

## Prerequisites

- **Server:** A Linux server (Ubuntu/Debian recommended) with Docker and Docker Compose installed.
- **Domain:** A domain name pointing to your server (or VPS if using WireGuard tunnel).
- **SSH Access:** Root or sudo user access.
- **Resources:** Minimum 4GB RAM (GitLab requires significant resources), 2 vCPUs, 50GB Disk.

## 1. Initial Host Setup

### SSH Configuration
Secure your server by setting up SSH key authentication.

1.  **Add your public key:**
    Place your public SSH key (e.g., `id_rsa.pub`) into the file `ssh/ci.pub` within the repository.

2.  **Run the setup script:**
    ```bash
    make setup-host-ssh
    ```
    This script will:
    - Install `openssh-server` and `resolvconf`.
    - Add the key from `ssh/ci.pub` to `~/.ssh/authorized_keys`.
    - Ensure the SSH service is running.

## 2. Environment Configuration

1.  **Clone the Repository:**
    ```bash
    git clone <repo_url> /opt/home-labs
    cd /opt/home-labs
    ```

2.  **Create Production Environment File:**
    Copy the template and edit it with your secrets.
    ```bash
    cp configs/prod.env configs/prod.env
    nano configs/prod.env
    ```
    **CRITICAL:** Change all default passwords!
    - `POSTGRES_PASSWORD`
    - `MYSQL_ROOT_PASSWORD`
    - `GITLAB_ROOT_PASSWORD`
    - `TELEPORT_AUTH_TOKEN`
    - `WG_PASSWORD`
    - etc.

## 3. Network & VPN Setup (WireGuard)

If your server is behind a NAT (e.g., home network) and you want public access via a VPS, configure WireGuard.

### Option A: Client Mode (Connect to VPS)
Use this if you have a VPS running a WireGuard server and want this home-lab to connect to it.

1.  Obtain your `wg0.conf` file from your VPS provider or self-hosted VPN.
2.  Place the file in:
    ```bash
    ci/volumes/wireguard/wg0.conf
    ```
    *Note: The container will use this configuration automatically.*

### Option B: Server Mode
Use this if your server has a public IP and will act as the VPN server.

1.  Configure `WG_HOST` and `WG_PASSWORD` in `configs/prod.env`.
2.  Ensure UDP port `51820` is open on your firewall.

## 4. Teleport Configuration

Teleport provides secure access to your infrastructure without opening SSH ports to the world.

1.  **Edit Configuration:**
    Edit the template file `ci/volumes/teleport/config/teleport.yaml`.
    ```bash
    nano ci/volumes/teleport/config/teleport.yaml
    ```
    - Update `auth_token` to match `TELEPORT_AUTH_TOKEN` in `configs/prod.env`.
    - Update `public_addr` if using a domain.
    - Configure `acme` (Let's Encrypt) if Teleport handles SSL.

## 5. Deploying the Stack

Start all services in production mode:

```bash
make up ENV_TYPE=prod
```

This command uses `ci/docker-compose.prod.yml` which applies resource limits and restart policies suitable for production.

## 6. Post-Deployment Configuration

### Nginx Proxy Manager (NPM)
Access NPM at `http://<server-ip>:81`.
- **Default Login:** `admin@example.com` / `changeme`
- **Change Credentials:** Immediately change the email and password.
- **Create Proxy Hosts:**
    Use the **service names** (defined in `docker-compose.yml`) as hostnames:
    - **GitLab:** `http://gitlab:80` -> `git.yourdomain.com`
    - **Nextcloud:** `http://nextcloud:80` -> `cloud.yourdomain.com`
    - **Docmost:** `http://docmost:3000` -> `docs.yourdomain.com`
    - **Beszel:** `http://beszel:8090` -> `sys.yourdomain.com`
    - **Portainer:** `http://portainer:9000` -> `portainer.yourdomain.com`
    - **MinIO:** `http://minio:9001` -> `s3-console.yourdomain.com`

### GitLab
- **Initial Login:** User `root`. Password is in `configs/prod.env` (`GITLAB_ROOT_PASSWORD`) or check logs:
  ```bash
  docker logs gitlab | grep "Password:"
  ```

### Beszel (Monitoring)
- Access at `http://<server-ip>:8090`.
- Create an admin account.
- The agent is already running and connected.

## Maintenance

- **Update Images:**
  ```bash
  make pull ENV_TYPE=prod
  make up ENV_TYPE=prod
  ```
- **View Logs:**
  ```bash
  make logs
  ```
- **Backup:**
  Regularly backup the `ci/volumes/` directory. This contains all persistent data (DBs, configs, files).
