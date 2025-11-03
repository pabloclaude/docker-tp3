#!/bin/bash

echo "--- Nettoyage des anciens containers ---"
docker stop http script 2> /dev/null
docker rm http script 2> /dev/null
docker network rm my-php-net 2> /dev/null

echo "--- Création du réseau 'my-php-net' ---"
docker network create my-php-net

echo "--- Lancement du container SCRIPT ---"
docker container run -d \
    --name script \
    --network my-php-net \
    -v "$(pwd -W)/src:/app" \
    php:8.2-fpm

echo "--- Lancement du container HTTP (NGINX) ---"
docker container run -d \
    --name http \
    --network my-php-net \
    -p 8080:8080 \
    -v "$(pwd -W)/src:/app" \
    -v "$(pwd -W)/config/default.conf:/etc/nginx/conf.d/default.conf" \
    nginx:latest

echo "--- Setup de l'Étape 1 terminé. ---"
echo "Vérifiez le résultat sur http://localhost:8080/"


echo ""
docker ps