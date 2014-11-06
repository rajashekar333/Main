#!/bin/bash
#
### This script is to build Instances
### Author: Rajashekar Guntupally	##Date: 10/27/2014
### Version: 1.0 To build Tomcat,Cassandra,sql,proxy instances		## Date: 10/27/2014
### Version: 2.0 Updated to build volumes for Cassandra and Sql 	## Date: 10/29/2014
### Version: 2.1 Updated to build volumes for Media  			## Date: 11/03/2014
### Version: 2.2 Updated to build volumes using functions.      	## Date: 11/04/2014
### Version: 2.3 Updated to have nova credentials check after password prompt.      	## Date: 11/05/2014


function isNovaExist {

	command -v nova >/dev/null
	if [ $? -gt 0 ]
	then
		echo "Nova is not installed, see this https://wiki.io.comcast.net/display/SSDDEVOPS/Nova+-+Installation"
		exit 1
	fi
}

function IsConfirm {

	eval confirmation="$1"
	eval exitreason="$2"
	if [ $confirmation != "Yes" ] && [ $confirmation != "Y" ]
	then
		echo "${exitreason}"
		exit
	fi
}	

function isFileExist {

	file="$1"
	if [ ! -e $file ] || [[ "x$file" == "x" ]]
	then
        	echo "File:$file doesn't exist, Provide complete path of file"
       		exit
	fi
}

function Flavors_details {

	echo -e "\t################################ Flavors definition ############################"
	echo -e "\t#       +-----+-----------+-----------+------+-----------+------+-------+      #"
	echo -e "\t#       | ID  | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs |      #"
	echo -e "\t#       +-----+-----------+-----------+------+-----------+------+-------+      #"
	echo -e "\t#       | 101 | m1.tiny   | 512       | 20   | 0         |      | 1     |      #"
	echo -e "\t#       | 102 | m1.small  | 2048      | 20   | 0         |      | 1     |      #"
	echo -e "\t#       | 103 | m1.medium | 4096      | 20   | 0         |      | 2     |      #"
	echo -e "\t#       | 104 | m1.large  | 8192      | 20   | 0         |      | 4     |      #"
	echo -e "\t#       | 105 | m1.xlarge | 16384     | 20   | 0         |      | 8     |      #"
	echo -e "\t#       +-----+-----------+-----------+------+-----------+------+-------+      #"
	echo -e "\t################################################################################"

}

function AddKeyPair {

	keylocation="$1"
	keyname="$2"

	nova keypair-add --pub_key $keylocation $keyname 2>/dev/null

	if [[ $? -gt 0 ]]
	then
        	echo -e "\tSeems Key $keyname already exists on Tenant, Nothing to do"
	else
	        echo -e "\tCreated key $keyname"
	fi

}

function Create_Volume {

	volume_name="$1"
	eval volume_desc="$2"
	volume_size="$3"
	echo "Creating Volume $volume_name for ${volume_desc}"
	nova volume-create --display-name $volume_name --display-description "${volume_desc}" $volume_size
	volume_id=`nova volume-list | grep $volume_name | awk -F' ' {'print $2'}`

}

function Attach_Volume {

	volume_host="$1"
	volume_id="$2"
	volume_dev="$3"
	echo "Attaching volume $volume_id to $volume_host"
	nova volume-attach $volume_host $volume_id $volume_dev

}	
	
isNovaExist

echo -n "Is Tenant ready to build instances? [Yes/No]:"
read tenant_confirmation
tenant_exitreason='First Create Tenants and run this script'
IsConfirm "\${tenant_confirmation}"  "\${tenant_exitreason}"

echo -n "Did you create Security Groups in Each Regions in Tenant [Yes/No]:"
read securitygroup_confirmation
securitygroup_exitreason="Go ahead and create Security Groups using cp_security_groups_across_regions.sh"
IsConfirm "\${securitygroup_confirmation}" "\${securitygroup_exitreason}"

currentdir=`pwd`
RCpath=`echo $currentdir| sed -e 's/scripts/RCs/'`

echo -n "Where is Tenant RC File [$RCpath/<RCfile>]:"
read source_Tenant
isFileExist $source_Tenant
echo "Sourcing $source_Tenant"
. $source_Tenant

echo -n "Enter the Tenant Full Region Name:"
read Source_Region
echo "Exporting Region OS_REGION_NAME=$Source_Region"
export OS_REGION_NAME="$Source_Region"

#Check nova credentials
nova credentials &>/dev/null

until [[ $? == "0" ]]
do
        if [[ $credcheckcounter == "1" ]]
        then
                echo -n "You have entered wrong password, Enter it again:"
        else
                echo -n "Enter your password to access OpenStack:"
        fi
        read -s source_password
        export OS_PASSWORD="$source_password"
        credcheckcounter="1"
	echo ""
        nova credentials &>/dev/null
done


echo -n "Short Region Name to have this Hostname [fxbo,wbrn..]:"
read region_short
echo -n "What is the App name You are building[usm,ugc,media]:"
read app
echo -n "Which Env [prod,qa,int,stg]:"
read env_name

if [ $env_name == "prod" ] || [ $env_name == "Prod" ]
then
        env_name=""
fi

echo -n "Number of Tomcat Instances:"
read count_Tomcat


if [[ $count_Tomcat -gt 0 ]]
then
	Flavors_details
	echo -n "Tomcat Flavor ID from above [102,103]:"
	read tomcat_flavor
	
	if [[ $app == "media" ]]
	then
		echo -e -n "\tMedia required volume size [50,100]:"
        	read mediavolume_size
	fi
fi

echo -n "Number of Proxy Instances:"
read count_Proxy
echo -n "Number of Cassandra Instances:"
read count_Cassandra

if [[ $count_Cassandra -gt 0 ]]
then
	echo -e -n "\tCassandra volume size for data [50,100,150]:"
	read cassdatavolume_size
	echo -e -n "\tCassandra volume size for commitlogs [50,100,150]:"
	read casscommitvolume_size
fi

echo -n "Number of Sql Instances:"
read count_Sql

if [[ $count_Sql -gt 0 ]]
then
	echo -e -n "\tSql required volume size [50,100,150]:"
	read sqlvolume_size
fi

#
echo -n "Enter security group names seperated with comma:"
read security_groups
#
#
jumphostkey_name="jumphost-fxbo"
jumphostkey_location="/Users/rguntu002c/.ssh/jumphostfxbo_key"

echo -n "Enter Key-Pair Name:"
read key_name
echo -n "Enter Public Key location:"
read pubkey_location

isFileExist $pubkey_location

#echo -n "Post installation script location:"
#read post_script

post_script="/Users/rguntu002c/Documents/Comcast/github/SSD/scripts/puppet-install.sh"
#post_script="/var/tmp/postscript.sh"

variable_app="app"
variable_proxy="proxy"
variable_cassandra="cass"
variable_sql="sql"


proxy_flavor="102"
#tomcat_flavor="103"
cass_flavor="105"
sql_flavor="104"
image_name="39b67c74-4249-49ba-a359-aeec4fcc5470"  ## NETO CentOS 6.4

echo -n "Confirm to Build Instances [Yes/No]:"
read finalconfirmation
final_exitreason=" ******** Oops, you found something wrong and wanted to quit ********"
echo ""
IsConfirm "\${finalconfirmation}"  "\${final_exitreason}"

## Adding Your key Pair
echo "Creating Key Pair $key_name on Tenant"
AddKeyPair $pubkey_location $key_name

## Adding Jumphost key Pair
#echo "Also Adding $jumphostkey_name (96.119.2.172) Key on Tenant"
#AddKeyPair $jumphostkey_location $jumphostkey_name

if [[ $count_Tomcat -gt 0 ]]
then
	tomcat_host=$env_name$app$variable_app-$region_short
	echo "------------ Building Tomcat Instances: ------------"

#	for (( j=1; j<=$count_Tomcat; j++ ))
	for (( i=1; i<=$count_Tomcat; i++ ))
	do
		echo "Building Instance $i:"	

##		Use this below to use Hostnames number starting with different number
#		i=$[$j +2]

		nova boot --image $image_name --flavor $tomcat_flavor $tomcat_host-0$i.sys.comcast.net --security-groups $security_groups --key-name $key_name --user-data $post_script
   		echo " *** Waiting 15 Sec for instance to be ready *** "
                sleep 15
	
#               To create and attach Volume for Media ffmpeg
		if [[ $app == "media" ]]
		then
                	volume_desc="Media ffmpeg files"
                	Create_Volume $tomcat_host-0$i "\${volume_desc}" $mediavolume_size
                	Attach_Volume $tomcat_host-0$i.sys.comcast.net $volume_id "/dev/vdi"		
		fi 
	done
fi

if [[ $count_Proxy -gt 0 ]]
then
	proxy_host=$env_name$app$variable_proxy-$region_short
	echo "------------ Building Proxy Instances: ------------"

	for (( i=1; i<=$count_Proxy; i++ ))
	do
		echo "Building Proxy Instance $i:"	
		nova boot --image $image_name --flavor $proxy_flavor $proxy_host-0$i.sys.comcast.net --security-groups $security_groups --key-name $key_name --user-data $post_script
	done
fi


if [[ $count_Cassandra -gt 0 ]]
then
	cass_host=$env_name$app$variable_cassandra-$region_short
	echo "------------ Building Cassandra Instances: ------------"

	for (( i=1; i<=$count_Cassandra; i++ ))
	do	
		echo "Building Cassandra Instance $i:"	
		nova boot --image $image_name --flavor $cass_flavor $cass_host-0$i.sys.comcast.net --security-groups $security_groups --key-name $key_name --user-data $post_script

                echo " *** Waiting 15 Sec for instance to be ready *** "
                sleep 15

#		To create and attach Volume for Cassandra Data 
		volume_desc="Cassandra Data"	
		Create_Volume $cass_host-0$i "\${volume_desc}" $cassdatavolume_size
		Attach_Volume $cass_host-0$i.sys.comcast.net $volume_id "/dev/vdi"

#		To create and attach Volume for Cassandra Commit logs
		volume_desc="Cassandra Commit logs"
		Create_Volume commit-$cass_host-0$i "\${volume_desc}" $casscommitvolume_size
		Attach_Volume $cass_host-0$i.sys.comcast.net $volume_id "/dev/vdj"

	done
fi

if [[ $count_Sql -gt 0 ]]
then
	sql_host=$env_name$app$variable_sql-$region_short
	echo "------------ Building Sql Instances: ------------"

	for (( i=1; i<=$count_Sql; i++ ))
	do	
		echo "Building Sql Instance $i:"	
		nova boot --image $image_name --flavor $sql_flavor $sql_host-0$i.sys.comcast.net --security-groups $security_groups --key-name $key_name --user-data $post_script
                
		echo " *** Waiting 15 Sec for instance to be ready *** "
                sleep 15

#		To create and attach Volume for Sql data
		volume_desc="Sql data"
		Create_Volume $sql_host-0$i "\${volume_desc}" $sqlvolume_size
		Attach_Volume $sql_host-0$i.sys.comcast.net $volume_id "/dev/vdk"

	done
fi
