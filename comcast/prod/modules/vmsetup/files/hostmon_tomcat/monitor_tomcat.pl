#!/usr/bin/perl

  use IO::Handle;
  my $period     = abs( shift @ARGV || 300 );
  my $persistent = shift @ARGV;
  my $terminated;
  $h_name=`hostname`;
  # handle kill signals
  $SIG{ $_ } = sub { $terminated++; die "\n" }
    for qw( HUP INT QUIT TERM );

  # ensure standard period is used
  $period    = get_std_period( $period );

  # build appropriate metric for desired period

  STDOUT->autoflush(1); # don't buffer samples!

  do {
    eval {
         $answer=`java -jar /usr/local/hostmon/bin/jmxsh-R5.jar /usr/local/hostmon/bin/monitor_tomcat.tcl`; 
         foreach (split(/\n/,$answer)) 
         {
            my ($fldname, $fldvalue,$cnt,$intval) = (split(/\:/,$_))[0,1,2,3];
            #print " Thae Values are **$fldname**\t$fldvalue\n";
            $fldinfo{$fldname} = $fldvalue;
            $now  = time();
            my $when = $now - ( $now % $period );
            if ($fldvalue eq "HeapMemoryUsage")
            {
                  $value=&HeapMemoryUsage($fldname);
                  $metric="$intval#$cnt#raw";
                  print "G,$metric,$when,$value,host_mon,cmds-fxbo-01.sys.comcast.net,xplat-ssd,tomcat\n";
            }
            elsif ($fldvalue eq "NonHeapMemoryUsage")
            {
                  $value=&HeapMemoryUsage($fldname);
                  $metric="$intval#$cnt#raw";
                  print "G,$metric,$when,$value,host_mon,cmds-fxbo-01.sys.comcast.net,xplat-ssd,tomcat\n";
            }
            elsif ($fldvalue ne "HeapMemoryUsage")
            {
                 $metric="$intval#$cnt#raw";
                 print "G,$metric,$when,$fldname,host_mon,cmds-fxbo-01.sys.comcast.net,xplat-ssd,tomcat\n";                        
            }
         }
         if( $persistent )
         {
           $when += $period;
           sleep $when - $now;
         } else { $terminated++ }
    };
  } until $terminated;

  exit 0;


  # convert integer to a standard period
  sub get_std_period {
    my ( $period ) = @_;

    my @periods = (   60,  300,   600,   900,   1200,  1800,
                    3600, 7200, 14400, 21600, 43200, 86400, 604800,
    );
    my $prev_p = 0;

    for my $p ( @periods ) {
      return $p if $p == $period;
      if( $period > $prev_p and $period < $p) {
        return( $prev_p || $periods[0] );
      }
      $prev_p = $p;
    }
    return $prev_p
}

sub HeapMemoryUsage
{
      $memory=$_[0];
      my($used) = $memory =~ m/(used=\d+)/;
      ($attr,$value)=split /=/, $used;
       return $value;
}
