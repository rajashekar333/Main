class vmsetup::jdk {

    $pkg_name	= 'jdk-1.7.0_65'

    package { 'jdk-1.7.0_60' :
	ensure		=> absent,
    }

    exec { 'install_jdk' :
        path    => '/bin:/usr/bin',
        command => "yum --enablerepo=xplat-ssd-x86_64 install -y $pkg_name",
        creates => '/usr/bin/java',
	require	=> [ Package [ 'jdk-1.7.0_60' ],
			yumrepo [ 'xplat-ssd-x86_64' ] ],
    }

/*
    # install jdk-7u65-linux-x64.rpm from repo
#    package { 'jdk' :
    package { 'jdk-1.7.0_65' :
	ensure		=> installed,
#	ensure		=> latest,
	install_options	=> ['--nogpgcheck'],
	require		=> Package [ 'jdk-1.7.0_60' ],
    }

#$jdk_rpm_file = '/var/tmp/jdk-7u60-linux-x64.rpm'

#### Use yum installlocal to perform installation

    # install jdk-7u60-linux-x64.rpm from puppet server
#    package { 'jdk' :
#        ensure		=> installed,
#	provider	=> 'rpm',
#	source	=> "$jdk_rpm_file",
#	require		=> File [ "$jdk_rpm_file" ],
#    }

#    file { "$jdk_rpm_file" :
#	ensure	=> file,
#	source	=> 'puppet:///modules/vmsetup/var/tmp/jdk-7u60-linux-x64.rpm',
#    }
*/

}
