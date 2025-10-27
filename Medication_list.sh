#!/bin/bash

#PBS -N Medication_list
#PBS -j oe
#PBS -o Medication_list_log
#PBS -l walltime=2:00:00
#PBS -l vmem=20gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022


#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"

#scripts required:
#/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts/create_dataset_for_medication_list.sh
#/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts/SA_UKBiobank_datafields_analysis_primary_care.sh

#ALL Primary care prescription for participants with diagnosed asthma:
grep -w -F -f ${PATH_DATA}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt ${PATH_DATA}/gp_scripts_edit.txt \
        > ${PATH_DATA}/asthma_diagnosis_gp_script.txt

#Eid participants primary care prescription for participants with diagnosed asthma:
awk -F "$" {'print $1'} ${PATH_DATA}/asthma_diagnosis_gp_script.txt | sort -u > ${PATH_DATA}/eid_asthma_diagnosis_gp_script.txt

#List of medication in primary care prescription with diagnosed asthma - drug name:
awk -F "$" {'print $7'} ${PATH_DATA}/asthma_diagnosis_gp_script.txt | sort -u -f > ${PATH_DATA}/drug_name_asthma_diagnosis_gp_script.txt

#List of medication in primary care prescription with a Readv2 only (no drug name):
##exclude prescription with a drug name and find Readv2 code:
awk -F "$" '{if ($7 == "NA") print $4}' ${PATH_DATA}/asthma_diagnosis_gp_script.txt | \
       sort -u > ${PATH_DATA}/readv2_nodrugname_asthma_diagnosis_gp_script.txt
##match Readv2 in the look-up table with Readv2-drug description and retrieve medication names:
xlsx2csv ${PATH_DATA}/all_lkps_maps_v3.xlsx -n 'read_v2_drugs_lkp' | grep -w -F -f ${PATH_DATA}/readv2_nodrugname_asthma_diagnosis_gp_script.txt | \
       awk -F "," {'print $2'} | sort -u > ${PATH_DATA}/meds_readv2_nodrugname_asthma_diagnosis_gp_script.txt
##Note: not needed for dmd code because they have drug name

#List of ALL medications in primary care prescription for asthma (union of drug name and medication names from readv2):
cat ${PATH_DATA}/meds_readv2_nodrugname_asthma_diagnosis_gp_script.txt ${PATH_DATA}/drug_name_asthma_diagnosis_gp_script.txt | \
        sort -u > ${PATH_DATA}/all_meds_asthma_diagnosis_gp_script.txt

#List of refined ALL medications (remove wildcard and asterisks as first/second character in some drug names, and do sort -u -f)
sed s/'^[*]\|^["]'//g ${PATH_DATA}/all_meds_asthma_diagnosis_gp_script.txt | sed s/'^[*]'//g | \
	sort -u -f > ${PATH_DATA}/refined_all_meds_asthma_diagnosis_gp_script.txt

#list match readv2 drug name for Proabtion:
xlsx2csv ${PATH_DATA}/all_lkps_maps_v3.xlsx -n 'read_v2_drugs_lkp' | \|
    grep -w -F -f ${PATH_DATA}/readv2_nodrugname_asthma_diagnosis_gp_script.txt | \
    awk -F "," {'print $1"$"$2'} > ${PATH_DATA}/match_drugname_readv2_asthma_diagnosis_gp_script.txt
