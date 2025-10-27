#!/bin/env/bash

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_SA_DATA="/data/gen1/UKBiobank_500K/severe_asthma/data"

###########
# Data:
#Datasets for application 56607:
#/rfs/TobinGroup/data/UKBiobank/application_56607/ukb50689.csv -including only asthma amalgamated datafields
#/rfs/TobinGroup/data/UKBiobank/application_56607/ukb48371.csv
#/rfs/TobinGroup/data/UKBiobank/application_56607/ukb44204.csv
#Previous Master table with useful information for genotyped participants only:
#/data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample

#####################

#Create datasets with good quality participants:

##Using the update list of withdrawns:
cat /rfs/TobinGroup/data/UKBiobank/application_56607/w56607_*.csv | sort -u > ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt
dos2unix ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt

#1.FROM SELF-REPORTED DOCTOR DIAGNOSED ASTHMA
#field 6152 -Blood clot, DVT, bronchitis, emphysema, asthma, rhinitis, eczema, allergy diagnosed by doctor- in ukb48371.csv; code 8 is for asthma:
#ACE touchscreen question "Has a doctor ever told you that you have had any of the following conditions? (You can select more than one answer)"
cut -d "," -f 2- /rfs/TobinGroup/data/UKBiobank/application_56607/self_reported_6152.csv | \
    grep -w "8" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - \
    /rfs/TobinGroup/data/UKBiobank/application_56607/self_reported_6152.csv \
    > ${PATH_DATA}/asthma_selfrepdocdiagnosed_6152.txt
#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/asthma_selfrepdocdiagnosed_6152.txt \
    > ${PATH_DATA}/QC_asthma_selfrepdocdiagnosed_6152.txt
rm ${PATH_DATA}/asthma_selfrepdocdiagnosed_6152.txt


#field 22127 -Doctor diagnosed asthma- in ukb44204.csv;
#User asked "Has a doctor ever told you that you have had any of the conditions below?" "asthma" was one of the options listed.
cut -d "," -f 2- /rfs/TobinGroup/data/UKBiobank/application_56607/self_reported_22127.csv | \
    grep -w "1" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - \
    /rfs/TobinGroup/data/UKBiobank/application_56607/self_reported_22127.csv > ${PATH_DATA}/asthma_selfrepdocdiagnosed_22127.txt
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/asthma_selfrepdocdiagnosed_22127.txt > \
    ${PATH_DATA}/QC_asthma_selfrepdocdiagnosed_22127.txt
rm ${PATH_DATA}/asthma_selfrepdocdiagnosed_22127.txt


#2.FROM PRIMARY CARE CLINICAL RECORDS (Readv2 and ReadCTV3)
#List of read v2 codes for asthma from the Asthma-P2 algorithm outcome codes-Category 42:

xlsx2csv ${PATH_DATA}/algorithm_outcome_codes.xlsx -n 'Asthma - P2' | grep '^ICD 9*\|^ICD 10*\|^Read*\|^UK B*' \
    > ${PATH_DATA}/AsthmaP2_algorithm_outcome_codes.csv
awk -F "," '{if ($1 == "Read V2") print $2}' ${PATH_DATA}/AsthmaP2_algorithm_outcome_codes.csv \
    > ${PATH_DATA}/Readv2_AsthmaP2_algorithm_outcome_codes

#List of read CTV3 codes from matching with Read v2 codes:
xlsx2csv ${PATH_DATA}/all_lkps_maps_v3.xlsx -n 'read_v2_read_ctv3' | awk -F "," '{print $2}' | \
grep -w -F -f ${PATH_DATA}/Readv2_AsthmaP2_algorithm_outcome_codes -n | awk -F ":" '{print $1}' \
> ${PATH_DATA}/rowidx_read_v2_read_ctv3.txt
xlsx2csv ${PATH_DATA}/all_lkps_maps_v3.xlsx -n 'read_v2_read_ctv3' | awk -F "," 'NR==FNR{ pos[$1]; next }FNR in pos' \
${PATH_DATA}/rowidx_read_v2_read_ctv3.txt - | sed  's/, [a-zA-Z0-9_]/ /g' | awk -F "," '{print $7}' | \
sort -u > ${PATH_DATA}/ReadCTV3_Asthma_codes
#print all the cols to have it as supplementary material in onedrive:
xlsx2csv ${PATH_DATA}/all_lkps_maps_v3.xlsx -n 'read_v2_read_ctv3' | awk -F "," 'NR==FNR{ pos[$1]; next }FNR in pos' \
${PATH_DATA}/rowidx_read_v2_read_ctv3.txt - | sort -u > ${PATH_DATA}/ReadCTV3_mapped_to_Readv2_Asthma_codes.txt

#Filter for Readv2 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} /rfs/TobinGroup/data/UKBiobank/application_56607/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/Readv2_AsthmaP2_algorithm_outcome_codes -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - /rfs/TobinGroup/data/UKBiobank/application_56607/primary_care/gp_clinical.txt \
     > ${PATH_DATA}/Readv2_asthma_gp_clinical.txt

#Filter	for ReadCTV3 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} /rfs/TobinGroup/data/UKBiobank/application_56607/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/ReadCTV3_Asthma_codes -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - /rfs/TobinGroup/data/UKBiobank/application_56607/primary_care/gp_clinical.txt > ${PATH_DATA}/ReadCTV3_asthma_gp_clinical.txt

#Merge results from Readv2 and ReadCTV3:
cat ${PATH_DATA}/Readv2_asthma_gp_clinical.txt ${PATH_DATA}/ReadCTV3_asthma_gp_clinical.txt | \
    sort -u > ${PATH_DATA}/asthma_gp_clinical.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/asthma_gp_clinical.txt \
    > ${PATH_DATA}/QC_asthma_gp_clinical.txt
rm ${PATH_DATA}/asthma_gp_clinical.txt


#3.FROM HES RECORDS FOR ASTHMA (including all levels, level 1, level 2)
#use of ICD-9 and ICD-10 codes
module load python
python ${PATH_SCRIPT}/SA_UKBiobank_datafields_analysis_hospitalisation.py

##Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/hesin_diag_asthma.txt \
    > ${PATH_DATA}/QC_hesin_diag_asthma.txt
rm ${PATH_DATA}/hesin_diag_asthma.txt

#4.FROM CAUSE of DEATH
## using of Altaf's ukbiobank tool python package:
### import ukbiobank genotyped dataset with all the fields for application 56607:
#want to have the parquet file in data folder: '--force' because I already have an imported ukb file and I have to update it
cd  ${PATH_SA_DATA}
biobank import --force /rfs/TobinGroup/data/UKBiobank/application_56607/ukb48371.csv

### exclude withdrawn participants:
biobank exclude /rfs/TobinGroup/data/UKBiobank/application_56607/w56607_*.csv

#ICD_10 code
#PRIMARY CAUSE - field 40001
## using of Altaf's ukbiobank tool python package:
### select fields I need: 40001
biobank select 40001 --output ${PATH_DATA}/PrimaryCauseOfDeath_40001.csv
sed 's/,/        /g' ${PATH_DATA}/PrimaryCauseOfDeath_40001.csv > ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt
grep "J45\|J46" ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt > ${PATH_DATA}/QC_asthma_PrimaryCauseOfDeath_40001.txt
rm ${PATH_DATA}/PrimaryCauseOfDeath_40001.csv

#SECONDARY CAUSE - field 40002
## using of Altaf's ukbiobank tool python package:
### select fields I need: 40002
cd ${PATH_DATA}
biobank select 40002 --output ${PATH_DATA}/SecondaryCauseOfDeath_40002.csv
sed 's/,/        /g' ${PATH_DATA}/SecondaryCauseOfDeath_40002.csv > ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt
grep "J45\|J46" ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt > ${PATH_DATA}/QC_asthma_SecondaryCauseOfDeath_40002.txt
rm ${PATH_DATA}/SecondaryCauseOfDeath_40002.csv

#return in scripts folder:
cd ${PATH_SCRIPT}

#Compare the different approaches with a venn diagram and obtain the list of eid of participants shared for each possible intersection:
#Putting also participants with self-reported doctor diagnosed emphysema/chronic bronchitis to have it in the Venn diagram and then exclude them
#chmod +x Comparison_asthma_diagnosis.r

module load R
Rscript ${PATH_SCRIPT}/Comparison_asthma_diagnosis.r

#Retrieve all participants with at least one line of evidence:
grep -v "^[A-Za-z]" ${PATH_DATA}/Eid_intersection_asthma_diagnosis.txt |
    grep -w -v -F -f  ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt \
    > ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt

#Exclude participants without genotype data using ukbiobank_master_app56607.sample:
awk -F " " '{print $52}' /data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample | tail -n +2 | \
  awk -F "." '{print $1}' | grep -F -f - ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt > \
      ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence_genotyped.txt

#Find participants with self-reported doctor diagnosed emphysema/chronic bronchitis:
#Not excluded yet-exclude them in Meds_stratification.sh pipeline:
bash ${PATH_SCRIPT}/emphysema_chronicbronchitis_diagnosis.sh

bash ${PATH_SCRIPT}/asthma_ecb_diagnosis_RP_clinicalcodes.sh

#List of all medication for primary care prescription for participants with diagnosed asthma:
qsub ${PATH_SCRIPT}/Medication_list.sh

#Move output files into output folder:
mv -t ${PATH_OUTPUT}/ ${PATH_DATA}/QC_asthma_selfrepdocdiagnosed_22127.txt \
    ${PATH_DATA}/QC_asthma_selfrepdocdiagnosed_6152.txt \
    ${PATH_DATA}/QC_asthma_gp_clinical.txt \
    ${PATH_DATA}/QC_hesin_diag_asthma.txt \
    ${PATH_DATA}/QC_asthma_PrimaryCauseOfDeath_40001.txt \
    ${PATH_DATA}/QC_asthma_SecondaryCauseOfDeath_40002.txt \
    ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence_genotyped.txt \
    ${PATH_DATA}/Venn_asthma_diagnosis.png \
    ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt \
    ${PATH_DATA}/UpSet_asthma_diagnosis.pdf \
    ${PATH_DATA}/venn_withdrawns.png \
    ${PATH_DATA}/all_meds_asthma_diagnosis_gp_script.txt \
    ${PATH_DATA}/refined_all_meds_asthma_diagnosis_gp_script.txt \
    ${PATH_DATA}/asthma_diagnosis_gp_script.txt

#Generate the Medication_list.Rmd report:
export PATH=${PATH}:/cm/shared/apps/R/deps/rstudio/bin/pandoc
file="scripts/Medication_list.Rmd"
module load R
Rscript -e 'rmarkdown::render("'$file'")'