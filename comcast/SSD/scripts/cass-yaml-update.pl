#!/usr/bin/perl

use strict;

my $cass_yaml_file=shift;

print "Enter Cluster_name:";
	my $cluster_name = <>;chomp($cluster_name);
print "Seeds(Seperated by Comma):";
	my $seeds = <>; chomp($seeds); $seeds =~ s/\s*//g;
print "endpoint_snitch [GossipingPropertyFileSnitch]:";
	my $endpoint_snitch = <>;chomp($endpoint_snitch);$endpoint_snitch=~ s/\s*//g;
print "listen_address:";
	my $listen_address = <>;chomp($listen_address);$listen_address=~ s/\s*//g;
print "rpc_address:";
	my $rpc_address = <>;chomp($rpc_address);$rpc_address=~ s/\s*//g;
print "rpc_port [9160]:";
	my $rpc_port = <>;chomp($rpc_port);$rpc_port=~ s/\s*//g;


open (IN, "$cass_yaml_file");
my @lines = <IN>;
close IN;

open (OUT, ">", $cass_yaml_file) or die "Could not open file '$cass_yaml_file' $!";;

foreach my $line (@lines){
	if ($line !~ /^\#/){
	
		if ($line =~ /^cluster_name/){
			$line =~ s/\'.*\'/\'$cluster_name\'/;
			print OUT $line;
		}
		elsif ($line =~ /seeds\:/){
			$line =~ s/\".*\"/\"$seeds\"/;
			print OUT "$line\n";
		}
		elsif ($line =~ /endpoint_snitch\:/){
			$line =~ s/\: .*$/\: $endpoint_snitch/;
			print OUT "$line\n";
		}
		elsif ($line =~ /rpc_address\:/){
			$line =~ s/\: .*$/\: $rpc_address/;
			print OUT "$line\n";
		}
		elsif ($line =~ /listen_address\:/){
			$line =~ s/\: .*$/\: $listen_address/;
			print OUT "$line\n";
		}
		elsif ($line =~ /rpc_port\:/){
			$line =~ s/\: .*$/\: $rpc_port/;
			print OUT "$line\n";
		}
		else{
			print OUT $line;
		}
	}else{
		print OUT $line;
	}
}
