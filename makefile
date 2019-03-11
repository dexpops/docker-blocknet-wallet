all: build run

run:
	docker stop blocknet; \
	docker volume rm blocknet-volume; \
	docker run --rm --name=blocknet \
	-v blocknet-volume:/app \
	-v /Users/kj/temp_data:/utxo:ro \
	-d dexpops/docker-blocknet-wallet:latets; \
	docker logs -f blocknet

stop:
	docker stop blocknet

prune:
	docker stop blocknet; \
	docker rm blocknet; \
	docker volume rm blocknet-volume;

build:
	docker build -t dexpops/docker-blocknet-wallet:latets .
