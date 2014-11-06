#!/bin/bash

## This script is to get all Tenants/Regions security groups
## Author: Rajashekar Guntupally	##Date: 11/04/2014
## Version: 1.0

#RCs_dir="$1"
#target_dir="$2"

#if [[ $# -lt 2 ]]
#then
#	echo -e "\tUsage $0 <RCs_dir> <Target_dir>"
#	echo -e "\t RCs_dir: Directory (no / at end) that has all OpenStack RC files only"
#	echo -e "\t Target_dir: To where all security groups files should be copied"
#	exit
#fi

target_dir="/Users/rguntu002c/Documents/Comcast/security_groups"
RCs_dir="/Users/rguntu002c/Documents/Comcast/openstack_RCs"

regions=( gbr_fxbo  sea_burn  ndc_cmc_c  chic_emhr  ndc_cmc_d  ndc_wcdc_b  ndc_ch2_c  ndc_ch2_d  gbr_wbrn  chic_area4 )

for Tenant_file in `ls $RCs_dir/*.sh`
#for Tenant_file in `ls /Users/rguntu002c/Documents/Comcast/openstack_RCs/*.sh`
do
        . $Tenant_file
	Tenant_base_file=`basename $Tenant_file`
	Tenant_name=`echo $Tenant_base_file | cut -d'.'  -f1`
	
	mkdir -p $target_dir/$Tenant_name

	for region in ${regions[@]}
	do
		export OS_REGION_NAME="$region"
		finaldir="$target_dir/$Tenant_name/$region"
		mkdir -p $finaldir
		
		Source_Security_Groups=`nova secgroup-list | awk -F'|' {'print $3'}| egrep -v "^\s*$|Name"|egrep -v default|sed -e 's/ //g'`
		
		for Source_Security_Group in ${Source_Security_Groups[@]}
			do
			
#			Rules_File="${Source_Tenant}_${Source_Region}_${Source_Security_Group}"
			Rules_File="${Source_Security_Group}"

			nova secgroup-list-rules $Source_Security_Group > $finaldir/$Rules_File
			
			## In OS X we need to add '' to sed command to function -i and -e at same time otherwise it creates another backup file ends with 'e'
			sed -i '' -e "1,3d" $finaldir/$Rules_File
			LASTLINE=`wc -l $finaldir/$Rules_File| awk -F' ' {'print $1'}`
			ADDITION="d"
			todelete="$LASTLINE$ADDITION"
			
			sed -i '' -e "$todelete" $finaldir/$Rules_File
			
			sed -i '' -e "s/\|//g" "$finaldir/$Rules_File"
			LINES_COUNT=`wc -l $finaldir/$Rules_File| awk -F' ' {'print $1'}`
			echo "$Tenant_name : $region : $LINES_COUNT Rules: $finaldir/$Rules_File"
		done
	done
done	


## Update it to git
#cd /var/tmp
#rm -rf SSD
#git clone https://github.comcast.com/XPlat/SSD/
#cd SSD/
#mkdir security_groups
#cp -r $target_dir .
#git add security_groups
#git commit -m "All Tenants/Regions security groups rules"
#git push

