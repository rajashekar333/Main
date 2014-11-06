#!/bin/bash
#
# this script will clean the ssl cert from the MagNETO puppet
# master

SERVERS=$@ 

PUPPET_URL="https://dcasvc.sys.comcast.net:48251/configuration-management-service/clean_host"

for cert in $SERVERS
do
	/usr/bin/curl -sk -X GET -u "$USER":""\
	 "$PUPPET_URL/$cert" | python -mjson.tool
done
