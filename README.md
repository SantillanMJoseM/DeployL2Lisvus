# L2J Docker PRO

## Deploy

cp .env.example .env
docker-compose up --build

## HEXID

docker exec -it l2-server bash
cd /opt/server/login
./RegisterGameServer.sh

Elegir: 1

Luego:

cd /opt/server/gameserver
java -cp "./libs/*:L2JLisvus.jar" net.sf.l2j.gameserver.GameServer

## Logs

tail -f /tmp/login.log
