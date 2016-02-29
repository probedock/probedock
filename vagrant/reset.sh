#!/bin/bash

RAILS_ENVIRONMENT=production
PROBEDOCK_DATA_DIR="/var/lib/probedock-${RAILS_ENVIRONMENT}"
DOCKER_COMPOSE_FILE="docker-compose.${RAILS_ENVIRONMENT}.vagrant.yml"
DOCKER_COMPOSE_PROJECT_NAME="probedock${RAILS_ENVIRONMENT}"

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" stop web
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" stop app
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" stop cache
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" stop db

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" rm -f web
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" rm -f app
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" rm -f cache
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" rm -f db

sudo rm -fr "$PROBEDOCK_DATA_DIR/*"

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" up --no-recreate -d db
docker run --rm --link "${DOCKER_COMPOSE_PROJECT_NAME}_db_1:db" aanand/wait

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" up --no-recreate -d cache
docker run --rm --link "${DOCKER_COMPOSE_PROJECT_NAME}_cache_1:cache" aanand/wait

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" run --rm --no-deps rake db:setup
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" run --rm --no-deps rake assets:precompile assets:clean
docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" run --rm --no-deps rake templates:precompile static:copy

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" up --no-deps -d app
docker run --rm --link "${DOCKER_COMPOSE_PROJECT_NAME}_app_1:app" aanand/wait

docker-compose -f "$DOCKER_COMPOSE_FILE" -p "$DOCKER_COMPOSE_PROJECT_NAME" up --no-deps -d web
