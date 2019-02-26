#!/bin/bash

if [ -z $BLOCKNETDX_RPCUSER ]
then
  BLOCKNETDX_RPCUSER="blocknetdxuser"
fi

if [ -z $BLOCKNETDX_RPCPASSWORD ]
then
  BLOCKNETDX_RPCPASSWORD="suttMinrull1e123"
fi

if [ -z $BLOCKNETDX_SNAPSHOT_FILENAME ]
then
  BLOCKNETDX_SNAPSHOT_FILENAME=blocknetdx.zip
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
  echo "Finding fileserver to download from"

  while [ 1 ]
  do

  	FILESERVER_IP=$(dig +short blocknet-snapshot.nginx.service.consul.)
  	FILESERVER_PORT=$(dig +short blocknet-snapshot.nginx.service.consul. SRV | awk '{ print $3 }')

    if [ ! -z "$FILESERVER_IP" ]
    then
      echo "Nginx fileserver service found @$FILESERVER_IP:$FILESERVER_PORT, lets get this show on the road..."
      break
    else
      echo "$(date): Nginx fileserver service not found yet..."
    fi

    sleep 10

  done

  echo "Downloading http://$FILESERVER_IP:$FILESERVER_PORT/$BLOCKNETDX_SNAPSHOT_FILENAME"
  wget http://$FILESERVER_IP:$FILESERVER_PORT/$BLOCKNETDX_SNAPSHOT_FILENAME

  # If file does not exist, then resync with new file
  if [ ! -f "$BLOCKNETDX_DATA_DIR/.fast_synced" ]
  then
    echo "deleting $BLOCKNETDX_DATA_DIR/blocks and $BLOCKNETDX_DATA_DIR/chainstate"
    rm -rf "$BLOCKNETDX_DATA_DIR/blocks"
    rm -rf "$BLOCKNETDX_DATA_DIR/chainstate"
    echo "Extracting snapshot from zip: $BLOCKNETDX_SNAPSHOT to: $BLOCKNETDX_DATA_DIR"
    unzip -d $BLOCKNETDX_DATA_DIR $BLOCKNETDX_SNAPSHOT_FILENAME
    touch $BLOCKNETDX_DATA_DIR/.fast_synced
  fi

fi

echo "Starting with config:"
cat $BLOCKNETDX_CONFIG_FILE

exec $BLOCKNETDX_BIN_DIR/blocknetdxd -conf=$BLOCKNETDX_CONFIG_FILE -server -printtoconsole