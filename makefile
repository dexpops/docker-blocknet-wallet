all: build run

run:
	docker stop blocknet; \
	docker volume rm blocknet-wallet-volume; \
	docker run --rm --name=blocknet \
	-p 41412:41412 \
	-p 41414:41414 \
	-v blocknet-wallet-volume:/app \
	-v /Users/kj/temp_data:/utxo:ro \
	-d dexpops/docker-blocknet-wallet:latest; \
	docker logs -f blocknet

stop:
	docker stop blocknet

prune:
	docker stop blocknet; \
	docker rm blocknet; \
	docker volume rm blocknet-wallet-volume;

build:
	docker build -t dexpops/docker-blocknet-wallet:latest .
