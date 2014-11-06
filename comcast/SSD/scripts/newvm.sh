#!/bin/bash
#
# Install puppet using
#
# https://wiki.io.comcast.net/display/IDEA/MagNETO+-+Installing+Puppet
#

HOST=$1
server=clduser@$HOST
LOG_FILE=nv-$HOST.out

echo "Installing puppet on $server"

mv $LOG_FILE.1 $LOG_FILE.2
mv $LOG_FILE.0 $LOG_FILE.1
mv $LOG_FILE $LOG_FILE.0
touch $LOG_FILE

# ftp the install_puppet.sh file to host
scp puppet-install.sh $server:/var/tmp

# execute install_puppet on server
ssh -t $server "sudo bash /var/tmp/puppet-install.sh" | tee -a $LOG_FILE

