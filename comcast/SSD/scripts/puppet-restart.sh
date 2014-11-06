#!/bin/bah

server=clduser@$1

ssh -t $server 'echo `hostname`; sudo service puppet restart'

