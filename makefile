all: build run

run:
	docker stop blocknetdx; \
	docker volume rm blocknetdx-volume; \
	docker run --rm --name=blocknetdx \
	-v /Users/kj/utxo/BlocknetDX.zip:/BlocknetDX.zip \
	-v blocknetdx-volume:/data \
	-p 41412:41412 \
	-p 41414:41414 \
	-e BLOCKNETDX_SNAPSHOT=/BlocknetDX.zip \
	dexpops/docker-blocknetdx:latest

stop:
	docker stop blocknetdx

build:
	docker build -t dexpops/docker-blocknetdx:latest .