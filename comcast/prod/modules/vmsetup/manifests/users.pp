class vmsetup::users {

/*
    file { '/etc/sudoers' :
	ensure	=> file,
	source	=> 'puppet:///modules/vmsetup/etc/sudoers',
	backup	=> ".puppet.bak.$uptime_seconds",
	owner	=>  root,
	group	=>  root,
	mode	=> '0440',
    }
*/

    file_line {'sudo_wheel' :
	path    => '/etc/sudoers',
	line    => '%wheel	ALL=(ALL)	NOPASSWD: ALL',
#	match   => '%wheel	ALL=(ALL)	NOP:*',
#	match   => '%wheel',
	ensure  => present,
	require => User [ 'xplat' ],
    }

    #-------------------------------------------#
    user { 'clduser' :
	name		=> 'clduser',
	ensure		=> present,
# this does not work with older puppet versions
#	purge_ssh_keys	=> true,
    }

	## add the sshkey to users login
        ssh_authorized_key { 'clduser@jumphost-fxbo' :
	    ensure	=> present,
	    user	=> 'clduser',
	    type	=> 'ssh-rsa',
	    key		=> 'AAAAB3NzaC1yc2EAAAABIwAAAQEAs/ZmY3GNsOkmxWZRt0BOCthFuJxf08eOJljEaIuX+/TXuIf38C8ZjFEmqmSetMcdIGl+6OxAPVM8m0HhF8bUH56NcMOtk75lWJE6aiFVPXcF4U6Y3xVXErGXVjyspCS+mTdxWtflVXUpHc6//vYaD9vHis9kYCSivZZunSwDage56Ohx9VOsdJyjzPuUHIIZNlPVcw58bcOAuvR14RmDE46UeX9IqHqBJK1Rv9tMs/cqCoqovcy3u4CYl10QOhfdV2fJhPrdOa52FhieHJvC2isvVq1TKY4wi7O9W/MKSyfU9BWkNZ4sAnCDdMRFwHZF61Q3d/uplfm7/+6nAdRRyQ==',
        }
        ssh_authorized_key { 'clduser@jumphost-wbrn' :
	    ensure	=> present,
	    user	=> 'clduser',
	    type	=> 'ssh-rsa',
	    key		=> 'AAAAB3NzaC1yc2EAAAABIwAAAQEAv8ebz/LMzbDwaoBWOPa6POfZq+eUfnyAz3DQc3uM1QCKjm1L/Soniv7wlbTK9tX0vc87wH841skVPs+kSpAz8+F5x9RfTCeOPk9CJ9mmuPrSuQAP+JqzLpFnFK1cgwUBP/H2JJeREHj10AVQuCmJKWEdU/9Zfa7fpqZFpP3ZJiJuDVX884BtXGvdcM6j6rvj/nT9Cvx4xd4h7HvZ9H+JkiRjWsmjndm31qAotjJphvXYPGVOgae6MF6LUvWV3LtnGbpD8AklDOI1UiffVicgw0n/WuGeNgi4tnvldd+hEhMGaq62rMuWvQJfMyWJYgesjQJHMyTm8ICx2Ucxy++MZw==',
        }

    #-------------------------------------------#
#    $xhsuser_passwd	= '$1$3lJpuf9B$p8KM9/4WvoRSXHSMp1Zox0'
    $xhsuser_passwd	= '$1$vMQ4RSy9$gHO4w/5wLtInUYFgyyDl01'

    user { 'xhsuser' :
	name	=> 'xhsuser',
	ensure	=> present,
	groups	=> [ 'wheel' ],
	home	=> '/home/xhsuse',
	uid     => '3999',
	password	=> $xhsuser_passwd,
	shell   => '/bin/bash',
	managehome => true,
    }

# The above password variable does not work with this version
# so going to plan B
    file_line {'xhsuser_password' :
	path    => '/etc/shadow',
	line    => "xhsuser:$xhsuser_passwd:16372:0:99999:7:::",
	match   => '^xhsuser:',
#	match   => '%wheel',
	ensure  => present,
	require => User [ 'xhsuser'],
    }
    #-------------------------------------------#
    user { 'xplat':
	name	=> 'xplat',
	ensure	=> present,
	home	=> '/opt/xplat',
	uid     => '4000',
#	gid     => 'admin',
	shell   => '/bin/bash',
	managehome => true,
# this does not work with older puppet versions
#	purge_ssh_keys => true,
    }

    file { '/opt/xplat' :
	ensure	=> directory,
	owner	=> 'xplat',
	group	=> 'xplat',
	mode	=> '0644',
	require	=> User [ 'xplat' ],
    }

    ssh_authorized_key { 'xplat@anthill' :
	ensure	=> present,
	user	=> 'xplat',
	type	=> 'ssh-rsa',
	key	=> 'AAAAB3NzaC1yc2EAAAABIwAAAQEA3bPvleyyzCHTQphx4qt/ZjUwWw32VYOdnqYsfDG1E2RpxkWBoyHtedLxOzIXP0jxRRLw3rgoQEBXp8MoVM50kPLFSSLjKYmRr4L1jrHTmTona/FZv8wZLcOX0qYho47lqFoq1inac71KgtSwPPH9ZfU5x0koYBorIbnryr79OKm2rEUUUSD1pK9b0cbJETaRTBzw1E/AI+mCtLZnlulMJbpNc2VDaPvMcBMUARs8Q02bHKpaJMcmtMhen1lB4uL/CglXU4+tzMpmjrO0NIQU2iGyEhCYwwdusxC5N24UY0PKQLuwZLCasMyabBvNnamRn8Wte4HtsONpteliPHdwHQ==',
    }

    #-------------------------------------------#

    add_user { 'mhalee000' :
	name		=> 'mhalee000',
	uid		=> '56995',
#	gid		=> '25000',
	ssh_key_title	=> 'mhalee000@HQSML-145536',
	ssh_key_type	=> 'ssh-dss',
	ssh_key		=> 'AAAAB3NzaC1kc3MAAACBAJjxMEtayPSh0Nvvc3YZsWNCKsDygrkQ82UBbowNGzO4YYgh/Tl4jBTj++HjhgYtcJUt4uVHxdILd08O2z3dEU4n2zzY8+LWEXVJx2k8LXadxzwBkvKTBrLjjYmYNmrhPRWiEpFKR3S1Plhu51XnQAYGaejnLVL1WhVUeL5ENuLlAAAAFQCLo1kUjhlY8oC33tcoZoaHp6NzOQAAAIAdw/NWmW65G1AJvOrWF24aId5b9kG2F1i2j2oJ4CjFjReWdAb7oBq9GEm5NrB8ydHeaEi+SgYCPPf9E5RdvnmooNK4SWYnoqk2a+KdbefwrG9YPrlAzEs02zffARHJ/imhbr6UvcTDGNmfvg9XwrRbZ4i+JnzmmkOBREkbFY9f4QAAAIBFCECEFgMGbMFkE3SPTn9ss6eKoluEAOVVMC+ZFCKKGu9U1rAsYViAaxuMUiEQv7UN1l86szteePcbqLs2dpCRSJMfs1Y9bOTKLYIiULNfgIh9G1LxOj4i8+nwAu0BMhz/ihF/hXXQEk4c8eJxBkY2Rd2gk2Vj0qRYzsc/uW8f5w==',
    }

    #-------------------------------------------#
    add_user { 'pgirij001c' :
	name		=> 'pgirij001c',
	uid		=> '92432',
#	gid		=> '5013',
	ssh_key_title	=> 'pradeep@pradeep-9.local',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDbcc+iEHq9+yJUl8R8w3+BVVLxYAoUznj5UDYWXGze8UJCRGQ3B4AQUseJLFF+MlPQS4oHN8yx8XxDE5me5M4bmH2IosTYHHgI4UBrQehixrIfv7w6KjeHoH3qdBb67eRE7Pb6cW0yYr4V4HnNm8JEJ6e4xdAf00qNhygbYtY4Ze239hoRJL5v1M43uW5oGPIy01xSAQ45W9K4Xbc+7+5ZGgyDffD0DHaPVeIN20YFld4lDJXJGq/OqFqG2PZLByP0XGRnJHNM1L/71S+ka2HVhy6fCzcpq/6Suq8lkq14dApEpT4JNQwCM3z+6yr1NbamfYGcyOe8RQffJpxQ4k2x',
    }

    #-------------------------------------------#
    add_user { 'rguntu002c':
	name		=> 'rguntu002c',
	uid		=> '70941',
#	gid		=> '5013',
	ssh_key_title	=> 'rajashekarguntupally@Guntupally',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDXoZtj7Aj7lyKx7RYKsQqup2XBg3KlWUH4m7ee/I3sm1x9Lxkw/IyJWRYTPYJkTS/Zbtj41517cBTj9euv+JIVGZO+yadmBYbDUlD3O3MUtnYYQh4fg28F49t2p5CbQoXBUfW9eZjnKfTcIp6tm4J0g7iofERxOXNBE09bUqRAKSL8mDwbRX1qwgUBDa5ujLp4xYEUB+jDNn7xlorUkr+72OZOb08odzju4mhYOD+TlBgKvY6vtJbDdJMdBvr8cwGYIPl/+VczH8MDmGpDj8ZdP6CDYXb3Wn6xZWpMmvdq6fmVZmudHqRjh/LlhLFhNtOC2KB0awDITCDmLBMa+iWD'
    }

    #-------------------------------------------#

    add_user { 'skhan005c':
	name		=> 'skhan005c',
	uid		=> '8617',
#	gid		=> '5013',
	ssh_key_title	=> 'skhan@comcast',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAABIwAAAQEApqRJAtdSNvfs6IROs/y3JA6SzRTePgtOjtmWi62pXQbl9ytSkgPg+wQNw7yF+UxsEs2dJ6h8ky11cEdfkocmAYFKfRbZxiHrEmS/XobOTXfV2n5bImsXUQGi97o9o9P+YNN+0su8Z+qC90DGqIXLhtxvZEGCBvn56n+LxWFaz66xgqo9z6QuKlrf4VPVJw9hVN1vcuH2ZGFqQcWH+Hsorfh+EGtVf6vPTkdpZweXK1dABei5Wt1PHN0ezACuJCiCFI8o6zIpr08Osp0Cke6eEuAFHC0bm6XQ1IeQgzHt2/q6AHLeyU5BmpjsXpNb1ZZ5O2E1ZV4tLgGmQxzZ9fH5eQ==',
    }

    #-------------------------------------------#

    add_user { 'ssolle001c' :
	name		=> 'ssolle001c',
	uid		=> '5013',
#	gid		=> '5013',
	ssh_key_title	=> 'ssolle001c',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAABJQAAAQEAkRmxeqN+ukTH5CLQYc507FeWuIFeLMtll0s7H4kc+M1hPIgRS6at3Q0y9RHBxf3PkK8JD727Ff6x/8x6QtfYw0fpcyQJAGB0TltQ1CT4rhgB7OUkSsTS8iattbnFRAl4IDMigEU3fU8hMoGeAXDrWbErziYs0Bmx8pfaY3Hem3IbvI/eYqOIuf0LDzwuweJ572JpYMqZtTP+LgOeSXYdGtQow+EhCsn2aQ0axaow5EpnZO+ht9QBGSRAQqUjU/5hfqccBqDGwlSe0+ORl+vUV+mj3HVZlHpgtiMS3fwN5tOSiH2U57xdZViroBkmJoPffNnQmxxh6epPxn0pnA/BJw==',
    }

    #-------------------------------------------#
    define add_user (
	$name		= $name,
	$uid		= $uid,
	$ssh_key_title	= $ssh_key_title,
	$ssh_key_type	= $ssh_key_type,
	$ssh_key	= $ssh_key
    ) {

	group { "$name" :
	    ensure	=> present,
	    gid		=> $uid,
	}

	user { "$name":
	    name	=> $name,
	    uid		=> $uid,
#	    groups	=> [ "$name", 'wheel' ],
	    groups	=> [ 'wheel' ],
	    ensure	=> present,
	    home	=> "/home/$name",
	    shell	=> '/bin/bash',
	    managehome	=> true,
# this does not work with older puppet versions
#	    purge_ssh_keys	=> true,
	    require     => Group["$name"],
	}

	## add the sshkey to users login
	ssh_authorized_key { "$name@$ssh_key_title" :
	    ensure	=> present,
	    user	=> $name,
	    type	=> $ssh_key_type,
	    key		=> $ssh_key,
        }

	## add the sshkey to clduser ogin
	ssh_authorized_key { "$ssh_key_title" :
	    ensure	=> present,
	    user	=> 'clduser',
	    type	=> $ssh_key_type,
	    key		=> $ssh_key,
        }
    }

}

