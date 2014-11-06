class vmsetup::xp_tomcat {

$rpm_file	= 'tomcat7-7.0.53-1.noarch.rpm'
##catalina_home	= 'default'
#$catalina_home	= '/opt/xplat/tomcat'
$tomcat_home	= '/opt/tomcat7'

    exec { 'install_tomcat' :
	path	=> '/bin:/usr/bin',
	command	=> 'yum --enablerepo=xplat-ssd-noarch install -y tomcat7',
	creates	=> '/opt/tomcat7',
#	notify	=> Exec [ 'clear_webapps' ],
#	refresh	=> Exec [ 'clear_webapps' ],
    }

    exec { 'clear_webapps' :
	path	=> '/bin:/usr/bin',
#	command	=> 'mv /opt/tomcat7/webapps /opt/tomcat7/webaps.old; mkdir /opt/tomcat7/webapps',
	command	=> 'rm -rf /opt/tomcat7/webapps/*',
#	creates	=> '/opt/tomcat7/webapps',
	refreshonly	=> true,
#	require	=> Exec [ 'install_tomcat' ],
	subscribe	=> Exec [ 'install_tomcat' ],
    }

    file { '/etc/sudoers.d/sudoers-xplat' :
	ensure	=> file,
	source	=> 'puppet:///modules/vmsetup/etc/sudoers-xplat',
	backup  => ".puppet.bak.$uptime_seconds",
	owner	=> 'root',
	group	=> 'root',
	mode	=> '0644',
	require	=> Exec [ 'install_tomcat' ],
    }

    file { '/etc/sysconfig/tomcat7' :
	ensure	=> file,
	backup  => ".puppet.bak.$uptime_seconds",
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
    }

    file { "$tomcat_home" :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
#	mode	=> '0775',
	recurse	=> true,
	require	=> [ Exec [ 'install_tomcat' ],
			User [ 'xplat' ] ],
    }

    file { "$tomcat_home/etc" :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
	require	=> Exec [ 'install_tomcat' ],
    }

    file { "$tomcat_home/scripts" :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
	require	=> Exec [ 'install_tomcat' ],
    }

    file { "$tomcat_home/WARs" :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
	require	=> Exec [ 'install_tomcat' ],
    }

    file { "$tomcat_home/webapps" :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
	require	=> Exec [ 'install_tomcat' ],
    }

    file { '/var/log/tomcat7' :
	ensure	=> directory,
	owner	=> 'tomcat',
	group	=> 'xplat',
	mode	=> '0775',
	recurse	=> true,
	require	=> Exec [ 'install_tomcat' ],
    }

    file_line { 'change_logrotate' :
	path	=> '/etc/logrotate.d/tomcat7',
	line	=> '  rotate 3',
	match	=> 'rotate*',
	ensure	=> present,
	require	=> Exec [ 'install_tomcat' ],
    }

    file_line {'JAVA_HOME' :
	ensure	=> present,
	path	=> '/etc/sysconfig/tomcat7',
	match	=> 'export JAVA_HOME*',
	line	=> 'export JAVA_HOME="/usr/java/jdk1.7.0_65"',
#	require	=> package [ 'tomcat7' ],
	require	=> Exec [ 'install_tomcat' ],
    }


    file_line {'TOMCAT_INIT_SCRIPT' :
	ensure	=> present,
	path	=> '/etc/init.d/tomcat7',
	match	=> 'export CATALINA_HOME*',
	line	=> 'export CATALINA_HOME CATALINA_PID JAVA_HOME CATALINA_OPTS',
        require => Exec [ 'install_tomcat' ],
}    

    file_line {'JAVA_OPTS' :
	ensure	=> present,
	path	=> '/etc/sysconfig/tomcat7',
	match	=> 'export JAVA_OPTS*',
	line	=> 'export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=6969 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Dsystem.id=`hostname` -verbose:gc -XX:+PrintGCDetails -Xloggc:${CATALINA_HOME}/logs/gc.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${CATALINA_HOME}/logs/heapdump.hpprof -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10M"',
#	require	=> package [ 'tomcat7' ],
	require	=> Exec [ 'install_tomcat' ],
    }

    file_line {'CATALINA_HOME' :
	path	=> '/etc/sysconfig/tomcat7',
#	line	=> 'CATALINA_HOME="/opt/xplat"',
	line	=> 'CATALINA_HOME="/opt/tomcat7"',
	match	=> 'CATALINA_HOME=',
	ensure	=> present,
	require	=> File_line [ 'JAVA_HOME' ],
    }

/*
    service { 'tomcat7':
	ensure	=> running,
	enable	=> true,
	require	=> File_line [ 'CATALINA_HOME' ],
    }
*/
file { '/etc/tomcat7' :
     ensure  => directory,
     recurse => true,
     owner     => tomcat,
     group     => tomcat,
}
# Configuration for hostmon which is for tomcat

    file { '/usr/local/hostmon/bin' :
        ensure  => directory,
        source  => 'puppet:///modules/vmsetup/hostmon_tomcat',
        recurse => true,
        owner   => root,
        group   => root,
        mode    => '0755',
        require => Package [ 'hostmon' ],
    }
   file { '/etc/hostmon/conf.d/external_source.cfg' :
        ensure  => file,
        backup  => ".puppet.bak.$date",
        owner   => root,
        group   => root,
        mode    => '0755',
        source  => 'puppet:///modules/vmsetup/hostmon_tomcat/external_source.cfg',
        require => Package [ 'hostmon' ],
    }

}
