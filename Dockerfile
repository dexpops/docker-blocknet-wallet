FROM debian:stretch-slim as builder

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget unzip

ENV BLOCKNETDX_VERSION 3.12.1
ENV BLOCKNETDX_URL https://github.com/BlocknetDX/blocknet/releases/download/v$BLOCKNETDX_VERSION/blocknetdx-$BLOCKNETDX_VERSION-x86_64-linux-gnu.tar.gz
ENV BLOCKNETDX_SHA256 ef083b72721b50cd132c25a1cd7af8cd7ed857774488cd62f5c3c9843673ca31

# install blocknetdx binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO blocknetdx.tar.gz "$BLOCKNETDX_URL" \
	&& echo "$BLOCKNETDX_SHA256 blocknetdx.tar.gz" | sha256sum -c - \
	&& mkdir bin \
	&& tar -xzvf blocknetdx.tar.gz -C /tmp/bin --strip-components=2 "blocknetdx-$BLOCKNETDX_VERSION/bin/blocknetdx-cli" "blocknetdx-$BLOCKNETDX_VERSION/bin/blocknetdxd" \
	&& cd bin \
	&& wget -qO gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
	&& echo "0b843df6d86e270c5b0f5cbd3c326a04e18f4b7f9b8457fa497b0454c4b138d7 gosu" | sha256sum -c - \
  && cp $(which unzip) /tmp/bin

FROM debian:stretch-slim
COPY --from=builder "/tmp/bin" /usr/local/bin

RUN chmod +x /usr/local/bin/gosu && groupadd -r blocknet && useradd -r -m -g blocknet blocknet

# create data directory
ENV BLOCKNETDX_DATA /data
RUN mkdir "$BLOCKNETDX_DATA" \
	&& chown -R blocknet:blocknet "$BLOCKNETDX_DATA" \
	&& ln -sfn "$BLOCKNETDX_DATA" /home/blocknet/.blocknetdx \
	&& chown -h blocknet:blocknet /home/blocknet/.blocknetdx

VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 41412 41414
CMD ["blocknetdxd"]