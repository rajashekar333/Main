class vmsetup::nrpe {


###################
# Deprecated
#
# This below is deprecated since CentOS 6.5 comes with nrpe
#
#####################

#
# Based upon
#
#  https://www.digitalocean.com/community/tutorials/how-to-install-nagios-on-centos-6
#

# rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

    package {'nrpe-2.15' :
	ensure	=> installed,
    }

/*
    package {'nagios-plugins' :
	ensure	=> installed,
	require	=> Package [ 'nrpe-2.15' ],
    }
*/

    package { 'nagios-plugins-all' :
	ensure	=> installed,
	require	=> Package [ 'nrpe-2.15' ],
    }


    file { '/etc/nagios/nrpe.cfg' :
	ensure	=> file,
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=> root,
	group	=> root,
	source	=> 'puppet:///modules/vmsetup/nrpe.cfg',
	require	=> Package [ 'nrpe-2.15' ],
	notify	=> Service [ 'nrpe' ],
    }

    file { '/etc/logrotate.d/nrpe' :
	ensure	=> file,
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=> root,
	group	=> root,
	source	=> 'puppet:///modules/vmsetup/nrpe.logrotate',
	require	=> Package [ 'nrpe-2.15' ],
	notify	=> Service [ 'nrpe' ],
    }

    file { '/usr/lib64/nagios/plugins' :
	ensure	=> directory,
	source	=> 'puppet:///modules/vmsetup/nagios/',
	recurse	=> true,
	owner	=> root,
	group	=> root,
	mode	=> '0755',
	require	=> Package [ 'nagios-plugins-all' ],
    }

    service { 'nrpe' :
	ensure	=> running,
	require	=> [ Package [ 'nrpe-2.15' ],
			File [ '/etc/nagios/nrpe.cfg' ],
			File [ '/etc/rsyslog.d/nrpe.conf' ],
			Service [ 'rsyslog' ] ],
    }

    file { '/etc/rsyslog.d/nrpe.conf' :
	ensure	=> file,
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=> root,
	group	=> root,
	source	=> 'puppet:///modules/vmsetup/nrpe.conf',
	require	=> Package [ 'nrpe-2.15' ],
	notify	=> Service [ 'rsyslog' ],
    }

    service { 'rsyslog' :
	ensure	=> running,
	require	=> File [ '/etc/rsyslog.d/nrpe.conf' ],
    }
}
