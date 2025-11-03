#!/bin/bash

echo "--- Nettoyage des anciens containers/réseau/images ---"
docker stop http script data 2>/dev/null
docker rm http script data 2>/dev/null
docker network rm my-php-net 2>/dev/null

docker rmi -f tp3-php-mysqli 2>/dev/null

if [ -d "./src/create.sql;C" ]; then
    rm -r "./src/create.sql;C"
fi

echo "--- Création du réseau 'my-php-net' ---"
docker network create my-php-net

echo "--- Construction de l'image PHP avec mysqli (tp3-php-mysqli) ---"
docker build -t tp3-php-mysqli ./php

echo "--- Lancement du container DATA (MariaDB) ---"

docker container run -d \
    --name data \
    --network my-php-net \
    -e MARIADB_RANDOM_ROOT_PASSWORD=yes \
    -e MARIADB_DATABASE=my_app_db \
    -v "$(pwd -W)/src/create.sql:/docker-entrypoint-initdb.d/create.sql" \
    mariadb:latest

echo "--- Lancement du container SCRIPT (PHP-FPM) ---"
docker container run -d \
    --name script \
    --network my-php-net \
    -v "$(pwd -W)/src:/app" \
    tp3-php-mysqli

echo "--- Lancement du container HTTP (NGINX) ---"
docker container run -d \
    --name http \
    --network my-php-net \
    -p 8080:8080 \
    -v "$(pwd -W)/src:/app" \
    -v "$(pwd -W)/config/default.conf:/etc/nginx/conf.d/default.conf" \
    nginx:latest

echo "--- Setup de l'Étape 2 terminé. ---"
echo "Test : http://localhost:8080/test.php. Le compteur doit s'incrémenter à chaque rafraîchissement."