CID_FILE = /tmp/grokzen-redis-cluster.cid
CID =`cat $(CID_FILE)`
IMAGE_NAME = grokzen/redis-cluster
PORTS = -p 7000:7000 -p 7001:7001 -p 7002:7002 -p 7003:7003 -p 7004:7004 -p 7005:7005
NAME = redis1
IP_STATIC = 172.18.0.2
NET_NAME = state_net

help:
	@echo "Please use 'make <target>' where <target> is one of"
	@echo "  build           build the docker image containing a redis cluster"
	@echo "  rebuild         rebuilds the image from scratch without using any cached layers"
	@echo "  run             run the built docker image"
	@echo "  bash            starts bash inside a running container."
	@echo "  clean           removes the tmp cid file on disk"
	@echo "  cli             run redis-cli inside the container on the server with port 7000"
	@echo " ---------"
	@echo "Docker compose commands"
	@echo "  compose-build   builds docker-compose containers"
	@echo "  compose-up      starts docker-compose containers"
	@echo "  compose-stop    stops the running docker-compose containers"

build:
	@echo "Building docker image..."
	docker build -t ${IMAGE_NAME} .

rebuild:
	@echo "Rebuilding docker image..."
	docker build --no-cache=true -t ${IMAGE_NAME} .

network:
	@echo "Trying: Removing old docker container..."
	docker network create --subnet=172.18.0.0/24 $(NET_NAME)
run:
	@echo "Trying: Removing old docker container..."
	-docker rm $(NAME)
	@echo "Running docker image..."
	docker run --name $(NAME) --net $(NET_NAME) --ip $(IP_STATIC) -d $(PORTS) --cidfile $(CID_FILE) -i -t ${IMAGE_NAME}

bash:
	docker exec -it $(CID) /bin/bash

stop:
	docker stop $(CID)
	-make clean

clean:
	# Cleanup cidfile on disk
	-rm $(CID_FILE)
	-docker network rm $(NET_NAME)

cli:
	@echo "Starting CLI with redirect enabled (-c option)"
	docker exec -it $(CID) /redis/src/redis-cli -c -p 7000

compose-build:
	docker-compose -f docker-compose.yml build

compose-up:
	docker-compose -f docker-compose.yml up

compose-stop:
	docker-compose -f docker-compose.yml stop
