class vmsetup::atlas-client {

    $tar_file			= 'atlas-client-2.1.16.el6.x86_64.tar.gz'
    $url			= "puppet:///modules/vmsetup/${tar_file}"

    $work_dir			= "/var/tmp"
    $destination_tar_file	= "$work_dir/$tar_file"
    $extracted_dir		= "$work_dir/atlas-client-2.1.16.el6.x86_64"
    $extract_command		= 'tar -zxvf'
#    $gem_path			= "/opt/puppet/bin"
    $gem_path			= '/app/interpreters/ruby/1.9.3/bin'
# not being used
#    $email			= "shahab_khan@cable.comcast.com"

####################################
#  copy and extract tar.gz file
####################################
  file {$destination_tar_file:
    ensure	=> present,
    source	=> "$url",
  }

  file { $extracted_dir :
    path	=> $extracted_dir,
    ensure	=> directory,
    notify      => Exec['unpack tar-gz'],
  }

  exec { 'unpack tar-gz':
    cwd         => $extracted_dir,
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    command     => "tar -xzf $destination_tar_file",
    creates	=> "$extracted_dir/install_atlas_client.sh",
    refreshonly => true,
    require	=> [ File [$destination_tar_file],
			File [$extracted_dir]  ]
  }

###################
# This will work for newer versions of puppet
# which have array iteration turnged on
###################
#  $packages = [	'libicu-4.2.1-9.1.el6_2.x86_64',
#		'libicu-devel-4.2.1-9.1.el6_2.x86_64', ]
#  each($packages) |$value| {
#    vmsetup::rpm_install { "$packages":
#	rpm_source	=> $extracted_dir }
#  }

####################################
# Install RPMs
####################################

# auto-ruby-1.9.3p194-0.el6.x86_64.rpm
  rpm_install { 'auto-ruby':
	rpm_source	=> $extracted_dir }

# auto-ruby-bundler-0.2.0-0.noarch.rpm
  rpm_install { 'auto-ruby-bundler':
	rpm_source	=> $extracted_dir }

# libffi-3.0.5-3.2.el6.x86_64.rpm
  vmsetup::rpm_install { 'libffi':
	rpm_source	=> $extracted_dir }

# libffi-devel-3.0.5-3.2.el6.x86_64.rpm
  vmsetup::rpm_install { 'libffi-devel':
	rpm_source	=> $extracted_dir }

# libicu-4.2.1-9.1.el6_2.x86_64.rpm
  vmsetup::rpm_install { 'libicu':
	rpm_source	=> $extracted_dir }

# libicu-devel-4.2.1-9.1.el6_2.x86_64.rpm
  vmsetup::rpm_install { 'libicu-devel':
	rpm_source	=> $extracted_dir }

# libyaml-0.1.3-1.el6.x86_64.rpm
#  vmsetup::rpm_install { 'libyaml':
#	rpm_source	=> $extracted_dir }

# libyaml-devel-0.1.3-1.el6.x86_64.rpm
  vmsetup::rpm_install { 'libyaml':
	rpm_source	=> $extracted_dir }

# pkgconfig-0.23-9.1.el6.x86_64.rpm
  vmsetup::rpm_install { 'pkgconfig':
	rpm_source	=> $extracted_dir }

/*
    package { 'rubygems' :
      ensure      => installed,
#      provider => 'rpm',
#      source      => "$rpm_source/$rpm_package*.rpm",
#      require     => Exec ['unpack tar-gz']
  }
*/


#####################################
# Install gems
#####################################
 # atlas-client-2.1.16.gem
  gem_install { 'atlas-client':
	gem_source	=> $extracted_dir,
	require		=> [ Exec [ 'unpack tar-gz' ],
			gem_install [ 'gli' ],
			gem_install [ 'net-http-persistent' ],
			],
#    notify	=> File ['/sbin/atlas-client' ],
  }

# gli-2.9.0.gem
  gem_install { 'gli':
	gem_source	=> $extracted_dir,
	require		=> Exec [ 'unpack tar-gz' ], }

# net-http-persistent-2.9.1.gem
  gem_install { 'net-http-persistent':
	gem_source	=> $extracted_dir,
	require		=> Exec [ 'unpack tar-gz' ], }

######################
# Setup symlink
######################
  file { "$gem_path/atlas-client" :
	ensure	=> present,
	require	=> Gem_install [ 'atlas-client' ],
  }

  file { '/sbin/atlas-client':
    ensure	=> link,
    target	=> "$gem_path/atlas-client",
    require	=> Gem_install [ 'atlas-client' ],
#    notify	=> Exec ['run atlas-client'],
  }

    exec { 'run atlas-client' :
	cwd		=> $work_dir,
	path		=> '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
	command		=> "atlas-client f -f 2>&1 > /tmp/atlas-client.log",
	creates		=> "/tmp/atlas-client.log",
	refreshonly	=> true,
	subscribe	=> [ Gem_install [ 'atlas-client' ],
				File ['/sbin/atlas-client'] ],
	require		=> File [ '/sbin/atlas-client' ],
#	notify		=> Exec['Send email'],
    }

#     before  => [File[$keyfile, "${keyfile}.pub"],Exec["Notify user ${email}"]]
#    }

/*
    exec { 'Send email':
	path		=> '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
#	command`	=> "cat ${keyfile} | mail -s 'New server with hostmon installed' ${email}",
	command 	=> "mail -s 'New server with hostmon installed' ${email}",
	subscribe	=> Exec["run atlas-client"],
	refreshonly	=> true,
	require		=> Exec [ 'run atlas-client' ],
    }
*/

}
