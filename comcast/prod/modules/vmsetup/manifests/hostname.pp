class vmsetup::hostname {

    $net_file	= '/etc/sysconfig/network'

    file { "$net_file" :
	ensure	=> file,
    }

    file_line { 'change_hostname' :
	path	=> "$net_file",
	line	=> "HOSTNAME=${fqdn}",
	match	=> '^HOSTNAME*',
    }

/*
augeas{ "export foo" :
    context => "/files/tmp/network",
    changes => [
        "set dir[last()+1] /foo",
        "set dir[last()]/client weeble",
        "set dir[last()]/client/option[1] ro",
        "set dir[last()]/client/option[2] all_squash",
    ],
}
*/

}
