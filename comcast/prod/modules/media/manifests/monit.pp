class media::monit {

###
### Not to be used for tomcat servrs
###
/*
    file {'/etc/monit.conf' :
	ensure	=> file,
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=> 'root',
	group	=> 'root',
	mode	=> '0600',
	source	=> 'puppet:///modules/media/monit.conf',
	require	=> Package  ['monit'],
	notify	=> Service [ 'monit' ],
    }

    file { '/etc/monit.d/media' :
	ensure	=> file,
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=> 'root',
	group	=> 'root',
	mode	=> '0644',
	source	=> 'puppet:///modules/media/media-monit.d',
	require	=> Package  ['monit'],
	notify	=> Service [ 'monit' ],
    }
*/

/*
    exec { "chkconfig_monit' :
	path	=> '/bin:/usr/bin',
	command	=> 'chkconfig monit on',
	onlyif	=> ['test -f /usr/bin/monit', '! service monit status'],
	require	=> [ Package ['monit'],
			File [ '/etc/monit.conf' ],
			File [ '/etc/monit.d/media' ] ]
    }
*/

    service {'monit' :
#	ensure	=> running,
#	enable	=> true,
	# do not torn on for tomcat servers
	ensure	=> stopped,
	enable	=> false,
	require	=> Package  ['monit'],
#	subscribe	=> [ File [ '/etc/monit.conf' ],
#			File [ '/etc/monit.d/media' ] ]
    }

}
