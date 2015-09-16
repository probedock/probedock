DOCKER_COMPOSE_PREFIX=$1
DOCKER_COMPOSE_SERVICE=$2
DATA_DIR=$3
DOCKER_COMPOSE_CONFIG=$4

if [ -z "$DOCKER_COMPOSE_CONFIG" ]; then
  DOCKER_COMPOSE_CONFIG=docker-compose.yml
fi

# List running containers for the given prefix and service.
for CONTAINER in $(docker-compose -f "$DOCKER_COMPOSE_CONFIG" -p $DOCKER_COMPOSE_PREFIX ps -q $DOCKER_COMPOSE_SERVICE); do

  # Save container ID.
  echo "- id: $CONTAINER" >> "$DATA_DIR/${DOCKER_COMPOSE_SERVICE}Containers.yml"

  # Save container name.
  NAME=$(docker inspect -f "{{.Name}}" $CONTAINER|sed "s/^\///")
  echo "  name: $NAME" >> "$DATA_DIR/${DOCKER_COMPOSE_SERVICE}Containers.yml"
done
