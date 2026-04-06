#!/bin/bash

echo "===== CONFIGURACION L2J ====="

read -p "DB Name [l2j]: " DB_NAME
DB_NAME=${DB_NAME:-l2j}

read -p "DB User [l2j]: " DB_USER
DB_USER=${DB_USER:-l2j}

read -p "DB Password: " DB_PASSWORD

read -p "DB Port [3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

read -p "MySQL Root Password: " MYSQL_ROOT_PASSWORD

read -p "GameServer ID [1]: " GAMESERVER_ID
GAMESERVER_ID=${GAMESERVER_ID:-1}

read -p "Internal Host [127.0.0.1]: " INTERNAL_HOST
INTERNAL_HOST=${INTERNAL_HOST:-127.0.0.1}

read -p "External Host: " EXTERNAL_HOST

cat > .env <<EOF
DB_HOST=mariadb
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
GAMESERVER_ID=$GAMESERVER_ID
INTERNAL_HOST=$INTERNAL_HOST
EXTERNAL_HOST=$EXTERNAL_HOST
EOF

echo "✅ Archivo .env creado"

# ==============================
# 🐳 INSTALAR DOCKER SI NO EXISTE
# ==============================

if ! command -v docker &> /dev/null
then
    echo "🐳 Docker no encontrado. Instalando..."

    apt update
    apt install -y ca-certificates curl gnupg

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update

    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    echo "✅ Docker instalado correctamente"
else
    echo "✅ Docker ya está instalado"
fi

# ==============================
# 🚀 LEVANTAR SERVICIO
# ==============================

echo "🚀 Iniciando Docker Compose..."
docker compose up -d --build