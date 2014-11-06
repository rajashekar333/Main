
class vmsetup::yumrepo {

    yumrepo { 'xplat-ssd-noarch' :
	name		=> 'xplat-ssd-noarch',
	descr		=> 'SSD noarch repo',
#	ensure		=> present,
	baseurl		=> 'http://yumrepo.sys.comcast.net/ssd/noarch',
	enabled		=> 0,
	gpgcheck	=> 0,
    }

    yumrepo { 'xplat-ssd-x86_64' :
	name		=> 'xplat-ssd-x86_64',
	descr		=> 'SSD x86_64n repo',
#	ensure		=> present,
	baseurl		=> 'http://yumrepo.sys.comcast.net/ssd/x86_64',
	enabled		=> 0,
	gpgcheck	=> 0,
    }

}
