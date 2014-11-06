# == Class: vmsetup
#
# Full description of class vmsetup here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { vmsetup:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class vmsetup {

    include 'vmsetup::ntp'
    include vmsetup::users
    include vmsetup::atlas-client
    include vmsetup::hostmon
    include vmsetup::hostname
    include vmsetup::jdk
    include vmsetup::monit
    include vmsetup::nrpe
    include vmsetup::splunk
    include vmsetup::yumrepo
#  include 'vmsetup::postfix_local'

    # only run this if the machines are MEDIA
    if ($hostname =~ /^qamedia/ ) or 
	    ($hostname =~ /^media/) {
	include media
    }

    # only run this if the machines are USM
    if ($hostname =~ /^qausm/ ) or 
	    ($hostname =~ /^usm/) {
	include usm
    }

}
