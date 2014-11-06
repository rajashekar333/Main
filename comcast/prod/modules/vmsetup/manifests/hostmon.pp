class vmsetup::hostmon {

    exec { 'repo-2626' :
	command	=> '/sbin/atlas-client --smartproxy=69.252.205.149 repo-join --repo-id 2626 --force-overwrite',
	require	=> File [ '/sbin/atlas-client'],
	unless	=> '/bin/ls /etc/yum.repos.d/atlas-client-2626*',
#	creates => '/etc/yum.repos.d/atlas-client-2626-I_O_Infrastructure_Development_Atlas_6_noarch.repo',
    }

    package { 'comcast-camo-conntest-util' :
        ensure	=> present,
	require	=> Exec ['repo-2626'],
    }

    exec { 'repo-438' :
	command	=> '/sbin/atlas-client repo-join --repo-id=438 --force-overwrite',
	unless	=> '/bin/ls /etc/yum.repos.d/atlas-client-438*',
#	creates	=> '/etc/yum.repos.d/atlas-client-438-I_O_Infrastructure_Development_Atlas_6_noarch.repo',
	require	=> File [ '/sbin/atlas-client'],
    }

    package { 'hostmon' :
        ensure	=> present,
	require	=> [ 
# Package ['comcast-camo-conntest-util'],
			Exec ['repo-438'] ],
    }


}
