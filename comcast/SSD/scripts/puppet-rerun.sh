#!/bin/sh

SERVER=clduser@$1

PE_MASTER=autopuppet.sys.comcast.net
#PE_ENV=neto_pe_xfinity_home_qa
PE_ENV=pe_ssd_prod

ssh -t $SERVER "sudo /app/interpreters/ruby/1.9.3/bin/puppet agent --server $PE_MASTER --environment $PE_ENV --test --no-daemonize --pluginsync"


