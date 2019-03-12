#!/bin/bash
set -e

echo "Starting up with $1"

if [[ "$1" == "blocknetdx-cli" || "$1" == "blocknetdx-tx" || "$1" == "blocknetdxd" || "$1" == "test_blocknetdx" ]]; then

	mkdir -p "$BLOCKNETDX_DATA"


	# Fast sync mode
	if [[ ! -v BLOCKNETDX_SNAPSHOT ]]
	then
		echo "Normal startup"
		echo $BLOCKNETDX_SNAPSHOT
	else
		echo "Check fastsync startup?"
	  if [ ! -f "$BLOCKNETDX_DATA/.fast_synced" ]
	  then
	    echo "Extracting snapshot from zip: $BLOCKNETDX_SNAPSHOT to: $BLOCKNETDX_DATA"
			unzip -d $BLOCKNETDX_DATA $BLOCKNETDX_SNAPSHOT
		  # mv $BLOCKNETDX_DATA/BlocknetDX/blocks $BLOCKNETDX_DATA/blocks
		  # mv $BLOCKNETDX_DATA/BlocknetDX/chainstate $BLOCKNETDX_DATA/chainstate
	    touch $BLOCKNETDX_DATA/.fast_synced
	  fi
	fi

	cat <<-EOF > "$BLOCKNETDX_DATA/blocknetdx.conf"
datadir=/home/blocknet/.blocknetdx
dbcache=256
maxmempool=512
maxmempoolxbridge=128
port=41412
rpcport=41414
listen=1
server=1
logtimestamps=1
logips=1
rpcallowip=0.0.0.0/0
rpctimeout=15
rpcclienttimeout=15
printtoconsole=1
rpcuser=blocknetdxrpc
rpcpassword=DsSjSaRQdPHNJkedZf2K2dcNTEVg3ztCuK2m7vjAisCK
${BLOCKNETDX_EXTRA_ARGS}
EOF
	chown blocknet:blocknet "$BLOCKNETDX_DATA/blocknetdx.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R blocknet "$BLOCKNETDX_DATA"
	ln -sfn "$BLOCKNETDX_DATA" /home/blocknet/.blocknetdx
	chown -h blocknet:blocknet /home/blocknet/.blocknetdx

	exec gosu blocknet "$@"

else
	exec "$@"
fi