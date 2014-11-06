class usm::yum_install {

    package { 'httpd' :
	ensure	=> installed,
    }

    package { 'php' :
	ensure	=> installed,
    }

}
