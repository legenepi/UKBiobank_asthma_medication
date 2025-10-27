#!/bin/bash

#PBS -N SA_UKBB_primarycare
#PBS -j oe
#PBS -o SA_UKBB_primarycare_log
#PBS -l walltime=2:00:00
#PBS -l vmem=20gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022


#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPTS="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"


#interactive copy the gp_scripts.txt from /rfs because PBS scheduler can't read file in /rfs:
#cp /rfs/TobinGroup/data/UKBiobank/application_56607/primary_care/gp_scripts.txt ${PATH_DATA}/

#Edit the gp_scripts.txt file with the correct delimiter and columns:
sed 's/\t/||/g' ${PATH_DATA}/gp_scripts.txt | sed 's/||||/||NA||/g' | sed 's/||/\$/g'> ${PATH_DATA}/gp_scripts_edit.txt

#Drop duplicated lines in the gp_scripts
cat -n < ${PATH_DATA}/gp_scripts_edit.txt | sort -uk2 | sort -n | cut -f2- > ${PATH_DATA}/gp_scripts_edit_uniq.txt && mv ${PATH_DATA}/gp_scripts_edit_uniq.txt ${PATH_DATA}/gp_scripts_edit.txt


#Key term for asthma from asthma medication
#awk -F "\t| " '{print $2}' /data/gen1/UKBiobank_500K/severe_asthma/data/Codes_for_asthma_diagnosis.txt | sort | uniq | sed 's/sodium/cromoglycate/g' > ${PATH_DATA}/asthma_meds_key_term.txt

#Run python scripts to retrieve Read v2 for asthma from the table read_v2_drugs_lkp in the all_lkps_maps_v3.xlsx file
#Creation of outputs: asthma_code_read_v2_drugs.txt and asthma_code_dmd.txt
#module load python
#chmod +x ${PATH_SCRIPTS}/SA_UKBiobank_datafields_analysis_primary_care.py
#python ${PATH_SCRIPTS}/SA_UKBiobank_datafields_analysis_primary_care.py

#Filter prescription without readv2 prescription code and without dmd drug code using the key term in the Drug Name column in the gp_scripts.txt file
#Retrieve any prescription without readv2 code and without dmd code drug name in the asthma_meds_key_term.txt:
#awk -F "$" '{if (($4 == "NA") && ($6 == "NA")) print}' ${PATH_DATA}/gp_scripts_edit.txt | grep -w -i -f ${PATH_DATA}/asthma_meds_key_term.txt > ${PATH_DATA}/asthma_meds_gp_scripts.txt

#Read v2
#Use it here to filter gp_scripts for asthma readv2 codes:
#awk -F "\t" {'print $1'} ${PATH_DATA}/asthma_code_read_v2_drugs.txt  | grep -F -w -f - ../data/gp_scripts_edit.txt > ${PATH_DATA}/asthma_readv2_gp_scripts.txt

#DMD code
#Retrieve dmd code for asthma from the table dmd_lkp in the all_lkps_maps_v3.xlsx file in python
#Use it here to filter gp_scripts for asthma dmd code:
#awk -F "\t" '{print $1}' ${PATH_DATA}/asthma_code_dmd.txt | grep -F -w -f - ${PATH_DATA}/gp_scripts_edit.txt > ${PATH_DATA}/asthma_dmd_gp_scripts.txt

#Merge the three files for asthma_*_gp_scripts.txt
#cat ${PATH_DATA}/asthma_meds_gp_scripts.txt ${PATH_DATA}/asthma_readv2_gp_scripts.txt ${PATH_DATA}/asthma_dmd_gp_scripts.txt | sort -u > ${PATH_DATA}/asthma_gp_scripts.txt

#Exclude withdrawn participants up to August 2021:
#awk -F "." {'print $1'} ${PATH_DATA}/Eid_withdrawn | grep -F -f - ${PATH_DATA}/asthma_gp_scripts.txt > ${PATH_DATA}/QC_asthma_gp_scripts.txt

#Remove files not needed anymore:
rm ${PATH_DATA}/gp_scripts.txt


#With the QC-ed QC_asthma_gp_scripts.txt file, find the subset of moderate-severe prescription
#Key term for moderate-severe asthma medication - a subset of asthma medication
#awk -F "\t| " '{print $2}' /data/gen1/UKBiobank_500K/severe_asthma/data/Codes_for_severe_asthma_diagnosis.txt | sort | uniq > ${PATH_DATA}/modsevasthma_meds_key_term.txt
#head -n 1 ${PATH_DATA}/QC_asthma_gp_scripts.txt > ${PATH_DATA}/header_asthma_gp_scripts.txt
#grep -w -i -f ${PATH_DATA}/modsevasthma_meds_key_term.txt ${PATH_DATA}/QC_asthma_gp_scripts.txt | cat ${PATH_DATA}/header_asthma_gp_scripts.txt - > ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt

 
