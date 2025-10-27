#!/bin/bash

#PBS -N control_definition
#PBS -j oe
#PBS -o control_definition_log
#PBS -l walltime=2:00:00
#PBS -l vmem=20gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022


#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_SA_DATA="/data/gen1/UKBiobank_500K/severe_asthma/data"

#eid column: cannot do this on batch, need to do this interactively adn then run the job
awk -F '","' '{print $1}' ${PATH_APPL}/ukb48371.csv | sed s/'"'//g > ${PATH_DATA}/tmp_control_eid.txt

#withdrawns participants are already excluded since ukb48371.csv does not have them after
#exclude command in biobank tools

#exclude asthma participants:
grep -v -w -F -f ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/tmp_control_eid.txt > ${PATH_DATA}/noasthma_tmp_control_eid.txt

#exclude Non-cancer illness code, self-reported asthma datafield 20002 (value 1111)
cd  ${PATH_SA_DATA}
biobank select 20002 --output  ${PATH_DATA}/noncancer_illcode_selfrep_20002.txt
cd ${PATH_SCRIPT}

grep -w "1111" ${PATH_DATA}/noncancer_illcode_selfrep_20002.txt | awk -F ',' {'print $1'} \
    > ${PATH_DATA}/asthma_noncancer_illcode_selfrep_20002.txt

grep -v -w -F -f ${PATH_DATA}/asthma_noncancer_illcode_selfrep_20002.txt \
    ${PATH_DATA}/noasthma_tmp_control_eid.txt > ${PATH_DATA}/noasthma20002_noasthma_tmp_control_eid.txt

#exclude any participants with asthma e/o COPD (emphysema/chronic bronchitis) as found by Richard Packer codes
grep -v -w -F -f ${PATH_DATA}/eid_QC_RP_asthma.txt \
    ${PATH_DATA}/noasthma20002_noasthma_tmp_control_eid.txt > \
    ${PATH_DATA}/noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

grep -v -w -F -f ${PATH_DATA}/eid_QC_RP_ecb.txt ${PATH_DATA}/noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    > ${PATH_DATA}/noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#exclude any participants with emphysema/chronic bronchitis as found by my analysis
grep -v -w -F -f ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    > ${PATH_DATA}/noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#exclude participant with FEV1/FVC <= 70%
chmod o+x ${PATH_SCRIPT}/FEV1_FVC_ratio.py #to create the ratio value
module load python
python ${PATH_SCRIPT}/FEV1_FVC_ratio.py
awk -F "\t" '{if ($2 <= 0.70 && $2 ~ /[0-9]/) print $1}' ${PATH_DATA}/Best_FEV1_FVC_ratio_20150_20151.txt \
   > ${PATH_DATA}/eid_less70_Best_FEV1_FVC_ratio_20150_20151.txt

grep -v -w -F -f ${PATH_DATA}/eid_less70_Best_FEV1_FVC_ratio_20150_20151.txt \
    ${PATH_DATA}/noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    > ${PATH_DATA}/noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#any other major respiratory illness:
#UNDERSTAND HOW TO RETRIEVE THIS CATEGORY: FROM 20002 - all the coding grouped in 'respiratory/ent':
#downloand data coding 6 and select all codes related to illness grouped in 'respiratory/ent'
#Download on my local laptop coding6.tsv from https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=6
#scp /home/noemipiga/Downloads/coding6.tsv    nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/coding6.tsv
awk -F "\t" '{if ($4 == 1072) print}' ${PATH_DATA}/coding6.tsv | tail -n +3 > ${PATH_DATA}/Respiratory_coding6.tsv
awk -F "\t" '{if ($4 == 1466 || \
    $4 == 1130 || \
    $4 == 1131 || \
    $4 == 1132 || \
    $4 == 1133 || \
    $4 == 1134 || \
    $4 == 1136 || \
    $4 == 1660) print}' ${PATH_DATA}/coding6.tsv >> ${PATH_DATA}/Respiratory_coding6.tsv
awk -F "\t" '{if ($4 == 1139 || \
    $4 == 1140 || \
    $4 == 1141 || \
    $4 == 1142 || \
    $4 == 1143 || \
    $4 == 1144 || \
    $4 == 1467 || \
    $4 == 1164 || \
    $4 == 1168 || \
    $4 == 1534 || \
    $4 == 1559 || \
    $4 == 1560 || \
    $4 == 1561 || \
    $4 == 1562 || \
    $4 == 1563 || \
    $4 == 1465) print}' ${PATH_DATA}/coding6.tsv >> ${PATH_DATA}/Respiratory_coding6.tsv

awk '{print $1}' ${PATH_DATA}/Respiratory_coding6.tsv | grep -w -F -f - ${PATH_DATA}/selfreported_20002.txt \
    | awk -F "," '{print $1}' > ${PATH_DATA}/eid_respiratory_selfreported_20002.txt

grep -v -w -F -f ${PATH_DATA}/eid_respiratory_selfreported_20002.txt \
    ${PATH_DATA}/noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    > ${PATH_DATA}/noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#exclude participants with FEV1 < 60% (GINA suggests risk of asthma exacerbation)
awk -F "," '{if ($2 < 60 && $2 ~ /[0-9]/) print $1}' ${PATH_DATA}/Predicted_percentage_FEV1_20154.txt \
   > ${PATH_DATA}/eid_less60_Predicted_percentage_FEV1_20154.txt

grep -v -w -F -f ${PATH_DATA}/eid_less60_Predicted_percentage_FEV1_20154.txt \
    ${PATH_DATA}/noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    > ${PATH_DATA}/noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#exlcude any participant with a self-reported medication for all asthma:
awk -F "\t" '{print $1}' /data/gen1/UKBiobank_500K/severe_asthma/data/Codes_for_asthma_diagnosis.txt >  ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt
grep -w -F -f ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt /rfs/TobinGroup/data/UKBiobank/application_56607/20003_self_meds.csv.csv | \
    awk -F "," '{print $1}' | \
    grep -v -F -f - ${PATH_DATA}/noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt > \
    ${PATH_DATA}/noasthmaselfrepmed20003_noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

#exclude any participants with a primary care prescription for all asthma:
grep -F -f /home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/data/QC_Asthma_Meds.txt \
    ${PATH_DATA}/gp_scripts_edit.txt | \
    awk -F "$" '{print $1}' | sort -u > ${PATH_DATA}/Eid_with_asthmascripts

grep -v -w -F -f ${PATH_DATA}/Eid_with_asthmascripts \
    ${PATH_DATA}/noasthmaselfrepmed20003_noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt > \
    ${PATH_DATA}/noasthmascript_noasthmaselfrepmed20003_noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt

mv ${PATH_DATA}/noasthmascript_noasthmaselfrepmed20003_noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/Eid_controls.txt


#delete tmp files:
rm ${PATH_DATA}/tmp_control_eid.txt ${PATH_DATA}/noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt \
    ${PATH_DATA}/noasthmaselfrepmed20003_noless60FEV1_noresp20002_noless70FEV1FVC_noecb_noecbRP_noasthmaRP_noasthma20002_noasthma_tmp_control_eid.txt