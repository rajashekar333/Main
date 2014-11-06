class haproxy {

#    $ha_rpm	= 'haproxy-1.5-dev22.el6.x86_64.rpm'
    $ha_rpm	= 'haproxy-1.5.3-1.5.3.x86_64.rpm'
    $ha_pkg	= 'haproxy-1.5.3'

    exec { 'install_haproxy' :
	path    => '/bin:/usr/bin',
	command => "yum --enablerepo=xplat-ssd-x86_64 install -y $ha_pkg",
	creates => '/usr/sbin/haproxy',
	require	=> yumrepo [ 'xplat-ssd-x86_64' ],
    }

/*
    file { '/etc/haproxy/haproxy.cfg' :
	ensure	=> file,
	source	=> 'puppet:///modules/haproxy/haproxy.cfg',
	backup	=> '.puppet.bak',
	require	=> package [ 'haproxy' ],
	notify	=> Service [ 'haproxy' ],
    }
*/

    file { '/etc/haproxy' :
	ensure	=> directory,
	source	=> 'puppet:///modules/haproxy/etc/haproxy/',
	owner	=> root,
	group	=> root,
	recurse	=> true,
	require	=> Exec [ 'install_haproxy' ],
    }

    file { '/var/run/haproxy' :
	ensure	=> directory,
	mode	=> '0755',
	require	=> Exec [ 'install_haproxy' ],
    }

/*
    service { 'haproxy' :
	ensure	=> running,
	enable	=> true,
	require	=> [ Package['haproxy'],
			File ['/opt/haproxy'] ],
    }
*/

}
