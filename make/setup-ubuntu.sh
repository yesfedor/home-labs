#!/bin/bash

# Before run chmod +x setup-ubuntu.sh
# Скрипт для настройки Ubuntu 24.04 в WSL (Docker, SSH, WireGuard)
# Выполняется от имени root

set -e

echo "--- Обновление системы ---"
apt update && apt upgrade -y

echo "--- Установка базовых утилит, Docker, SSH и WireGuard ---"
apt install -y \
    curl wget git software-properties-common apt-transport-https \
    ca-certificates gnupg lsb-release build-essential unzip jq \
    ufw wireguard resolvconf openssh-server

echo "--- Настройка Docker репозитория ---"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- Настройка SSH Сервиса ---"
# Генерация ключей хоста, если они отсутствуют
ssh-keygen -A

# Настройка конфига (разрешаем вход по ключам, отключаем пароли для безопасности)
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Настройка ключа пользователя из ~/ci.pub
SSH_KEY_FILE="$HOME/ci.pub"
if [ -f "$SSH_KEY_FILE" ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cat "$SSH_KEY_FILE" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "Ключ из ci.pub добавлен."
else
    echo "ПРЕДУПРЕЖДЕНИЕ: $SSH_KEY_FILE не найден."
fi

# Запуск и включение SSH
if command -v systemctl >/dev/null && systemctl is-system-running >/dev/null 2>&1; then
    systemctl enable ssh
    systemctl start ssh
else
    service ssh start
fi

echo "--- Настройка Firewall (UFW) ---"
ufw allow 22/tcp      # SSH
ufw allow 80/tcp      # HTTP
ufw allow 443/tcp     # HTTPS
ufw allow 51820/udp   # WireGuard
ufw allow 3000:9000/tcp # Dev ports
ufw --force enable

echo "--- Настройка WireGuard (~/wg0.conf) ---"
WG_CONF_SOURCE="$HOME/wg0.conf"
WG_DEST="/etc/wireguard/wg0.conf"
if [ -f "$WG_CONF_SOURCE" ]; then
    cp "$WG_CONF_SOURCE" "$WG_DEST"
    chmod 600 "$WG_DEST"
    
    if command -v systemctl >/dev/null && systemctl is-system-running >/dev/null 2>&1; then
        systemctl enable wg-quick@wg0
        systemctl start wg-quick@wg0
    else
        wg-quick up wg0 || echo "Ошибка старта wg0."
    fi
else
    echo "ПРЕДУПРЕЖДЕНИЕ: $WG_CONF_SOURCE не найден."
fi

echo "--- Очистка ---"
apt autoremove -y && apt clean

echo "--- Финальная проверка ---"
service ssh status | grep Active || echo "SSH не запущен"
docker --version

systemctl enable docker
systemctl enable ssh
systemctl enable wg-quick@wg0

# For dev
sudo ufw disable
