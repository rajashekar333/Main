#!/bin/bash
servers="$1"

if [[ $servers == "" ]]
then
	echo -e "\tUsage $0 <file>"
	exit
fi

for server in `cat $servers`
do
	ip=`grep $server $servers|sed -e 's/^/a-/g ;s/\./-/g;s/$/\.sys\.comcast\.net/g'`
	echo "$ip"
done

