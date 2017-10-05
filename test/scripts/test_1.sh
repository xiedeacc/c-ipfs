#!/bin/bash

####
# Attempt to retrieve large binary file from running daemon
#
####

source ./test_helpers.sh

IPFS="../../main/ipfs --config /tmp/ipfs_1"

function pre {
	rm -Rf /tmp/ipfs_1
	eval "$IPFS" init;
	check_failure_with_exit "pre" $?
	cp ../config.test1.wo_journal /tmp/ipfs_1/config
}

function post {
	rm -Rf /tmp/ipfs_1;
	rm hello.bin;
	rm hello2.bin;
}

function body {
	create_binary_file 512;
	eval "$IPFS" add hello.bin
	check_failure_with_exit "add hello.bin" $?
	
	#start the daemon
	eval "../../main/ipfs --config /tmp/ipfs_1 daemon &"
	daemon_id=$!
	sleep 5
	
	eval "$IPFS" cat QmVGA3bXDJ41xoT621xQNzQgtBMQHj2AYxaunLBJtSoNgg > hello2.bin
	check_failure_with_exit "cat" $?
	
	# file size should be 512
	actualsize=$(wc -c < hello2.bin)
	if [ $actualsize -ne 512 ]; then
		echo '*** Failure *** file size incorrect'
		exit 1
	fi
	
	kill -9 $daemon_id
}
