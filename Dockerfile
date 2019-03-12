FROM blocknetdx/servicenode:3.12.1

RUN apt-get update && apt-get install -y unzip dnsutils tcpdump

ENV BLOCKNETDX_BASE_DIR /app
ENV BLOCKNETDX_BIN_DIR $BLOCKNETDX_BASE_DIR
ENV BLOCKNETDX_DATA_DIR $BLOCKNETDX_BASE_DIR
ENV BLOCKNETDX_CONFIG_DIR $BLOCKNETDX_BASE_DIR
ENV BLOCKNETDX_CONFIG_FILE $BLOCKNETDX_CONFIG_DIR/blocknetdx.conf
ENV BLOCKNETDX_XBRIDGE $BLOCKNETDX_CONFIG_DIR/xbridge.conf

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p $BLOCKNETDX_DATA_DIR && \
    mkdir -p $BLOCKNETDX_CONFIG_DIR && \
    mkdir -p $BLOCKNETDX_BIN_DIR && \
    mv /bin/blocknetdxd $BLOCKNETDX_BIN_DIR/blocknetdxd

COPY files/blocknetdx.conf $BLOCKNETDX_CONFIG_FILE
COPY files/xbridge.conf $BLOCKNETDX_XBRIDGE

ENTRYPOINT [ "/entrypoint.sh" ]