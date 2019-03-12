#!/bin/bash

if [ -z $BLOCKNETDX_RPCUSER ]
then
  BLOCKNETDX_RPCUSER="test"
fi

if [ -z $BLOCKNETDX_RPCPASSWORD ]
then
  BLOCKNETDX_RPCPASSWORD="1234"
fi

sed -i "s/{{BLOCKNETDX_DATA_DIR}}/${BLOCKNETDX_DATA_DIR//\//\\/}/g" $BLOCKNETDX_CONFIG_FILE
sed -i "s/{{BLOCKNETDX_RPCUSER}}/${BLOCKNETDX_RPCUSER}/g" $BLOCKNETDX_CONFIG_FILE
sed -i "s/{{BLOCKNETDX_RPCPASSWORD}}/${BLOCKNETDX_RPCPASSWORD}/g" $BLOCKNETDX_CONFIG_FILE

echo "Fastsynced already?"
# If file does not exist, then resync with new file
if [ ! -f "$BLOCKNETDX_DATA_DIR/.fast_synced" ]
then
  cd /utxo
  ls -lastr
  echo "Extracting snapshot from zip: /utxo/BlocknetDX.zip to: $BLOCKNETDX_DATA_DIR"
  unzip -d $BLOCKNETDX_DATA_DIR /utxo/BlocknetDX.zip
  mv $BLOCKNETDX_DATA_DIR/BlocknetDX/blocks $BLOCKNETDX_DATA_DIR/blocks
  mv $BLOCKNETDX_DATA_DIR/BlocknetDX/chainstate $BLOCKNETDX_DATA_DIR/chainstate
  touch $BLOCKNETDX_DATA_DIR/.fast_synced
fi

echo "Starting with config $BLOCKNETDX_CONFIG_FILE:"
cat $BLOCKNETDX_CONFIG_FILE

#exec $BLOCKNETDX_BIN_DIR/blocknetdxd -conf=$BLOCKNETDX_CONFIG_FILE -server -printtoconsole
exec sleep 86400