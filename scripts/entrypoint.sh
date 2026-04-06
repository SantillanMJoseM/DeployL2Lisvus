#!/bin/bash

echo "=== Configurando L2J ==="

# Config DB
sed -i "s#jdbc:mariadb://.*#jdbc:mariadb://db:3306/\#g" login/config/*.properties
sed -i "s#Login=.*#Login=\#g" login/config/*.properties
sed -i "s#Password=.*#Password=\#g" login/config/*.properties

sed -i "s#jdbc:mariadb://.*#jdbc:mariadb://db:3306/\#g" gameserver/config/*.properties
sed -i "s#Login=.*#Login=\#g" gameserver/config/*.properties
sed -i "s#Password=.*#Password=\#g" gameserver/config/*.properties

# IP
sed -i "s#ExternalHostname=.*#ExternalHostname=\#g" gameserver/config/*.properties
sed -i "s#LoginHost=.*#LoginHost=login#g" gameserver/config/*.properties

echo "=== Iniciando LoginServer ==="

cd /opt/server/login
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.loginserver.L2LoginServer > /tmp/login.log 2>&1 &

sleep 10

echo "=== GENERAR HEXID ==="
echo "Ejecutar manualmente:"
echo "docker exec -it l2-server bash"
echo "cd /opt/server/login"
echo "./RegisterGameServer.sh"

echo "=== Esperando antes de GameServer ==="
sleep 999999
