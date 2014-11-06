class vmsetup::monit {

    $pkg_name	= 'monit'

    package { "$pkg_name" :
	ensure	=> installed,
    }

}
