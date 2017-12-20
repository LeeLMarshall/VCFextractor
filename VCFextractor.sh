#!/bin/bash
echo '--------------------------------------------------------------------------------'
echo '--------------------------------- VCFextractor ---------------------------------'
echo '--------------------------------------------------------------------------------'

#---------- Help Function
if [ "${1}" == "--help" -o "${1}" == "-help" -o "${1}" == "-h" ]
then
	echo '---------- VCFextractor HELP FUNCTION
VCFextractor is a unix based software that requires no prerequisites to run.
This script will take any VCF file and output functional information from the file itself,
or from the ExAC rest api database http://exac.hms.harvard.edu 

----- INSTALL
Download VCFextractor.sh  
chmod 750 VCFextractor.sh
export PATH=$PATH:/PATH/TO/VCFextractorDIRECTORY

----- RUN
To run VCFextractor simply call the following command in the terminal

COMMAND == VCFextractor.sh PATH/TO/FILE.vcf [OPTIONS] [OUTPUT]

----- OPTIONS 
If not options are included, all options will be outputted

--INFO == Output from VCF chromosome(#CHROM), position(POS), reference allele(REF) and alternative allele(ALT)
--TYPE or --Variant_Type == Output from VCF TYPE Variant Type(Variant_Type)
--DP or --Total_Read_Depth == Output from VCF DP Total Read Depth(Total_Read_Depth)
--AO or --Variant_Read_Depth == Output from VCF AO Variant Read Depth(Variant_Read_Depth)
--RO or --Reference_Read_Depth == Output from VCF RO Reference Read Depth(Reference_Read_Depth)
--AO/(AO+RO)x100 or --Percentage_Variant_Reads == Output from VCF Percentage Variant Reads(Percentage_Variant_Reads) 
--AO/DPx100 or --Variant_Allele_Frequency == Output from VCF Variant Allele Frequency(Variant_Allele_Frequency)
--ExAC_ALL or --ExAC_ordered_csqs == Output from ExAC Browser Variant Orderred Consequence(ExAC_ordered_csqs)
--ExAC_ALL or --ExAC_allele_freq == Output from ExAC Browser Variant Allele Frequency(ExAC_allele_freq)
--ExAC_ALL or --ExAC_rsid == Output from ExAC Browser Variant RSID(ExAC_rsid)

----- OUTPUT
-tsv == Tab separated file (default)
-csv == Comma separated file

----- EXAMPLE
VCFextractor.sh coding_challenge_final.vcf
'
	exit 0
#---------- Find VCF file
elif [[ "${1}" == *".vcf" ]]
then
	echo "---------- RUNNING VCFEXTRACTOR"
	FILE=`awk -v OFS='\t' -F'[\t]' '/^[a-zA-Z0-9]/ {gsub("chr","") ; print $0}' "${1}"`
	#---------- INFO
	if [ -z "${2}" ] || [[ "$@" == *"--INFO"* ]]
	then
		echo "INFO OUTPUTTED == #CHROM POS REF ALT"
		INFO=`awk -v OFS='\t' -F'[\t]' 'BEGIN{print "#CHROM", "POS", "REF", "ALT"} ; 
		{print $1, $2, $4, $5}' <(echo "${FILE}") \
		| awk -v OFS='\t' -F'[\t,]' '{ if ( $5 != "" ) {print $1, $2, $3, $4 ; 
		print $1, $2, $3, $5} else if ( $5 == "" ) print $0}'`
		if [ ! -f "${1}.tmp" ]
		then
			paste <(echo "${INFO}") > ${1}.tmp		
		else
			echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp"
			exit 0
		fi
	else
		echo "INFO NOT OUTPUTTED"
	fi
	#---------- TYPE
	if [ -z "${2}" ] || [[ "$@" == *"--TYPE"* ]] || [[ "$@" == *"--Variant_Type"* ]]
	then 
		echo "VARIANT TYPE OUTPUTTED == Variant_Type"
		TYPE=`awk -v OFS='\t' -F'[\t;]' 'BEGIN{print "Variant_Type"} ; 
		{for(i=1;i<=NF;i++) {if ($i ~ /^TYPE=/){print $i}}}' <(echo "${FILE}") \
		| awk -v OFS='\t' -F'[,]' '{gsub("TYPE=","") ;
		if ( $2 != "" )	{print $1 ; print $2} else if ( $2 == "" ) print $1}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${TYPE}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${TYPE}") > ${1}.tmp
		fi
	else
		echo "VARIANT TYPE NOT OUTPUTTED"
	fi
	#---------- TOTAL READ DEPTH
	if [ -z "${2}" ] || [[ "$@" == *"--DP"* ]] || [[ "$@" == *"--Total_Read_Depth"* ]]
	then 
		echo "TOTAL READ DEPTH OUTPUTTED == Total_Read_Depth"
		DEPTH=`awk -v OFS='\t' -F'[\t;]' 'BEGIN{print "Total_Read_Depth", "REF"} ; 
		{for(i=1;i<=NF;i++) {if ($i ~ /^DP=/){print $i, $5}}}' <(echo "${FILE}") \
		| awk -v OFS='\t' -F'[\t,]' '{gsub("DP=","") ; 
		if ( $3 != "" ) {print $1 ; print $1} else if ( $3 == "" ) print $1}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${DEPTH}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${DEPTH}") > ${1}.tmp
		fi
	else
		echo "TOTAL READ DEPTH NOT OUTPUTTED"
	fi
	#---------- VARIANT READ DEPTH
	if [ -z "${2}" ] || [[ "$@" == *"--AO"* ]] || [[ "$@" == *"--Variant_Read_Depth"* ]]
	then 
		echo "VARIANT READ DEPTH OUTPUTTED == Variant_Read_Depth"
		VARIANT=`awk -v OFS='\t' -F'[\t;]' 'BEGIN{print "Variant_Read_Depth"} ; 
		{for(i=1;i<=NF;i++)	{if ($i ~ /^AO=/) {print $i}}}' <(echo "${FILE}") \
		| awk -v OFS='\t' -F'[\t,]' '{gsub("AO=","") ; 
		if ( $2 != "" ) {print $1 ; print $2} else if ( $2 == "" ) print $1}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${VARIANT}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${VARIANT}") > ${1}.tmp
		fi
	else
		echo "VARIANT READ DEPTH NOT OUTPUTTED"
	fi
	#---------- REFERENCE READ DEPTH
	if [ -z "${2}" ] || [[ "$@" == *"--RO"* ]] || [[ "$@" == *"--Reference_Read_Depth"* ]]
	then 
		echo "REFERENCE READ DEPTH OUTPUTTED == Reference_Read_Depth"
		REFERENCE=`awk -v OFS='\t' -F'[\t;]' 'BEGIN{print "Reference_Read_Depth", "REF"} ; 
		{for(i=1;i<=NF;i++){if ($i ~ /^RO=/) {print $i, $5}}}' <(echo "${FILE}") \
		| awk -v OFS='\t' -F'[\t,]' '{gsub("RO=","") ; 
		if ( $3 != "" )	{print $1 ; print $1} else if ( $3 == "" ) print $1}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${REFERENCE}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${REFERENCE}") > ${1}.tmp
		fi
	else
		echo "REFERENCE READ DEPTH NOT OUTPUTTED"
	fi
	#---------- PERCENTAGE VARIANT READS
	if [ -z "${2}" ] || [[ "$@" == *"--AO/(AO+RO)x100"* ]] || [[ "$@" == *"--Percentage_Variant_Reads"* ]]
	then 
		echo "PERCENTAGE VARIANT READS OUTPUTTED == Percentage_Variant_Reads"
		PERCENTAGE=`awk -v OFS='\t' -F'[\t;]' '{for(i=1;i<=NF;i++) 
		{if ($i ~ /^AO=/ || $i ~ /^RO=/) {print $i}}}' <(echo "${FILE}") \
		| awk '{gsub("AO=","") ; printf $0 "\t" ; getline ; print $0}' \
		| awk -v OFS='\t' -F'[\t,]' 'BEGIN{print "Percentage_Variant_Reads"} ; 
		{gsub("RO=","") ; if ( $3 != "" ) {print $1/($1 + $3)*100 ; print $2/($2 + $3)*100}
		else if ( $3 == "" ) print $1/($1 + $2)*100}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${PERCENTAGE}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${PERCENTAGE}") > ${1}.tmp
		fi
	else
		echo "PERCENTAGE VARIANT READS NOT OUTPUTTED"
	fi
	#---------- VARIANT ALLELE FREQUENCY
	if [ -z "${2}" ] || [[ "$@" == *"--AO/DPx100"* ]] || [[ "$@" == *"--Variant_Allele_Frequency"* ]]
	then 
		echo "VARIANT ALLELE FREQUENCY OUTPUTTED == Variant_Allele_Frequency"
		FREQUENCY=`awk -v OFS='\t' -F'[\t;]' '{for(i=1;i<=NF;i++) 
		{if ($i ~ /^AO=/ || $i ~ /^DP=/) {print $i}}}' <(echo "${FILE}") \
		| awk '{gsub("AO=","") ; printf $0 "\t" ; getline ; print $0}' \
		| awk -v OFS='\t' -F'[\t,]' 'BEGIN{print "Variant_Allele_Frequency"} ; 
		{gsub("DP=","") ; if ( $3 != "" ) {print $1/$3*100 ; print $2/$3*100}
		else if ( $3 == "" ) print $1/$2*100}'`
		if [ -f "${1}.tmp" ]
		then
			paste ${1}.tmp <(echo "${FREQUENCY}") > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
		else 
			paste <(echo "${FREQUENCY}") > ${1}.tmp
		fi
	else
		echo "VARIANT ALLELE FREQUENCY NOT OUTPUTTED"
	fi
	#---------- ExAC
	if [ -z "${2}" ] || [[ "$@" == *"--ExAC"* ]] 
	then
		echo "ExAC BROWSER QUERIED"
		if [ ! -f "${1}.tmp.exac" ]
		then
			awk -v OFS='\t' -F'[\t]' '{print $1, $2, $4, $5}' <(echo "${FILE}") \
			| awk -v OFS='-' -F'[\t,]' '{ if ( $5 != "" ) {print $1, $2, $3, $4 ; 
			print $1, $2, $3, $5} else if ( $5 == "" ) print $1, $2, $3, $4}' > ${1}.tmp.exac
		else
			echo "[[ERROR]] ExAC TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac"
			exit 0	
		fi
		#---------- ExAC VARIANT ORDERED CONSEQUENCE
		if [ -z "${2}" ] || [[ "$@" == *"--ExAC_ALL"* ]] || [[ "$@" == *"--ExAC_ordered_csqs"* ]]
		then 
			echo "ExAC VARIANT ORDERED CONSEQUENCE OUTPUTTED == ExAC_ordered_csqs"
			if [ ! -f "${1}.tmp.exac1" ]
			then
				for i in `cat ${1}.tmp.exac` ; do
					curl -s -w "\n" -H 'Accept: application/json' -H 'Content-Type: application/json' \
					http://exac.hms.harvard.edu/rest/variant/ordered_csqs/${i} \
					| awk -v OFS='\t' -F'["]' '{print $4}' >> ${1}.tmp.exac1
				done
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac1"
				exit 0
			fi
			if [ ! -f "${1}.tmp.exac2" ]
			then
				awk 'BEGIN{print "ExAC_ordered_csqs"} ; {print}' ${1}.tmp.exac1 > ${1}.tmp.exac2
				mv ${1}.tmp.exac2 ${1}.tmp.exac1
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac2"
				exit 0
			fi
			if [ -f "${1}.tmp" ]
			then
				paste ${1}.tmp ${1}.tmp.exac1 > ${1}.tmp1
				mv ${1}.tmp1 ${1}.tmp.exac1 
				mv ${1}.tmp.exac1 ${1}.tmp
			else
				mv ${1}.tmp.exac1 ${1}.tmp
			fi
		else
			echo "ExAC VARIANT ORDERED CONSEQUENCE NOT OUTPUTTED"
		fi
		#---------- ExAC VARIANT ALLELE FREQUENCY
		if [ -z "${2}" ] || [[ "$@" == *"--ExAC_ALL"* ]] || [[ "$@" == *"--ExAC_allele_freq"* ]]
		then 
			echo "ExAC VARIANT ALLELE FREQUENCY OUTPUTTED == ExAC_allele_freq"
			if [ ! -f "${1}.tmp.exac1" ]
			then
				for i in `cat ${1}.tmp.exac` ; do
					curl -s -w "\n" -H 'Accept: application/json' -H 'Content-Type: application/json' \
					http://exac.hms.harvard.edu/rest/variant/${i} \
					| awk -v OFS='\t' -F'[",]' '{for(i=1;i<=NF;i++) {if ($i ~ /^allele_freq/) print $(i+1)}} 
					!/allele_freq/{print ""}' | awk '{print $NF}' >> ${1}.tmp.exac1
				done
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac1"
				exit 0
			fi
			if [ ! -f "${1}.tmp.exac2" ]
			then
				awk 'BEGIN{print "ExAC_allele_freq"} ; {print}' ${1}.tmp.exac1 > ${1}.tmp.exac2
				mv ${1}.tmp.exac2 ${1}.tmp.exac1
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac2"
				exit 0
			fi
			if [ -f "${1}.tmp" ]
			then
				paste ${1}.tmp ${1}.tmp.exac1 > ${1}.tmp1
				mv ${1}.tmp1 ${1}.tmp.exac1 
				mv ${1}.tmp.exac1 ${1}.tmp
			else
				mv ${1}.tmp.exac1 ${1}.tmp
			fi
		else
			echo "ExAC VARIANT ALLELE FREQUENCY NOT OUTPUTTED"
		fi
		#---------- ExAC VARIANT RSID
		if [ -z "${2}" ] || [[ "$@" == *"--ExAC_ALL"* ]] || [[ "$@" == *"--ExAC_rsid"* ]]
		then 
			echo "ExAC VARIANT RSID OUTPUTTED == ExAC_rsid"
			if [ ! -f "${1}.tmp.exac1" ]
			then
				for i in `cat ${1}.tmp.exac` ; do
					curl -s -w "\n" -H 'Accept: application/json' -H 'Content-Type: application/json' \
					http://exac.hms.harvard.edu/rest/variant/${i} \
					| awk -v OFS='\t' -F'[",]' '{for(i=1;i<=NF;i++) {if ($i ~ /^rsid/) print $(i+2)}}
					!/rsid/{print ""}' >> ${1}.tmp.exac1
				done
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac1"
				exit 0
			fi
			if [ ! -f "${1}.tmp.exac2" ]
			then
				awk 'BEGIN{print "ExAC_rsid"} ; {print}' ${1}.tmp.exac1 > ${1}.tmp.exac2
				mv ${1}.tmp.exac2 ${1}.tmp.exac1
			else
				echo "[[ERROR]] TMP FILE FOUND FROM PREVIOUS RUN ${1}.tmp.exac2"
				exit 0
			fi
			if [ -f "${1}.tmp" ]
			then
				paste ${1}.tmp ${1}.tmp.exac1 > ${1}.tmp1
				mv ${1}.tmp1 ${1}.tmp.exac1 
				mv ${1}.tmp.exac1 ${1}.tmp
			else
				mv ${1}.tmp.exac1 ${1}.tmp
			fi
		else
			echo "ExAC VARIANT RSID NOT OUTPUTTED"
		fi
		#---------- REMOVE ${1}.tmp.exac
		if [ -f "${1}.tmp.exac" ]
		then
			mv ${1}.tmp ${1}.tmp.exac
			mv ${1}.tmp.exac ${1}.tmp
		else
			echo "[[ERROR]] FAILED TO CREATE ${1}.tmp.exac"
			exit 0
		fi
	else
		echo "ExAC BROWSER NOT QUERIED"
	fi
	#---------- CREATE ${1}.tsv
	if [ -f "${1}.tmp" ]
	then
		echo "CONVERTING TO FILE FORMAT"
		if [[ "$@" == *"-tsv"* ]]
		then
			echo "FILE FORMAT TSV"
			mv ${1}.tmp ${1}.tsv
			echo "OUTPUT == ${1}.tsv"
		elif [[ "$@" == *"-csv"* ]]
		then
			echo "FILE FORMAT CSV"
			awk -v OFS=',' -F'\t' '{print $0}' ${1}.tmp > ${1}.tmp1
			mv ${1}.tmp1 ${1}.tmp
			mv ${1}.tmp ${1}.csv
			echo "OUTPUT == ${1}.csv"
		else
			echo "FILE FORMAT DEFAULTED TO TSV"
			mv ${1}.tmp ${1}.tsv
			echo "OUTPUT == ${1}.tsv"		
		fi
echo '--------------------------------------------------------------------------------'
echo '----------------------------- VCFextractor FINISHED ----------------------------'
echo '--------------------------------------------------------------------------------'
	else
		echo "[[ERROR]] FAILED TO ASK FOR OUTPUT"
	fi
else
	echo "[[ERROR]] VCF FILE NOT FOUND"
	exit 0
fi
