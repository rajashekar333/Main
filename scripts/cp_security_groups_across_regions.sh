#!/bin/bash

## This script is to copy Security groups acorss Tenants and Regions
## Author: Rajashekar Guntupally	##Date: 10/09/2014
## Version: 1.0

List_Tenants() {
	echo  " List of Tenants Available:"
	echo -e "\thsi\tipam\tsimon\txcloudv1\txcloudv2\txcloudv3\txhs_REginev1\txhs_REginev2\txhs_platform_v1\txplat\thsiqa\txcloud-int"
}
List_Regions() {
	echo  "List of Regions Available:"
	echo -e "\tgbr_fxbo\tsea_burn\tndc_cmc_c\tchic_emhr\tndc_cmc_d\tndc_wcdc_b\tndc_ch2_c\tndc_ch2_d\tgbr_wbrn\tchic_area4\tndc_ch2_d"
}

List_Tenants
echo -n "Select Source Tenant from above list:"
read Source_Tenant

List_Regions
echo -n "Select Source Region from above list:"
read Source_Region

if [ -f $Source_Tenant.sh ]
then
	. $Source_Tenant.sh
	export OS_REGION_NAME="$Source_Region"
	Source_Security_GroupS=`nova secgroup-list | awk -F'|' {'print $3'}| egrep -v "^\s*$|Name"`
	echo  "$Source_Security_GroupS"
	echo -n "Select Security Group from above: "
	read Source_Security_Group
else
	echo "$Source_Tenant.sh file doesn't exist, download it from OpenStack Dashboard"
	exit
fi

RULES_FILE="${Source_Tenant}_${Source_Region}_${Source_Security_Group}"
echo "RULES_FILE is $RULES_FILE"
nova secgroup-list-rules $Source_Security_Group > $RULES_FILE

## In OS X we need to add '' to sed command to function -i and -e at same time otherwise it creates another backup file at end'e'
sed -i '' -e "1,3d" $RULES_FILE
LASTLINE=`wc -l $RULES_FILE| awk -F' ' {'print $1'}`
ADDITION="d"
todelete="$LASTLINE$ADDITION"

sed -i '' -e "$todelete" $RULES_FILE

sed -i '' -e "s/\|//g" "$RULES_FILE"
LINES_COUNT=`wc -l $RULES_FILE| awk -F' ' {'print $1'}`
echo "Security group $LINES_COUNT Rules are copied to file $RULES_FILE"

List_Tenants
echo -n "Select Target Tenant from above list:"
read Target_Tenant
List_Regions
echo -n "Select Target Region from above list:"
read Target_Region

if [ -f $Target_Tenant.sh ]
then	
	echo "Sourcing Target details: $Target_Tenant : $Target_Region"
	. $Target_Tenant.sh
	export OS_REGION_NAME="$Target_Region"
	echo -n "Security Group name on Target:"
	read Target_Security_Group
	echo -n "Security Group Description on Target:"
	read Target_Security_Group_desc
else
	echo "$Target_Tenant.sh file doesn't exist, download it from OpenStack Dashboard and Run Script again"
	exit 1
fi

echo "Creating Security Group $Target_Security_Group on $Target_Tenant.sh:$Target_Region"
nova secgroup-create $Target_Security_Group "$Target_Security_Group_desc"

while read line
do
	nova secgroup-add-rule $Target_Security_Group $line

done <$RULES_FILE

rm -f $RULES_FILE
