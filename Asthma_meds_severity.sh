#!/bin/bash

#PBS -N Asthma_meds_severity
#PBS -j oe
#PBS -o Asthma_meds_severity_log
#PBS -l walltime=00:30:00
#PBS -l vmem=5gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022


#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_GEN="/data/gen1/UKBiobank_500K/severe_asthma/data/"

#List of Asthma Meds from Mike:
#on my local computer: scp /home/noemipiga/Documents/PhD/Severe_Asthma_Project/Asthma_Meds.* \
# nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/

#exclude 'MOMETASONE FUROATE' (line 1820) because not specific for asthma
#dos2unix ${PATH_DATA}/Asthma_Meds.txt
sed '1821,1821d' ${PATH_DATA}/Asthma_Meds.txt > ${PATH_DATA}/QC_Asthma_Meds.txt


#Find participants with QC_Asthma_meds in gp_scripts in all UK Biobank
sed 's/\$/ /g' ${PATH_DATA}/gp_scripts_edit.txt | grep -F -f ${PATH_DATA}/QC_Asthma_Meds.txt  \
    > ${PATH_DATA}/QC_Asthma_Meds_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/QC_Asthma_Meds_gp_scripts_edit.txt | sort -u \
    > ${PATH_DATA}/Eid_QC_Asthma_Meds_gp_scripts_edit.txt


#Find participants with QC_Asthma_meds in gp_script in asthma diagnosis participants in UK Biobank
sed 's/\$/ /g' ${PATH_DATA}/asthma_diagnosis_gp_script.txt | grep -F -f ${PATH_DATA}/QC_Asthma_Meds.txt  \
    > ${PATH_DATA}/QC_Asthma_Meds_asthma_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/QC_Asthma_Meds_asthma_gp_scripts_edit.txt | sort -u \
   > ${PATH_DATA}/Eid_QC_Asthma_Meds_asthma_gp_scripts_edit.txt


#exclude participants with emphysema/chronic bronchitis
grep -w -v -F -f ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/QC_Asthma_Meds_asthma_gp_scripts_edit.txt > \
    ${PATH_DATA}/Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt | sort -u \
    > ${PATH_DATA}/Eid_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

#exclude participants with emphysema/chronic bronchitis or COPD from Richard Packer clinical codes
cat ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/eid_QC_RP_ecb.txt | sort -u > ${PATH_DATA}/eid_ecb_COPDRP.txt

grep -w -v -F -f ${PATH_DATA}/eid_ecb_COPDRP.txt ${PATH_DATA}/QC_Asthma_Meds_asthma_gp_scripts_edit.txt \
    > ${PATH_DATA}/NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt | sort -u \
   > ${PATH_DATA}/Eid_NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt


#compare QC_Asthma_Meds with self-reported list of medication Lancet Paper:
awk '{print $2}' ${PATH_GEN}/Codes_for_asthma_diagnosis.txt | \
    grep -i -F -f - ${PATH_DATA}/QC_Asthma_Meds.txt > \
    ${PATH_DATA}/shared_asthmameds_scripts_selfrep.txt

awk '{print $2}' ${PATH_GEN}/Codes_for_asthma_diagnosis.txt | \
    grep -v -i -F -f - ${PATH_DATA}/QC_Asthma_Meds.txt > \
    ${PATH_DATA}/notshared_asthmameds_scripts_selfrep.txt

awk '{print $2}' ${PATH_GEN}/Codes_for_severe_asthma_diagnosis.txt | \
    grep -i -F -f - ${PATH_DATA}/QC_Asthma_Meds.txt > \
    ${PATH_DATA}/shared_modsevere_asthmameds_scripts_selfrep.txt

awk '{print $2}' ${PATH_GEN}/Codes_for_severe_asthma_diagnosis.txt | \
    grep -v -i -F -f - ${PATH_DATA}/QC_Asthma_Meds.txt > \
    ${PATH_DATA}/notshared_modsevere_asthmameds_scripts_selfrep.txt


#Find asthma participants-ecb excluded- with moderate-severe medication prescriptions:
grep -F -f ${PATH_DATA}/shared_modsevere_asthmameds_scripts_selfrep.txt \
    ${PATH_DATA}/Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt > \
    ${PATH_DATA}/modsevere_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/modsevere_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt | sort -u \
    > ${PATH_DATA}/Eid_modsevere_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

#Find asthma participants-ecb or COPD_RP excluded- with moderate-severe medication prescriptions:
grep -F -f ${PATH_DATA}/shared_modsevere_asthmameds_scripts_selfrep.txt \
    ${PATH_DATA}/NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt > \
    ${PATH_DATA}/modsevere_NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

awk '{print $1}' ${PATH_DATA}/modsevere_NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt | sort -u \
    > ${PATH_DATA}/Eid_modsevere_NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt

#Find participants with asthma diagnosed and self-reported medication for asthma excluding ecb participants:
awk -F " " '{print $1}' ${PATH_GEN}/Codes_for_asthma_diagnosis.txt > ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt

awk -F " " '{print $1}' ${PATH_GEN}/Codes_for_severe_asthma_diagnosis.txt > ${PATH_DATA}/OnlyCodes_for_modsev_asthma_diagnosis.txt

#cd ${PATH_DATA}
#biobank select 20003 --output ${PATH_DATA}/treatment_medication_code_selfrep_20003.txt
#cd ${PATH_SCRIPT}

grep -w -F -f ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/treatment_medication_code_selfrep_20003.txt | \
    grep -w -F -f ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    > ${PATH_DATA}/noecb_asthmadiag_selfrepmed_allasthma.txt

awk -F "," '{print $1}' ${PATH_DATA}/noecb_asthmadiag_selfrepmed_allasthma.txt > \
    ${PATH_DATA}/Eid_noecb_asthmadiag_selfrepmed_allasthma.txt

grep -w -F -f ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/treatment_medication_code_selfrep_20003.txt | \
    grep -w -F -f ${PATH_DATA}/OnlyCodes_for_modsev_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_OUTPUT}/eid_union_ecb_ATLEAST_1_evidence.txt \
    > ${PATH_DATA}/noecb_asthmadiag_selfrepmed_modsevasthma.txt

awk -F "," '{print $1}' ${PATH_DATA}/noecb_asthmadiag_selfrepmed_modsevasthma.txt > \
    ${PATH_DATA}/Eid_noecb_asthmadiag_selfrepmed_modsevasthma.txt

#union modsev prescription and self-rep medications for asthma-ecb excluded:
cat ${PATH_DATA}/Eid_modsevere_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt \
    ${PATH_DATA}/Eid_noecb_asthmadiag_selfrepmed_modsevasthma.txt | sort -u \
    > ${PATH_DATA}/Eid_noecb_union_modsev_asthma_scripts_selfrep.txt

##Find participants with asthma diagnosed and self-reported medication for asthma excluding ecb participants or
# COPD participants from Richard Packer clinical codes
grep -w -F -f ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/treatment_medication_code_selfrep_20003.txt | \
    grep -w -F -f ${PATH_DATA}/OnlyCodes_for_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_DATA}/eid_ecb_COPDRP.txt \
    > ${PATH_DATA}/noCOPDRP_noecb_asthmadiag_selfrepmed_allasthma.txt

awk -F "," '{print $1}' ${PATH_DATA}/noCOPDRP_noecb_asthmadiag_selfrepmed_allasthma.txt  > \
    ${PATH_DATA}/Eid_noCOPDRP_noecb_asthmadiag_selfrepmed_allasthma.txt

grep -w -F -f ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/treatment_medication_code_selfrep_20003.txt | \
    grep -w -F -f ${PATH_DATA}/OnlyCodes_for_modsev_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_DATA}/eid_ecb_COPDRP.txt \
    > ${PATH_DATA}/noCOPDRP_noecb_asthmadiag_selfrepmed_modsevasthma.txt

awk -F "," '{print $1}' ${PATH_DATA}/noCOPDRP_noecb_asthmadiag_selfrepmed_modsevasthma.txt > \
    ${PATH_DATA}/Eid_noCOPDRP_noecb_asthmadiag_selfrepmed_modsevasthma.txt

##union modsev prescription and self-rep medications for asthma-ecb or COPD_RP excluded:
 cat ${PATH_DATA}/Eid_modsevere_NoCOPDRP_Noecb_QC_Asthma_Meds_asthma_gp_scripts_edit.txt \
     ${PATH_DATA}/Eid_noCOPDRP_noecb_asthmadiag_selfrepmed_modsevasthma.txt | sort -u \
     > ${PATH_DATA}/Eid_noCOPDRP_noecb_union_modsev_asthma_scripts_selfrep.txt


##execute Rscript:
#chmod o+x ${PATH_SCRIPT}/Asthma_meds_severity.R
#module load R
#Rscript ${PATH_SCRIPT}/Asthma_meds_severity.R
