# VCFextractor
VCFextractor is a unix based software that requires no prerequisites to run.
This script will take any VCF file and output functional information from the file itself,
or from the ExAC rest api database http://exac.hms.harvard.edu 

## INSTALL
Download VCFextractor.sh  
chmod 750 VCFextractor.sh. 
export PATH=$PATH:/PATH/TO/VCFextractorDIRECTORY 

## RUN
To run VCFextractor simply call the following command in the terminal

COMMAND == VCFextractor.sh PATH/TO/FILE.vcf [OPTIONS] [OUTPUT]

## OPTIONS 
If not options are included, all options will be outputted

--INFO == Output from VCF chromosome(#CHROM), position(POS), reference allele(REF) and alternative allele(ALT)  
--Variant_Type == Output from VCF TYPE Variant Type(Variant_Type)  
--Total_Read_Depth == Output from VCF DP Total Read Depth(Total_Read_Depth)  
--Variant_Read_Depth == Output from VCF AO Variant Read Depth(Variant_Read_Depth)  
--Reference_Read_Depth == Output from VCF RO Reference Read Depth(Reference_Read_Depth)  
--Percentage_Variant_Reads == Output from VCF Percentage Variant Reads(Percentage_Variant_Reads)  
--Variant_Allele_Frequency == Output from VCF Variant Allele Frequency(Variant_Allele_Frequency)  
--ExAC_ALL or --ExAC_ordered_csqs == Output from ExAC Browser Variant Orderred Consequence(ExAC_ordered_csqs)  
--ExAC_ALL or --ExAC_allele_freq == Output from ExAC Browser Variant Allele Frequency(ExAC_allele_freq)  
--ExAC_ALL or --ExAC_rsid == Output from ExAC Browser Variant RSID(ExAC_rsid)  

## OUTPUT
-tsv == Tab separated file (default)  
-csv == Comma separated file

## EXAMPLE
VCFextractor.sh coding_challenge_final.vcf --Variant_Type --ExAC_ordered_csqs --Total_Read_Depth --Variant_Read_Depth --Percentage_Variant_Reads --Variant_Allele_Frequency --ExAC_allele_freq --ExAC_rsid --INFO -csv 
