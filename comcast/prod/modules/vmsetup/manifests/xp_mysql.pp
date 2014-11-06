class vmsetup::xp_mysql {

    yumrepo { 'mariadb' :
	baseurl	=> 'http://yum.mariadb.org/5.5/centos6-amd64',
#	ensure		=> present,
	gpgkey	=> 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',

	enabled		=> 0,
	gpgcheck	=> 1,
	require		=> Yumrepo [ 'xplat-ssd-noarch' ],
    }

    exec { 'install_mysql' :
	path    => '/bin:/usr/bin',
	command => 'yum --enablerepo=mariadb install -y MariaDB-Galera-server MariaDB-client galera',
	creates => '/usr/sbin/mysqld',
	require	=> Yumrepo [ 'mariadb' ],
    }

    $percona_pkg	= 'percona-release'
    $percona_rpm	= "$percona_pkg-0.0-1.x86_64.rpm"

    exec { 'wget_percona.rpm' :
	cwd	=> '/var/tmp',
	path	=> '/usr/bin',
	command	=> "wget http://www.percona.com/downloads/percona-release/$percona_rpm",
	creates => "/var/tmp/$percona_rpm",
	require	=> Yumrepo [ 'mariadb' ],
    }

/*
    file { "/var/tmp/$percona_rpm" :
	ensure	=> present,
	source	=> "puppet:///modules/vmsetup/mysql/$percona_rpm",
	require	=> Exec [ 'install_mysql' ]
    }
*/

    package { "$percona_pkg" :
	ensure	=> installed,
	provider	=> 'rpm',
	source	=> "/var/tmp/$percona_rpm",
#	require	=> File [ "/var/tmp/$percona_rpm" ]
	require	=> Exec [ 'wget_percona.rpm' ]
    }

    package { 'percona-xtrabackup' :
	ensure	=> installed,
	require	=> package [ "$percona_pkg" ],
    }

}
