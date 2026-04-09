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
# 🔨 COMPILAR SOLO SI NO EXISTE BUILD
# ==============================
if [ ! -f "core/build/core.zip" ]; then
  echo "🔨 Compilando core..."
  cd core
  ant clean && ant
else
  echo "✅ Core ya compilado"
fi

if [ ! -f "datapack/build/datapack.zip" ]; then
  echo "🔨 Compilando datapack..."
  cd ../datapack
  ant clean && ant
else
  echo "✅ Datapack ya compilado"
fi

# ==============================
# 📦 DESCOMPRIMIR SI NO EXISTE SERVER
# ==============================
if [ ! -d "/opt/l2server/login" ]; then
  echo "📦 Preparando servidor..."

  mkdir -p /opt/l2server

  unzip -o /opt/l2j-lisvus/core/build/core.zip -d /opt/l2server
  unzip -o /opt/l2j-lisvus/datapack/build/datapack.zip -d /opt/l2server

  chmod -R +x /opt/l2server
else
  echo "✅ Servidor ya desplegado"
fi

# ==============================
# ⚙️ CONFIGURAR DB (SIEMPRE)
# ==============================
echo "🗄️ Configurando conexión a base de datos..."

for file in \
  /opt/l2server/login/config/LoginServer.properties \
  /opt/l2server/gameserver/config/GameServer.properties
do
	sed -i "/# Database info/,/^$/ s|^Driver=.*|Driver=org.mariadb.jdbc.Driver|" $file
	sed -i "/# Database info/,/^$/ s|^URL=.*|URL=jdbc:mariadb://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false|" $file
	sed -i "/# Database info/,/^$/ s|^Login=.*|Login=${DB_USER}|" $file
	sed -i "/# Database info/,/^$/ s|^Password=.*|Password=${DB_PASSWORD}|" $file
done

# ==============================
# 🌐 CONFIGURAR HOST (GAME)
# ==============================
echo "🌐 Configurando IP del GameServer..."

FILE=/opt/l2server/gameserver/config/GameServer.properties

sed -i "s|^InternalHostname.*|InternalHostname=${EXTERNAL_HOST}|" $FILE
sed -i "s|^ExternalHostname.*|ExternalHostname=${EXTERNAL_HOST}|" $FILE

# ==============================
# 📥 GESTIÓN DE BASE DE DATOS
# ==============================
echo "📥 Verificando estado de la base de datos..."

TABLE_EXISTS=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME \
  -e "SHOW TABLES LIKE 'accounts';" | grep accounts || true)

if [ "$RESET_DB" = "yes" ]; then

  echo "🧨 RESET_DB activado - recreando base..."

  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;"
  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME;"

  TABLE_EXISTS=""

fi

if [ -z "$TABLE_EXISTS" ]; then

  echo "🆕 Inicializando base de datos..."

  cd /opt/l2j-lisvus/datapack/sql

  for f in $(ls *.sql custom/*.sql 2>/dev/null); do
    echo "Importando $f"
    mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < "$f"
  done

  # ==============================
  # 🎮 REGISTRAR GAMESERVER
  # ==============================
  echo "🎮 Verificando GameServer en base de datos..."

  GS_EXISTS=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME \
    -se "SELECT COUNT(*) FROM gameservers WHERE server_id=${GAMESERVER_ID};")

  if [ "$GS_EXISTS" -eq 0 ]; then

    echo "🆕 GameServer no registrado, procediendo..."

    cd /opt/l2server/login
    chmod +x *.sh

	echo -e "${GAMESERVER_ID}\n" | ./RegisterGameServer.sh	
  else
    echo "✅ GameServer ID ${GAMESERVER_ID} ya existe"
  fi

else
  echo "✅ Base de datos ya inicializada, no se modifica"
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
# 📜 LOGS (esperar archivo)
# ==============================
echo "⏳ Esperando logs..."

while [ ! -f /opt/l2server/gameserver/game.log ]; do
  sleep 2
done

tail -f /opt/l2server/login/login.log /opt/l2server/gameserver/game.log