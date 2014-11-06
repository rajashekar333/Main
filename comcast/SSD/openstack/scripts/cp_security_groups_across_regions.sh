#!/bin/bash

## This script is to copy Security groups across Tenants and Regions
## Author: Rajashekar Guntupally	##Date: 10/09/2014
## Version: 1.0

List_Tenants() {
	echo  " List of Tenants Available:"
	echo -e "\thsi\tipam\tsimon\txcloudv1\txcloudv2\txcloudv3\txhs_REginev1\txhs_REginev2\txhs_platform_v1\txplat\thsiqa\txcloud-int\txcloudqa"
}
List_Regions() {
	echo  "List of Regions Available:"
	echo -e "\tgbr_fxbo\tsea_burn\tndc_cmc_c\tchic_emhr\tndc_cmc_d\tndc_wcdc_b\tndc_ch2_c\tndc_ch2_d\tgbr_wbrn\tchic_area4\tndc_ch2_d"
}


#List_Tenants
currentdir=`pwd`
RCpath=`echo $currentdir| sed -e 's/scripts/RCs/'`

echo -n "Where is Source Tenant RC File [$RCpath/<RCfile>]:"
read Source_Tenant

List_Regions
echo -n "Select Source Region from above list:"
read Source_Region

echo -n "Enter your password to access OpenStack:"
read -s source_password
export OS_PASSWORD="$source_password"
echo ""

if [ -f $Source_Tenant ]
then
	. $Source_Tenant
	export OS_REGION_NAME="$Source_Region"
	Source_Security_GroupS=`nova secgroup-list | awk -F'|' {'print $3'}| egrep -v "^\s*$|Name"`
	echo  "$Source_Security_GroupS"
	echo -n "Select Security Group from above: "
	read Source_Security_Group
else
	echo "$Source_Tenant file doesn't exist, download it from OpenStack Dashboard"
	exit
fi

Tenant_base_file=`basename $Source_Tenant`
Tenant_name=`echo $Tenant_base_file | cut -d'.'  -f1`
Source_Tenant=$Tenant_name

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
#echo -n "Select Target Tenant from above list:"
echo -n "Where is Target Tenant RC file:"
read Target_Tenant
List_Regions
echo -n "Select Target Region from above list:"
read Target_Region

#if [ -f $Target_Tenant.sh ]
if [ -f $Target_Tenant ]
then	
	echo "Sourcing Target details: $Target_Tenant : $Target_Region"
	. $Target_Tenant
	export OS_REGION_NAME="$Target_Region"
	echo -n "Security Group name on Target:"
	read Target_Security_Group
	echo -n "Security Group Description on Target:"
	read Target_Security_Group_desc
else
	echo "$Target_Tenant file doesn't exist, download it from OpenStack Dashboard and Run Script again"
	exit 1
fi

Tenant_base_file=`basename $Target_Tenant`
Tenant_name=`echo $Tenant_base_file | cut -d'.'  -f1`
Target_Tenant=$Tenant_name

echo "Creating Security Group $Target_Security_Group on $Target_Tenant:$Target_Region"
nova secgroup-create $Target_Security_Group "$Target_Security_Group_desc"

while read line
do
	nova secgroup-add-rule $Target_Security_Group $line

done <$RULES_FILE

rm -f $RULES_FILE
