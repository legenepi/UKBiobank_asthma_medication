#!/bin/bash

#PBS -N control_definition_V2
#PBS -j oe
#PBS -o control_definition_V2_log
#PBS -l walltime=2:00:00
#PBS -l vmem=20gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022


#For Eid files support from control_definition.sh
# create_dataset_for_medication_list.sh
# medication_list.sh
# emphysema_chronic_bronchitis_diagnosis.sh
# asthma_ecb_diagnosis_RP_clinicalcodes.sh

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_SA_DATA="/data/gen1/UKBiobank_500K/severe_asthma/data"

#eid column:
awk -F '","' '{print $1}' ${PATH_APPL}/ukb48371.csv | sed s/'"'//g > ${PATH_DATA}/tmp_control_eid.txt


#ASTHMA-FREE CONTROLS:
#exclude asthma participants:
#${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt

#exclude Non-cancer illness code, self-reported asthma datafield 20002 (value 1111)
#${PATH_DATA}/asthma_noncancer_illcode_selfrep_20002.txt

#exclude any participants with asthma according to Richard Packer clinical codes:
#${PATH_DATA}/eid_QC_RP_asthma.txt

#exlcude any participant with a self-reported medication for all asthma:
grep -w -F -f ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt /rfs/TobinGroup/data/UKBiobank/application_56607/20003_self_meds.csv.csv | \
    awk -F "," '{print $1}' > ${PATH_DATA}/Eid_asthma_treatment_medication_code_selfrep_20003.txt

#exclude participant with FEV1/FVC <= 70%
#${PATH_DATA}/eid_less70_Best_FEV1_FVC_ratio_20150_20151.txt

#exclude participants with FEV1 < 60% (GINA suggests risk of asthma exacerbation)
# ${PATH_DATA}/eid_less60_Predicted_percentage_FEV1_20154.txt

#exclude withdrawns participants are already excluded since ukb48371.csv does not have them after
#exclude command in biobank tools
#anyway, withdrawns file:
#${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt

#exclude participant with no record for datafield 20003:
awk -F "," '{print $1, $2}' /rfs/TobinGroup/data/UKBiobank/application_56607/20003_self_meds.csv.csv | awk -F " "  '{if ($2  !~ /[0-9]/) print $1}' | \
    tail -n +2 | sed s/'"'//g \
    > ${PATH_DATA}/Eid_NO_treatment_medication_code_selfrep_20003.txt

#exclude participants with no records for primary care prescriptions:
awk -F "$" '{print $1}' ${PATH_DATA}/gp_scripts_edit.txt | tail -n +2 | sort -u | \
    grep -v -w -F -f - ${PATH_DATA}/tmp_control_eid.txt > ${PATH_DATA}/Eid_NO_gp_scripts_edit.txt

#merge participants from each exclusion criteria
cat ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/asthma_noncancer_illcode_selfrep_20002.txt \
    ${PATH_DATA}/eid_QC_RP_asthma.txt \
    ${PATH_DATA}/Eid_asthma_treatment_medication_code_selfrep_20003.txt \
    ${PATH_DATA}/eid_less70_Best_FEV1_FVC_ratio_20150_20151.txt \
    ${PATH_DATA}/eid_less60_Predicted_percentage_FEV1_20154.txt \
    ${PATH_DATA}/Eid_with_asthmascripts \
    ${PATH_DATA}/Eid_NO_treatment_medication_code_selfrep_20003.txt \
    ${PATH_DATA}/Eid_NO_gp_scripts_edit.txt \
    ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt | \
    sort -u > ${PATH_DATA}/Eid_to_exclude_control_asthmafree.txt

#Controls asthma-free
grep -v -w -F -f ${PATH_DATA}/Eid_to_exclude_control_asthmafree.txt  ${PATH_DATA}/tmp_control_eid.txt \
    > ${PATH_DATA}/Eid_control_asthmafree.txt


#RESPIRATORY-FREE CONTROLS
#Filter the asthma-free controls for three additional exclusion criteria

#exclude any participants with emphysema/chronic bronchitis as found by my analysis:
#${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt

#exclude any participants with COPD (emphysema/chronic bronchitis) as found by Richard Packer codes:
#${PATH_DATA}/eid_QC_RP_ecb.txt

#any other major respiratory illness:
#${PATH_DATA}/eid_respiratory_selfreported_20002.txt

#merge participants from additional exclusion criteria
cat ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/eid_QC_RP_ecb.txt \
    ${PATH_DATA}/eid_respiratory_selfreported_20002.txt |
    sort -u \
    > ${PATH_DATA}/Eid_to_exclude_control_respiratoryfree.txt

#Controls respiratory-free
grep -v -w -F -f ${PATH_DATA}/Eid_to_exclude_control_respiratoryfree.txt ${PATH_DATA}/Eid_control_asthmafree.txt \
    > ${PATH_DATA}/Eid_control_respiratoryfree.txt

