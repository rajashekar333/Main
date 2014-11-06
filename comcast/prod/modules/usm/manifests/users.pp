class usm::users {


    #-------------------------------------------#
    # add Adam Kaufman
    add_user { 'akaufm200' :
#	name		=> 'akaufm200',
	uid		=> 90881,
	ssh_key_title	=> 'adam_kaufman@cable.comcast.com',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDbK4ZhowV8gytSo4hzEWsWDasjAfbD1zmu8He8jVHXYwmJa3nNTaXxNriov5CAAGA6CRKFrtUWJOx+dwJ6TE0KaGbxK3BiwHvLXPfLtbTpWH53vRLS0DCeWMNx2kNUsEvNbV+H/D3bXJ9ZyeD6OwkUFLiSQIUO7FisyZrwEXjnrxCxv9Mqu3mpp6dFxXPE4k781SiAX6LgXzcUWGv7/n14IrGzt8VAMnwnezEKEM20wMKKNcZ6HBqYRc/yoYb5JOAVgoO5L3iXBxk0XnrqcGFfPINra41w2JnIfjMfaXDz18eZocULjLbom0SRoyLBFngZMQRuHhPISxVEV5rfjRXH',
    }

    #-------------------------------------------#
    # add Eddie Mbabaali
    add_user { 'embaba001c' :
#	name		=> 'embaba001c',
	uid		=> 90882,
	ssh_key_title	=> 'embaba001c@HQSML-145987',
	ssh_key_type	=> 'ssh-rsa',
	ssh_key		=> 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDLn/CtsEnc4EZ5n3MxQ5RiSLxqRuhOy0ZBdqSoaQ3m7MkXCTolJcLnNUUnMQh92zhCbXlM3SpnWwtkzIwM4+0beAahvZK/QRVP2M9263own9WQziU1+AYpGza4K8cHqty2lDvtkbd4zRP19p48XTW86kV82DzmhiHgmmzQjq2/4sppw0kcBccNoEmVzDsZdjIsxgYdxqJaOX8OGM0arPVJHOekohfSzzHFG8aCEWPS510n0FS6FuYWSaKJcAcyS+tG48FYiJUaqGhYU91gQ/E5Dy3/cJTEyW5fr3gYkhuR/Y9PUDGNy581q8mKsCKqf2OTdsTH2DGRlpLpbACL5ErT',
    }

    #-------------------------------------------#
    define add_user (
	$username	= $title,
	$uid            = $uid,
	$ssh_key_title  = $ssh_key_title,
	$ssh_key_type   = $ssh_key_type,
	$ssh_key        = $ssh_key
    ) {

	group { "$username" :
	    ensure      => present,
	    gid         => $uid,
	}

	user { "$username":
#	    name        => $name,
	    uid         => $uid,
	    groups      => [ 'wheel' ],
	    ensure      => present,
	    home        => "/home/$username",
	    shell       => '/bin/bash',
	    managehome  => true,
# this does not work with older puppet versions
#	    purge_ssh_keys      => true,
	    require     => Group["$username"],
        }

	## add the sshkey to users login
	ssh_authorized_key { "$username@$ssh_key_title" :
	    user => $username,
            type => $ssh_key_type,
            key  => $ssh_key,
        }
    }

}
