#!/bin/bash


file=$1
TEMPFILE=$file.tmp
if [ "x$file" = "x" ];
then
        echo "usage: $0 <filename>"
        exit 1
fi


regions=( gbr_fxbo  sea_burn  ndc_cmc_c  chic_emhr  ndc_cmc_d  ndc_wcdc_b  ndc_ch2_c  ndc_ch2_d  gbr_wbrn  chic_area4 )
#regions=( gbr_fxbo gbr_wbrn )

for Tenant in `ls *.sh| grep -v security|grep -v get` 
do
	. $Tenant
	echo "Sourcing $Tenant"
	for region in ${regions[@]}
	do
		 export OS_REGION_NAME="$region"
		 echo -e "\t exported $region"

		nova list > $TEMPFILE
		#echo -e "$Tenant:$region">> $file
		
		if [ $region == "gbr_fxbo" ] || [ $region == "chic_area4" ]
		then
			awk -F'|' {'print $3" "$7'} $TEMPFILE |egrep -v "Name\s*Networks|^\s*$" |sed  -e 's/^ //g'| sed -e "s/ .*Public_AGILE=\(.*\),.*$/:\1/g" >> $file
		else
		
			awk -F'|' {'print $3" "$7'} $TEMPFILE |egrep -v "Name\s*Networks|^\s*$"| sed  -e 's/^ //g'|sed -e 's/ .*,/:/g'|sed -e 's/ //g' >> $file
		#awk -F'|' {'print $3" "$7'} $TEMPFILE | egrep -v "Name\s*Networks|^\s*$" | sed  -e 's/^ //g' | sed -e 's/Public_AGILE.*,/:/g'|sed -e 's/ //g' >> $file
		fi
		#echo "" >>  $file
		rm $TEMPFILE
	done

done


#awk -F'|' {'print $3" "$7'} servers-pull-from-OS | egrep -v "Name\s*Networks|^\s*$" | sed -e 's/^ //g' | sed -e 's/Public_AGILE.*,/:/g'|sed -e 's/ //g'


