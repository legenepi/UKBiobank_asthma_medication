#!/bin/env/bash

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_SA_DATA="/data/gen1/UKBiobank_500K/severe_asthma/data"

#ASTHMA
#split RP's codes into V2 - CTV3 - ICD10 - ICD9
awk -F "," '{if ($6 == "V2") print $4}' ${PATH_DATA}/asthma_codes_rated.csv > ${PATH_DATA}/V2_asthma_codes_rated.csv
awk -F "," '{if ($6 == "V3") print $4}' ${PATH_DATA}/asthma_codes_rated.csv > ${PATH_DATA}/V3_asthma_codes_rated.csv
grep "ICD10\|MD\|cancer" ${PATH_DATA}/asthma_codes_rated.csv | awk -F "," '{print $4}' \
    > ${PATH_DATA}/ICD10_asthma_codes_rated.csv
grep "ICD9" ${PATH_DATA}/asthma_codes_rated.csv | awk -F "," '{print $4}' \
    > ${PATH_DATA}/ICD9_asthma_codes_rated.csv
#Retrieve ICD-9 and ICD-10 clinical codes: (not sure I need this, to be deleted)
#awk -F "," '{if ($1 == "ICD 9") print $2}' ${PATH_DATA}/AsthmaP2_algorithm_outcome_codes.csv \
#    > ${PATH_DATA}/ICD9_AsthmaP2_algorithm_outcome_codes
#awk -F "," '{if ($1 == "ICD 10") print $2}' ${PATH_DATA}/AsthmaP2_algorithm_outcome_codes.csv \
#   > ${PATH_DATA}/ICD10_AsthmaP2_algorithm_outcome_codes
#module load R
#Rscript ${PATH_SCRIPT}/comparison_clinical_codes_RP.R

#FROM SELF-REPORTED asthma datafield 20002:
grep "SR" ${PATH_DATA}/asthma_codes_rated.csv | awk -F "," '{print $4}' > ${PATH_DATA}/SR_asthma_codes_rated.csv
cd ${PATH_SA_DATA}/
biobank select 20002 --output ${PATH_DATA}/selfreported_20002.txt
grep -w -F -f ${PATH_DATA}/SR_asthma_codes_rated.csv ${PATH_DATA}/selfreported_20002.txt \
    > ${PATH_DATA}/RP_asthma_selfreported_20002.txt
cd ${PATH_SCRIPT}/
#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_asthma_selfreported_20002.txt \
    > ${PATH_DATA}/QC_RP_asthma_selfreported_20002.txt
rm ${PATH_DATA}/RP_asthma_selfreported_20002.txt

awk -F "," {'print $1'} ${PATH_DATA}/QC_RP_asthma_selfreported_20002.txt \
    > ${PATH_DATA}/eid_QC_RP_asthma_selfreported_20002.txt

#FROM PRIMARY CARE CLINICAL RECORDS (Readv2 and ReadCTV3)
#Filter for Readv2 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/V2_asthma_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/primary_care/gp_clinical.txt \
     > ${PATH_DATA}/RP_Readv2_asthma_gp_clinical.txt

#Filter	for ReadCTV3 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/V3_asthma_codes_rated.csv -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - ${PATH_APPL}/primary_care/gp_clinical.txt > ${PATH_DATA}/RP_ReadCTV3_asthma_gp_clinical.txt

#Merge results from Readv2 and ReadCTV3:
cat ${PATH_DATA}/RP_Readv2_asthma_gp_clinical.txt ${PATH_DATA}/RP_ReadCTV3_asthma_gp_clinical.txt | \
    sort -u > ${PATH_DATA}/RP_asthma_gp_clinical.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_asthma_gp_clinical.txt \
    > ${PATH_DATA}/QC_RP_asthma_gp_clinical.txt
rm ${PATH_DATA}/RP_asthma_gp_clinical.txt

awk {'print $1'} ${PATH_DATA}/QC_RP_asthma_gp_clinical.txt | sort -u > ${PATH_DATA}/eid_QC_RP_asthma_gp_clinical.txt


#FROM HES RECORDS FOR ASTHMA (including all levels, level 1, level 2)
#use of ICD-9 and ICD-10 codes
awk -F "\t" '{print $7}' ${PATH_APPL}/hes/hesin_diag.txt | \
    grep -w -F -f ${PATH_DATA}/ICD10_asthma_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/hes/hesin_diag.txt \
    > ${PATH_DATA}/ICD10_RP_hesin_diag_asthma.txt

awk -F "\t" '{print $5}' ${PATH_APPL}/hes/hesin_diag.txt | \
    grep -w -F -f ${PATH_DATA}/ICD9_asthma_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/hes/hesin_diag.txt \
    > ${PATH_DATA}/ICD9_RP_hesin_diag_asthma.txt

cat ${PATH_DATA}/ICD9_RP_hesin_diag_asthma.txt ${PATH_DATA}/ICD10_RP_hesin_diag_asthma.txt | sort -u \
    > ${PATH_DATA}/RP_hesin_diag_asthma.txt

##Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_hesin_diag_asthma.txt \
    > ${PATH_DATA}/QC_RP_hesin_diag_asthma.txt
rm ${PATH_DATA}/RP_hesin_diag_asthma.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_hesin_diag_asthma.txt | sort -u > ${PATH_DATA}/eid_QC_RP_hesin_diag_asthma.txt

#FROM CAUSE of DEATH
#PRIMARY CAUSE - field 40001
grep -w -F -f ${PATH_DATA}/ICD10_asthma_codes_rated.csv ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt \
    > ${PATH_DATA}/QC_RP_asthma_PrimaryCauseOfDeath_40001.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_asthma_PrimaryCauseOfDeath_40001.txt \
    > ${PATH_DATA}/eid_QC_RP_asthma_PrimaryCauseOfDeath_40001.txt

#SECONDARY CAUSE - field 40002
grep -w -F -f ${PATH_DATA}/ICD10_asthma_codes_rated.csv ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt \
    > ${PATH_DATA}/QC_RP_asthma_SecondaryCauseOfDeath_40002.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_asthma_SecondaryCauseOfDeath_40002.txt \
    > ${PATH_DATA}/eid_QC_RP_asthma_SecondaryCauseOfDeath_40002.txt

#unique number of individuals
cat ${PATH_DATA}/eid_QC_RP_asthma_selfreported_20002.txt \
    ${PATH_DATA}/eid_QC_RP_asthma_gp_clinical.txt \
    ${PATH_DATA}/eid_QC_RP_hesin_diag_asthma.txt \
    ${PATH_DATA}/eid_QC_RP_asthma_PrimaryCauseOfDeath_40001.txt \
    ${PATH_DATA}/eid_QC_RP_asthma_SecondaryCauseOfDeath_40002.txt | sort -u > ${PATH_DATA}/eid_QC_RP_asthma.txt

#EMPHYSEMA/CHRONIC BRONCHITIS (COPD clinical codes)
#split RP's codes into V2 - CTV3 - ICD10 - ICD9
awk -F "," '{if ($6 == "V2") print $4}' ${PATH_DATA}/COPD_clinicalcodes_codes_rated.csv > ${PATH_DATA}/V2_COPD_codes_rated.csv
awk -F "," '{if ($6 == "V3") print $4}' ${PATH_DATA}/COPD_clinicalcodes_codes_rated.csv > ${PATH_DATA}/V3_COPD_codes_rated.csv
grep "ICD10\|MD\|cancer" ${PATH_DATA}/COPD_clinicalcodes_codes_rated.csv | awk -F "," '{print $4}' \
    > ${PATH_DATA}/ICD10_COPD_codes_rated.csv
grep "ICD9" ${PATH_DATA}/COPD_clinicalcodes_codes_rated.csv | awk -F "," '{print $4}' \
    > ${PATH_DATA}/ICD9_COPD_codes_rated.csv

#FROM SELF-REPORTED DOCTOR DIAGNOSED EMPHYSEMA/CHRONIC BRONCHITIS
grep "SR" ${PATH_DATA}/COPD_clinicalcodes_codes_rated.csv | awk -F "," '{print $4}' > ${PATH_DATA}/SR_COPD_codes_rated.csv
grep -w -F -f ${PATH_DATA}/SR_COPD_codes_rated.csv ${PATH_DATA}/selfreported_20002.txt \
    > ${PATH_DATA}/RP_ecb_selfreported_20002.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_ecb_selfreported_20002.txt \
    > ${PATH_DATA}/QC_RP_ecb_selfreported_20002.txt
rm ${PATH_DATA}/RP_ecb_selfreported_20002.txt

awk -F "," {'print $1'} ${PATH_DATA}/QC_RP_ecb_selfreported_20002.txt | sort -u \
    > ${PATH_DATA}/eid_QC_RP_ecb_selfreported_20002.txt


#FROM PRIMARY CARE CLINICAL RECORDS (Readv2 and ReadCTV3)
#Filter for Readv2 COPD clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/V2_COPD_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/primary_care/gp_clinical.txt \
     > ${PATH_DATA}/RP_Readv2_ecb_gp_clinical.txt

#Filter	for ReadCTV3 COPD clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/V3_COPD_codes_rated.csv -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - ${PATH_APPL}/primary_care/gp_clinical.txt > ${PATH_DATA}/RP_ReadCTV3_ecb_gp_clinical.txt

#Merge results from Readv2 and ReadCTV3:
cat ${PATH_DATA}/RP_Readv2_ecb_gp_clinical.txt ${PATH_DATA}/RP_ReadCTV3_ecb_gp_clinical.txt | \
    sort -u > ${PATH_DATA}/RP_ecb_gp_clinical.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_ecb_gp_clinical.txt \
    > ${PATH_DATA}/QC_RP_ecb_gp_clinical.txt
rm ${PATH_DATA}/RP_ecb_gp_clinical.txt

awk {'print $1'} ${PATH_DATA}/QC_RP_ecb_gp_clinical.txt | sort -u > ${PATH_DATA}/eid_QC_RP_ecb_gp_clinical.txt

#5.FROM HES RECORDS FOR COPD (including all levels, level 1, level 2)
#use of ICD-9 and ICD-10 codes
awk -F "\t" '{print $7}' ${PATH_APPL}/hes/hesin_diag.txt | \
    grep -w -F -f ${PATH_DATA}/ICD10_COPD_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/hes/hesin_diag.txt \
    > ${PATH_DATA}/ICD10_RP_hesin_diag_ecb.txt

awk -F "\t" '{print $5}' ${PATH_APPL}/hes/hesin_diag.txt | \
    grep -w -F -f ${PATH_DATA}/ICD9_COPD_codes_rated.csv -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/hes/hesin_diag.txt \
    > ${PATH_DATA}/ICD9_RP_hesin_diag_ecb.txt

cat ${PATH_DATA}/ICD9_RP_hesin_diag_ecb.txt ${PATH_DATA}/ICD10_RP_hesin_diag_ecb.txt | sort -u \
    > ${PATH_DATA}/RP_hesin_diag_ecb.txt

##Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/RP_hesin_diag_ecb.txt \
   > ${PATH_DATA}/QC_RP_hesin_diag_ecb.txt
rm ${PATH_DATA}/RP_hesin_diag_ecb.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_hesin_diag_ecb.txt > ${PATH_DATA}/eid_QC_RP_hesin_diag_ecb.txt

#6.FROM CAUSE of DEATH
#PRIMARY CAUSE - field 40001
grep -w -F -f ${PATH_DATA}/ICD10_COPD_codes_rated.csv ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt \
    > ${PATH_DATA}/QC_RP_ecb_PrimaryCauseOfDeath_40001.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_ecb_PrimaryCauseOfDeath_40001.txt \
    > ${PATH_DATA}/eid_QC_RP_ecb_PrimaryCauseOfDeath_40001.txt

#SECONDARY CAUSE - field 40002
grep -w -F -f ${PATH_DATA}/ICD10_COPD_codes_rated.csv ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt \
    > ${PATH_DATA}/QC_RP_ecb_SecondaryCauseOfDeath_40002.txt

awk '{print $1}' ${PATH_DATA}/QC_RP_ecb_SecondaryCauseOfDeath_40002.txt \
    > ${PATH_DATA}/eid_QC_RP_ecb_SecondaryCauseOfDeath_40002.txt

#unique number of individuals
cat ${PATH_DATA}/eid_QC_RP_ecb_selfreported_20002.txt \
    ${PATH_DATA}/eid_QC_RP_ecb_gp_clinical.txt \
    ${PATH_DATA}/eid_QC_RP_hesin_diag_ecb.txt \
    ${PATH_DATA}/eid_QC_RP_ecb_PrimaryCauseOfDeath_40001.txt \
    ${PATH_DATA}/eid_QC_RP_ecb_SecondaryCauseOfDeath_40002.txt | sort -u > ${PATH_DATA}/eid_QC_RP_ecb.txt

#Run Rscripts:
chmod o+x ${PATH_SCRIPT}/comparison_clinical_codes_RP.R
chmod o+x ${PATH_SCRIPT}/comparison_parts.R
module load R
Rscript ${PATH_SCRIPT}/comparison_clinical_codes_RP.R
Rscript ${PATH_SCRIPT}/comparison_parts.R

#Move data in output/ :
mv -t ${PATH_OUTPUT}/ \
    ${PATH_DATA}/eid_QC_RP_ecb.txt \
    ${PATH_DATA}/eid_QC_RP_asthma.txt