#!/bin/bash

if [ -z $BLOCKNETDX_RPCUSER ]
then
  BLOCKNETDX_RPCUSER="blocknetdxuser"
fi

if [ -z $BLOCKNETDX_RPCPASSWORD ]
then
  BLOCKNETDX_RPCPASSWORD="suttMinrull1e"
fi

sed -i "s/{{BLOCKNETDX_DATA_DIR}}/${BLOCKNETDX_DATA_DIR//\//\\/}/g" $BLOCKNETDX_CONFIG_FILE
sed -i "s/{{BLOCKNETDX_RPCUSER}}/${BLOCKNETDX_RPCUSER}/g" $BLOCKNETDX_CONFIG_FILE
sed -i "s/{{BLOCKNETDX_RPCPASSWORD}}/${BLOCKNETDX_RPCPASSWORD}/g" $BLOCKNETDX_CONFIG_FILE

# Set default FAST_SYNC_MODE
if [ -z $FAST_SYNC_MODE ]
then
  echo "Started blocknetdx in regular mode"
else

  echo "Started blocknetdx in FastSync mode"

  if [ -z $BLOCKNETDX_SNAPSHOT ]
  then
    BLOCKNETDX_SNAPSHOT="${BLOCKNETDX_DATA_DIR}/blocknetdx_snapshot.zip"
  fi

  if [ -z $BLOCKNETDX_SNAPSHOT_MARKER ]
  then
    BLOCKNETDX_SNAPSHOT_MARKER="${BLOCKNETDX_DATA_DIR}/.finished_snapshot_blocknetdx"
  fi

  while [ ! -f $BLOCKNETDX_SNAPSHOT_MARKER ]
  do
    echo "$(date): Waiting for ${BLOCKNETDX_SNAPSHOT_MARKER} to be ready..."
    sleep 5
  done

  echo "Found $BLOCKNETDX_SNAPSHOT_MARKER!"

  # If file does not exist, then resync with new file
  if [ ! -f "$BLOCKNETDX_DATA_DIR/.fast_synced" ]
  then
    echo "deleting $BLOCKNETDX_DATA_DIR/blocks and $BLOCKNETDX_DATA_DIR/chainstate"
    rm -rf "$BLOCKNETDX_DATA_DIR/blocks"
    rm -rf "$BLOCKNETDX_DATA_DIR/chainstate"
    echo "Extracting snapshot from zip: $BLOCKNETDX_SNAPSHOT to: $BLOCKNETDX_DATA_DIR"
    unzip -d $BLOCKNETDX_DATA_DIR $BLOCKNETDX_SNAPSHOT
    touch $BLOCKNETDX_DATA_DIR/.fast_synced
  fi

fi

echo "Starting with config: "
cat $BLOCKNETDX_CONFIG_FILE

exec $BLOCKNETDX_BIN_DIR/blocknetdxd -conf=$BLOCKNETDX_CONFIG_FILE -server -printtoconsole