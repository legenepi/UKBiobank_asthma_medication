#!/bin/bash

#PBS -N ecb_COPD_comparison
#PBS -j oe
#PBS -o ecb_COPD_comparison_log
#PBS -l walltime=1:00:00
#PBS -l vmem=10gb
#PBS -l nodes=1:ppn=16
#PBS -d .
#PBS -W umask=022

#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"
PATH_GEN="/data/gen1/UKBiobank_500K/severe_asthma/data/"


#check prescription are for asthma patients and not for ecb-diagnosed participants:
#rationale: if I retrieve the same 3237 prescriptions that Mike found, means that these prescriptions are prescribed at
# least once for an asthma-excluded ecb participants


##My approach for ecb phenotype definition
awk -F "$" '{print $1, $7}' ${PATH_DATA}/gp_scripts_edit.txt | \
    grep -w -F -f ${PATH_OUTPUT}/eid_excl_ecb_asthma_diagnosis.txt | \
    grep -w -F -f ${PATH_DATA}/Asthma_Meds.txt | \
    cut -d " " -f 2- | sort -u > ${PATH_DATA}/Asthma_Meds_shared_excl_ecb_asthma_diagnosis.txt

awk -F "$" '{print $1, $7}' ${PATH_DATA}/gp_scripts_edit.txt | \
    grep -w -F -f ${PATH_OUTPUT}/eid_excl_ecb_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_DATA}/Asthma_Meds.txt | \
    cut -d " " -f 2- | sort -u > ${PATH_DATA}/Asthma_Meds_notshared_excl_ecb_asthma_diagnosis.txt

##Richard Packer's clinical codes for COPD as combination of emphysema/chronic bronchitis codes for ecb phenotype definition:
grep -v -w -F -f ${PATH_DATA}/eid_QC_RP_ecb.txt ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt \
    > ${PATH_DATA}/eid_excl_QCRPecb_asthma_diagnosis.txt

awk -F "$" '{print $1, $7}' ${PATH_DATA}/gp_scripts_edit.txt | \
    grep -w -F -f ${PATH_DATA}/eid_excl_QCRPecb_asthma_diagnosis.txt | \
    grep -w -F -f ${PATH_DATA}/Asthma_Meds.txt | \
    cut -d " " -f 2- | sort -u > ${PATH_DATA}/Asthma_Meds_shared_excl_QCRPecb_asthma_diagnosis.txt


awk -F "$" '{print $1, $7}' ${PATH_DATA}/gp_scripts_edit.txt | \
    grep -w -F -f ${PATH_DATA}/eid_excl_QCRPecb_asthma_diagnosis.txt | \
    grep -v -w -F -f ${PATH_DATA}/Asthma_Meds.txt | \
    cut -d " " -f 2- | sort -u > ${PATH_DATA}/Asthma_Meds_notshared_excl_QCRPecb_asthma_diagnosis.txt
