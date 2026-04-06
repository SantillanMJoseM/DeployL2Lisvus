#!/bin/bash

set -e

echo "⏳ Esperando MariaDB..."
sleep 10

cd /opt

if [ ! -d "l2j-lisvus" ]; then
  git clone https://gitlab.com/TheDnR/l2j-lisvus.git
fi

cd l2j-lisvus

echo "🔨 Compilando datapack..."
cd datapack
ant clean && ant

echo "🔨 Compilando core..."
cd ../core
ant clean && ant

echo "📦 Descomprimiendo server..."
mkdir -p /opt/l2server

unzip -o build/core.zip -d /opt/l2server
unzip -o ../datapack/build/datapack.zip -d /opt/l2server

echo "⚙️ Configurando propiedades..."

sed -i "s/ExternalHostname = .*/ExternalHostname = ${EXTERNAL_HOST}/" /opt/l2server/login/config/LoginServer.properties
sed -i "s/InternalHostname = .*/InternalHostname = ${INTERNAL_HOST}/" /opt/l2server/login/config/LoginServer.properties

sed -i "s/ExternalHostname = .*/ExternalHostname = ${EXTERNAL_HOST}/" /opt/l2server/gameserver/config/GameServer.properties
sed -i "s/InternalHostname = .*/InternalHostname = ${INTERNAL_HOST}/" /opt/l2server/gameserver/config/GameServer.properties

echo "📥 Importando base de datos..."

cd /opt/l2j-lisvus/datapack/sql

for f in $(ls *.sql custom/*.sql 2>/dev/null); do
  echo "Importando $f"
  mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME < "$f"
done

echo "🎮 Registrando GameServer..."

cd /opt/l2server/login

chmod +x *.sh

cd /opt/l2server/gameserver

chmod +x *.sh

echo -e "${GAMESERVER_ID}\n" | ./RegisterGameServer.sh

echo "🚀 Iniciando servidores..."

cd /opt/l2server/login
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.loginserver.L2LoginServer &

cd /opt/l2server/gameserver
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.gameserver.GameServer &

tail -f /opt/l2server/login/*.log /opt/l2server/gameserver/*.log