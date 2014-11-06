#!/bin/bash

function AddKeyPair {

	keylocation="$1"
	keyname="$2"

	nova keypair-add --pub_key $keylocation $keyname 2>/dev/null

	if [[ $? -gt 0 ]]
	then
        	echo "Key already exists"
	else
	        echo "Created key"
	fi 

}

key_location="/Users/rguntu002c/.ssh/jumphostfxbo_key"
key_name="jumphost-fxbo"
AddKeyPair $key_location $key_name 
#nova keypair-add --pub_key /Users/rguntu002c/.ssh/jumphostfxbo_key jumphost-fxbo3 2>/dev/null
