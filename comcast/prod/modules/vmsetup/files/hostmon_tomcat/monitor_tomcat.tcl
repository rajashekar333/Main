set host localhost
set port 6969
set period 300
set persistent 0
set terminated 0
set mbeanattrs [list]
lappend mbeanattrs {1|java.lang:type=Threading|ThreadCount|300|ThreadCount}
lappend mbeanattrs {1|java.lang:type=Memory|HeapMemoryUsage|60|jvmMemoryHeapUsedKB}
lappend mbeanattrs {1|java.lang:type=Memory|NonHeapMemoryUsage|60|jvmMemoryNonHeapUsedKB}
lappend mbeanattrs {1|java.lang:type=OperatingSystem|OpenFileDescriptorCount|300|OpenFileDescriptors}
set when [clock seconds]
jmx_connect -h $host -p $port
# Write the header
foreach {mbeanattr} $mbeanattrs {
     set parts [split $mbeanattr "\t"]
     set vals [split $mbeanattr "|"]
     set mbean [lindex $vals 1]
     set attr [lindex $vals 2]
     set cnt [lindex $vals 3]
     set intval [lindex $vals 4]
     set answer "[jmx_get -m $mbean $attr]"
     set hostmonstr $answer:$attr:$cnt:$intval
     puts $hostmonstr
}
