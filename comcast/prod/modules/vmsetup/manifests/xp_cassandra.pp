class vmsetup::xp_cassandra {

    yumrepo { 'datastax' :
	descr	=> 'DataStax Repo for Apache Cassandra',
	baseurl	=> 'http://rpm.datastax.com/community',
#	ensure		=> present,
	enabled		=> 0,
	gpgcheck	=> 0,
	require		=> Yumrepo [ 'xplat-ssd-noarch' ],
    }

/*
    package { 'tomcat7' :
        ensure  => present,
        install_options => [{'--enablerepo' => 'xplat-ssd-noarch'}],
	require	=> Yumrepo [ 'datastax' ],
    }
    package { 'mysql' :
	ensure	=> 'installed',
    }
*/

    exec { 'install_cassandra' :
	path    => '/bin:/usr/bin',
	command => 'yum --enablerepo=datastax install -y cassandra20-2.0.9',
	creates => '/var/lib/cassandra',
	require	=> [ Yumrepo [ 'datastax' ],
			Exec [ 'install_jdk' ] ],
    }

    $jna_jar	= 'jna-4.1.0.jar'
    $jna_url	= "https://maven.java.net/content/repositories/releases/net/java/dev/jna/jna/4.1.0/$jna_jar"
    $jna_folder	= '/usr/share/cassandra/lib'

    exec { 'download_jna' :
	cwd	=> '/var/tmp',
	path	=> '/usr/bin',
	command	=> "wget $jna_url",
	creates	=> "/var/tmp/$jna_jar",
	require	=> Exec [ 'install_cassandra' ],
    }

    file { "$jna_folder/$jna_jar" :
	ensure	=> file,
	source 	=> "/var/tmp/$jna_jar",
	owner	=> 'cassandra',
	group	=> 'cassandra',
	mode	=> '0755',
	require	=> Exec [ 'download_jna' ],
    }

    file_line { 'nproc_limits' :
	ensure	=> present,
	path	=> '/etc/security/limits.d/90-nproc.conf',
	line	=> '*	-	nproc	32768',
	require	=> Exec [ 'install_cassandra' ]
    }

    file_line { 'vm.max_map_count' :
	ensure	=> present,
	path	=> '/etc/sysctl.conf',
	line	=> 'vm.max_map_count = 131072',
	match	=> '^vm.max_map_count*',
	require	=> Exec [ 'install_cassandra' ],
#	subscribe	=> Exec [ 'change_limit' ],
    }

    exec { 'change_limit' :
	cwd	=> '/',
	path	=> '/sbin',
	command	=> 'sysctl -e -p',
#	creates	=> "/var/tmp/$jna_jar",
	require	=> [ File_line [ 'nproc_limits' ],
		File_line ['vm.max_map_count'] ]
    }


}
