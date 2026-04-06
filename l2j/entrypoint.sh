#!/bin/bash

set -e

echo "⏳ Esperando MariaDB..."
sleep 10

cd /opt

# ==============================
# 📥 CLONAR REPO SI NO EXISTE
# ==============================
if [ ! -d "l2j-lisvus" ]; then
  git clone https://gitlab.com/TheDnR/l2j-lisvus.git
fi

cd l2j-lisvus

# ==============================
# 🔨 COMPILAR
# ==============================
echo "🔨 Compilando datapack..."
cd datapack
ant clean && ant

echo "🔨 Compilando core..."
cd ../core
ant clean && ant

# ==============================
# 📦 DESCOMPRIMIR SERVER
# ==============================
echo "📦 Preparando servidor..."
mkdir -p /opt/l2server

unzip -o build/core.zip -d /opt/l2server
unzip -o ../datapack/build/datapack.zip -d /opt/l2server

# ==============================
# 🔐 PERMISOS
# ==============================
chmod -R +x /opt/l2server

# ==============================
# ⚙️ CONFIGURAR DB
# ==============================
echo "🗄️ Configurando base de datos..."

for file in \
  /opt/l2server/login/config/LoginServer.properties \
  /opt/l2server/gameserver/config/GameServer.properties
do
  sed -i "s|Driver=.*|Driver=org.mariadb.jdbc.Driver|" $file
  sed -i "s|URL=.*|URL=jdbc:mariadb://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false|" $file
  sed -i "s|Login=.*|Login=${DB_USER}|" $file
  sed -i "s|Password=.*|Password=${DB_PASSWORD}|" $file
done

# ==============================
# 🌐 CONFIGURAR HOST (SOLO GAME)
# ==============================
echo "🌐 Configurando hosts del GameServer..."

FILE=/opt/l2server/gameserver/config/GameServer.properties

sed -i "s|^InternalHostname.*|InternalHostname=${INTERNAL_HOST}|" $FILE
sed -i "s|^ExternalHostname.*|ExternalHostname=${EXTERNAL_HOST}|" $FILE

# ==============================
# 📥 IMPORTAR DB
# ==============================
echo "📥 Gestión de base de datos..."

if [ "$RESET_DB" = "yes" ]; then
  echo "🧨 Reseteando base de datos..."

  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;"
  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME;"

  echo "📥 Importando SQL..."

  cd /opt/l2j-lisvus/datapack/sql

  for f in $(ls *.sql custom/*.sql 2>/dev/null); do
    echo "Importando $f"
    mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < "$f"
  done

else
  echo "⚠️ Se conserva la base de datos existente"
fi

# ==============================
# 🎮 REGISTRAR GAMESERVER
# ==============================
if [ "$RESET_DB" = "yes" ]; then

  echo "🧹 Limpiando GameServers..."

  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "DELETE FROM gameservers;"

  echo "🎮 Registrando GameServer..."

  cd /opt/l2server/login
  chmod +x *.sh

  printf "%s\n" "${GAMESERVER_ID}" | ./RegisterGameServer.sh

else
  echo "⚠️ Registro de GameServer omitido"
fi
# ==============================
# 🚀 INICIAR SERVIDORES
# ==============================
echo "🚀 Iniciando servidores..."

cd /opt/l2server/login
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.loginserver.L2LoginServer > login.log 2>&1 &

cd /opt/l2server/gameserver
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.gameserver.GameServer > game.log 2>&1 &

# ==============================
# 📜 LOGS
# ==============================
tail -f /opt/l2server/login/login.log /opt/l2server/gameserver/game.log