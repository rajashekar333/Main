#!/bin/bash
#
# This script will install and configure the MagNETO puppet agent
# Based upon the following wiki
#
# https://wiki.io.comcast.net/display/IDEA/MagNETO+-+Installing+Puppet
#

RUBY_REPO=http://yumrepo.sys.comcast.net/ssd/x86_64
RUBY_RPM=auto-ruby-1.9.3p194-0.el6.x86_64.rpm
RUBY_PATH=/app/interpreters/ruby/1.9.3

function log { 
	LOG_TEXT="$@"
	# if -n flag then this is a new file
	if [ "$1" = "-n" ]
	then
		rm $LOGFILE
		shift
	fi
	LOG_TEXT="$@"
	PREFIX=`basename $0`
	echo "`date` $PREFIX $LOG_TEXT" | tee -a $LOGFILE

}

function yum_list {
	YUM_POSTFIX=$1

	YUM_LOG="/tmp/yl-$YUM_POSTFIX"

	if [ ! -f $YUM_LOG ]
	then
		yum list installed > $YUM_LOG
	fi

}

function install_ruby {

	cd /var/tmp

	# fetch the ruby rpm and install it
	wget -N $RUBY_REPO/$RUBY_RPM | tee -a $LOGFILE

	# Remove the default rubygems.org source
	#/var/tmp/auto-ruby-1.9.3p194-0.el6.x86_64.rpm
	yum localinstall -y /var/tmp/$RUBY_RPM | tee -a $LOGFILE

	# remove the default rubygem.org
	$RUBY_PATH/bin/gem sources\
		-r http://rubygems.org/ | tee -a $LOGFILE

	# Add the Atlas ruby gem source:
	$RUBY_PATH/bin/gem sources -a\
		 http://yumrepo.sys.comcast.net/gems/ | tee -a $LOGFILE
}

function install_puppet {

	# Install the puppet gem
	$RUBY_PATH/bin/gem install --no-rdoc --no-ri puppet\
		--version 3.4.3 | tee -a $LOGFILE

	echo "PATH=$RUBY_PATH/bin:$PATH" >> /etc/profile
}

function puppet_delete_cert {
	CERT_DIR=$1

	PUPPET_URL="https://dcasvc.sys.comcast.net:48251/configuration-management-service/clean_host"

	for cert in `ls $CERT_DIR`
	do
		if [ $cert != 'ca.pem' ]
		then
			cert_name=`echo $cert | sed 's/.pem$//'`
#			echo "Delete cert {$cert_name} from puppet server" | tee -a $LOGFILE
			log "Delete cert {$cert_name} from puppet server"
			/usr/bin/curl -sk -X GET -u "$USER":""\
				"$PUPPET_URL/$cert_name"\
				 | python -mjson.tool | tee -a $LOGFILE
		fi
	done
	rm -rf `dirname $CERT_DIR`
}

function run_puppet {
	# Run puppet
	PE_MASTER=autopuppet.sys.comcast.net
	#PE_ENV=neto_pe_xfinity_home_qa
	PE_ENV=pe_ssd_prod
	PUPPET_LOG="/var/log/puppet/puppet.log"

	$RUBY_PATH/bin/puppet agent --server $PE_MASTER\
		--environment $PE_ENV\
		--logdest=$PUPPET_LOG\
		--test --no-daemonize\
		--pluginsync | tee -a $LOGFILE
}

function check_reboot_required {

	CURRENT_KERNEL=$(uname -r)
	LAST_KERNEL=$(rpm -q --last kernel |\
		perl -pe 's/^kernel-(\S+).*/$1/' | head -1)

	if [ $LAST_KERNEL != $CURRENT_KERNEL ]
	then
#		echo REBOOT
		echo "################################"
		echo "# RRR  EEE BBB   OO   OO  TTTTT"
		echo "# R  R E   B  B O  O O  O   T"
		echo "# RRR  EE  BBB  O  O O  O   T"
		echo "# R R  E   B  B O  O O  O   T"
		echo "# R  R EEE BBB   OO   OO    T"
		echo "#######################################"
		echo "# RRR  EEE  QQ  U  U III RRR  EEE DDD"
		echo "# R  R E   Q  Q U  U  I  R  R E   D  D"
		echo "# RRR  EE  QQ Q U  U  I  RRR  EE  D  D"
		echo "# R R  E   Q QQ U  U  I  R R  E   D  D"
		echo "# R  R EEE  QQQ  UU  III R  R EEE DDD"
		echo "#######################################"
	fi
}

LOGFILE=/var/tmp/puppet-install.log

# Get timestamp for starting process
#echo "############" | tee $LOGFILE
log -n "############"
#echo "`date` $0 Started ###" | tee -a $LOGFILE
log "Started ###"

yum_list "0initial"

# skip if ruby is installed
if [ !  -f "$RUBY_PATH/bin/ruby" ]
then
	install_ruby
else
#	echo "Ruby already installed" | tee -a $LOGFILE
	log "Ruby already installed"
fi

# skip if puppet is installed
if [ !  -f "$RUBY_PATH/bin/puppet" ]
then
	install_puppet
else
#	echo "Puppet already installed" | tee -a $LOGFILE
	log "Puppet already installed"
fi

yum_list "1puppet"

# yum update
#echo "`date` $0 ##### Call yum update" | tee -a $LOGFILE
log "##### Call yum update"
yum update -y | tee -a $LOGFILE
yum upgrade -y | tee -a $LOGFILE

yum_list "2update"

#echo "`date` $0 ##### Call puppet agent" | tee -a $LOGFILE
log "##### Call puppet agent"

# run puppet if not running
if [ -z  "$(pgrep puppet)" ]
then
	if [ ! -z "$(ls /etc/puppet/ssl/certs)" ]
	then
		puppet_delete_cert "/etc/puppet/ssl/certs"
	fi
	run_puppet
else
#	echo "Puppet already running" | tee -a $LOGFILE
	log "Puppet already running"
fi

yum_list "3puppet-run"

# Get timestamp
#echo "`date` $0 ##### Finished" | tee -a $LOGFILE
log "##### Finished"
#echo "############" | tee -a $LOGFILE
log "############"

# reboot server at the end of everything
check_reboot_required


