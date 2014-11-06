class media::ffmpeg {

$free_repo	= 'rpmfusion-free-release'
$free_rpm	= "$free_repo-6-1.noarch.rpm"
$free_url	= 'http://download1.rpmfusion.org/free/el/updates/6/i386'

$nonfree_repo	= 'rpmfusion-nonfree-release'
$nonfree_rpm	= "$nonfree_repo-6-1.noarch.rpm"
$nonfree_url	= 'http://download1.rpmfusion.org/nonfree/el/updates/6/i386'

$pkg	= 'ffmpeg'

    package { "$pkg" :
	ensure	=> present,
	require	=> [ Get_repo [ "$free_repo" ],
			Get_repo [ "$nonfree_repo" ] ]
    }

    get_repo { "$free_repo" :
	repo_file	=> "$free_rpm",
	repo_url	=> "$free_url",
    }

    get_repo { "$nonfree_repo" :
	repo_file	=> "$nonfree_rpm",
	repo_url	=> "$nonfree_url",
    }

    package { 'epel-release' :
	ensure	=> present,
    }

    define get_repo (
	$repo_name	= $title,
	$repo_file	= $repo_file,
	$repo_url	= $repo_url
    ) {
	exec { "wget_$repo_file" :
	    cwd		=> '/var/tmp',
	    path	=> '/bin:/usr/bin',
	    command	=> "wget $repo_url/$repo_file",
	    creates	=> "/var/tmp/$repo_file",
	}

/*
	exec { "yum_install_$repo_file" :
	    cwd		=> '/var/tmp',
	    path	=> '/bin:/usr/bin',
	    command	=> "yum -y localinstall --nogpgcheck /var/tmp/$repo_file",
#	    creates	=> "/var/tmp/$repo_file",
	    require	=> Exec [ "wget_$repo_file" ],
	}
*/
	package { "$repo_name" :
	    ensure	=> present,
	    provider	=> rpm,
	    source	=> "/var/tmp/$repo_file",
	    install_options	=> ['--nosignature'],
	    require	=> [ Exec [ "wget_$repo_file" ],
				Package [ 'epel-release' ] ],
	}
	

    }

}
