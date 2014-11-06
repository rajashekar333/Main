

define vmsetup::gem_install (
     $gem_package = $title,
     $gem_source
) {

#    $gem_path	= $vmsetup::atlas-client::gem_path
   $gem_path	= '/app/interpreters/ruby/1.9.3/bin'

### Perform a standard exec instead of this
### we need to use the centos ruby not the puppet version of ruby
/*
     package { $gem_package :
	name	=> $gem_package,
	ensure	=> installed,
	provider	=> pe_gem,
	source	=> "$gem_source/$gem_package*.gem",
	require	=> [ Exec ['unpack tar-gz'],
#			rpm_install ['auto-ruby-bundler']
		]
    }
*/

    exec { $gem_package :
	cwd	=> "$gem_source",
	path	=> "$gem_path",
	command	=> "gem install --no-rdoc --no-ri --local $gem_source/*.gem 2>&1 > /tmp/gem-install.log",
	creates	=> "/tmp/gem-install.log",
	require	=> [ Exec ['unpack tar-gz'],
#			rpm_install ['auto-ruby-bundler']
		]
    }

}
