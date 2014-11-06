class vmsetup::ntp {

    #-------------------------------------------#
    package { 'ntp':
	ensure	=> present,
    }

    service { 'ntpd':
	ensure	=>   running,
	enable	=>   true,
	require	=>   Package['ntp'],
    }

    file { '/etc/ntp.conf' :
	ensure	=>  file,
	backup	=> ".puppet.bak.$uptime_seconds",
	mode	=>  '0644',
	owner	=>  root,
	group	=>  root,
	source	=>  'puppet:///modules/vmsetup/etc/ntp.conf',
	notify	=>  Service['ntpd'],
    }

}
