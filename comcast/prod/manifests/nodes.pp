node default {
        # Two ways to skin the a-la-carte cat ...

  notify {'This host has not been defined for any puppet node. Some very basic configs will still be applied':}
	include 'puppetd'
	include vmsetup
}

node prod-cassandra {
	include 'puppetd'
	include vmsetup
	include vmsetup::xp_cassandra
}

node prod-haproxy {
	include 'puppetd'
	include vmsetup
	include haproxy
}

node prod-mysql {
	include 'puppetd'
	include vmsetup
	include vmsetup::xp_mysql
}

node prod-tomcat {
	include 'puppetd'
	include vmsetup
	include vmsetup::xp_tomcat
}

#############################

node /cass-/ inherits prod-cassandra {
}

node /db-/ , /sql-/ inherits prod-mysql {
}

node /ha-/ , /proxy-/ inherits prod-haproxy {
}

node /intugc-/ , /intmedia-/ inherits prod-tomcat {
}

node /app-/ , /media-/ inherits prod-tomcat {
}

node /ipam-/ , /usm-/  inherits prod-tomcat {
}

node /cmds-/ , /cmdsjobs-/  inherits prod-tomcat {
}

