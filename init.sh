#!/bin/bash

echo "===== CONFIGURACION L2J ====="

# ==============================
# 📄 VERIFICAR SI EXISTE .ENV
# ==============================
if [ -f ".env" ]; then
  echo "⚠️ Ya existe un archivo .env"
  echo ""
  echo "1) Usar configuración existente"
  echo "2) Regenerar configuración"
  read -p "Seleccioná una opción [1-2]: " OPTION

  if [ "$OPTION" = "1" ]; then
    echo "✅ Usando configuración existente"

    echo ""
    read -p "¿Resetear base de datos? (yes/no) [no]: " RESET_DB
    RESET_DB=${RESET_DB:-no}

    # actualizar variable
    if grep -q "^RESET_DB=" .env; then
      sed -i "s/^RESET_DB=.*/RESET_DB=$RESET_DB/" .env
    else
      echo "RESET_DB=$RESET_DB" >> .env
    fi

  elif [ "$OPTION" = "2" ]; then
    echo "♻️ Regenerando configuración..."
    rm .env
  else
    echo "❌ Opción inválida"
    exit 1
  fi
fi

# ==============================
# 🆕 CREAR .ENV SI NO EXISTE
# ==============================
if [ ! -f ".env" ]; then

  echo ""
  echo "===== NUEVA CONFIGURACION ====="

  # ==============================
  # 🗄️ DATABASE
  # ==============================
  read -p "DB Name [l2j]: " DB_NAME
  DB_NAME=${DB_NAME:-l2j}

  read -p "DB User [l2j]: " DB_USER
  DB_USER=${DB_USER:-l2j}

  read -p "DB Password: " DB_PASSWORD
  [ -z "$DB_PASSWORD" ] && echo "❌ Password requerida" && exit 1

  read -p "DB Port [3306]: " DB_PORT
  DB_PORT=${DB_PORT:-3306}

  read -p "MySQL Root Password: " MYSQL_ROOT_PASSWORD
  [ -z "$MYSQL_ROOT_PASSWORD" ] && echo "❌ Root password requerida" && exit 1

  # ==============================
  # 🎮 GAME SERVER
  # ==============================
  read -p "GameServer ID [1]: " GAMESERVER_ID
  GAMESERVER_ID=${GAMESERVER_ID:-1}

  read -p "Internal Host [127.0.0.1]: " INTERNAL_HOST
  INTERNAL_HOST=${INTERNAL_HOST:-127.0.0.1}

  # ==============================
  # 🌐 DETECTAR IP
  # ==============================
  DEFAULT_IP=$(ip route get 1 | awk '{print $7; exit}')
  echo "💡 IP detectada automáticamente: $DEFAULT_IP"

  read -p "External Host (SIN puerto) [$DEFAULT_IP]: " EXTERNAL_HOST
  EXTERNAL_HOST=${EXTERNAL_HOST:-$DEFAULT_IP}

  if [[ "$EXTERNAL_HOST" == *":"* ]]; then
    echo "❌ No pongas puerto en ExternalHost"
    exit 1
  fi

  if [ -z "$EXTERNAL_HOST" ]; then
    echo "❌ ExternalHost no puede estar vacío"
    exit 1
  fi

  # ==============================
  # 🧹 RESET DB
  # ==============================
  read -p "¿Resetear base de datos? (yes/no) [yes]: " RESET_DB
  RESET_DB=${RESET_DB:-yes}

  # ==============================
  # 📄 CREAR .ENV
  # ==============================
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

RESET_DB=$RESET_DB
EOF

  echo "✅ Archivo .env creado correctamente"
fi

# ==============================
# 🐳 INSTALAR DOCKER SI NO EXISTE
# ==============================
if ! command -v docker &> /dev/null
then
    echo "🐳 Docker no encontrado. Instalando..."

    set -e

    apt update
    apt install -y ca-certificates curl gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update

    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "🔄 Iniciando Docker..."

    if command -v systemctl &> /dev/null
    then
        systemctl enable docker || true
        systemctl start docker || true
    fi

    # fallback LXC
    dockerd > /dev/null 2>&1 &

    sleep 5

    if ! command -v docker &> /dev/null
    then
        echo "❌ Docker no se instaló correctamente"
        exit 1
    fi

    echo "✅ Docker instalado correctamente"
else
    echo "✅ Docker ya está instalado"
fi

# ==============================
# 🚀 LEVANTAR SERVICIO
# ==============================
echo "🚀 Iniciando entorno..."

docker compose down
docker compose up -d --build

echo ""
echo "✅ Servidor desplegado correctamente"
echo "👉 Ver logs: docker logs -f l2j_server"