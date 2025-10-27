#!/bin/env/bash

#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"

#HOSPITALISATION CHECK
#Compare participants with hospitalisation record with hospitalisation data source as found by data-field 191495 (J45) and 191497 (J47)
#Data-field 191495 and 191497 use data-coding 2171. For hospitalisation we need data-coding equal to '40' and '41'.

#import datafield:
mkdir biobank_ukb50689
cd ${PATH_DATA}/biobank_ukb50689
biobank import ${PATH_APPL}/ukb50689.csv
biobank exclude ${PATH_APPL}/w56607_*.csv
biobank select 131495 131497 --output ${PATH_DATA}/Source_of_report_of_J45_J46_131495_131497.csv

#participant in 131495 for code '40' and '41' present in my hospitalisation asthma diagnosis:
 awk -F "," '{ if ($2 == 40 || $2 == 41) print $1}' ${PATH_DATA}/Source_of_report_of_J45_J46_131495_131497.csv | \
     grep -o -w -F -f - ${PATH_OUTPUT}/QC_hesin_diag_asthma.txt | sort -u > ${PATH_DATA}/131495_40_41_in_hesin_diag_asthma.txt

#participant in 131497 for code '40' and '41' present in my hospitalisation asthma diagnosis:
 awk -F "," '{ if ($3 == 40 || $3 == 41) print $1}' ${PATH_DATA}/Source_of_report_of_J45_J46_131495_131497.csv | \
     grep -o -w -F -f - ${PATH_OUTPUT}/QC_hesin_diag_asthma.txt | sort -u > ${PATH_DATA}/131497_40_41_in_hesin_diag_asthma.txt


#COMPARISON MY ASTHMA DIAGNOSIS DEFINITION WITH DATE OF ASTHMA REPORT (DATAFIELD 42014) AND SOURCE OF FIRST ASTHMA REPORT (DATAFIELD 131495, 131497)
#extract the datafields with the other asthma phenotype definition
# use biobank package, select the datafields of interest (41014) and save in a file
cd ${PATH_DATA}
biobank select 42014 --output ${PATH_DATA}/Date_of_asthma_report_42014.csv
#REMOVE WITHDRAWNS FOR APPLICATION 55607:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/Date_of_asthma_report_42014.csv > \
    ${PATH_DATA}/QC_Date_of_asthma_report_42014.csv
rm ${PATH_DATA}/Date_of_asthma_report_42014.csv
#131495, 131497 ALREADY IMPORTED - see 'HOSPITALISATION CHECK' SECTION


#Actual comparison analysis in R with venn diagram:
chmod ${PATH_SCRIPT}/Comparison_asthma_phenotypes.r
module load R
Rscript ${PATH_SCRIPT}/Comparison_asthma_phenotypes.r

#COMPARE INITIAL DATAFIELD FILES FOR EACH DATAFIELDS/DIAGNOSIS TYPE USED IN THE ANALYSIS:
#Not sure that initial number of participants is the same for each file:
wc -l /rfs/TobinGroup/data/UKBiobank/application_56607/ukb*.csv
#    502494 /rfs/TobinGroup/data/UKBiobank/application_56607/ukb44204.csv
#    502443 /rfs/TobinGroup/data/UKBiobank/application_56607/ukb48371.csv
#    502412 /rfs/TobinGroup/data/UKBiobank/application_56607/ukb50689.csv
#    1507349 total


#COMPARE MY CLINICAL CODES FOR ASTHMA WITH RICHARD PACKER's CLINICAL CODES:
#on my local laptop:
# scp /home/noemipiga/Documents/PhD/Severe_Asthma_Project/COPD_clinicalcodes_codes_rated.csv \
#     nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
#scp /home/noemipiga/Documents/PhD/Severe_Asthma_Project/asthma_codes_rated.csv \
#    nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
#scp /home/noemipiga/Documents/PhD/Severe_Asthma_Project/emphysema_codes_rated.csv \
#    nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/

#ASTHMA and EMPHYSEMA/Chronic bronchitis
bash ${PATH_SCRIPT}/asthma_ecb_diagnosis_RP_clinicalcodes.sh