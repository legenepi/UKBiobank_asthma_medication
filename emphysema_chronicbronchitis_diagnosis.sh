#!/bin/env/bash

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"



#1.FROM SELF-REPORTED DOCTOR DIAGNOSED ASTHMA
#field 6152 -Blood clot, DVT, bronchitis, emphysema, asthma, rhinitis, eczema, allergy diagnosed by doctor- in ukb48371.csv; code 6 is for emphysema/chronic bronchitis:
#ACE touchscreen question "Has a doctor ever told you that you have had any of the following conditions? (You can select more than one answer)"
cut -d "," -f 2- ${PATH_APPL}/self_reported_6152.csv | grep -w "6" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/self_reported_6152.csv \
    > ${PATH_DATA}/emphchronbronc_selfrepdocdiagnosed_6152.txt
#Exclude any withdrawn participants:
awk -F "." {'print $1'} ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt | \
    grep -v -F -f - ${PATH_DATA}/emphchronbronc_selfrepdocdiagnosed_6152.txt > ${PATH_DATA}/QC_emphchronbronc_selfrepdocdiagnosed_6152.txt
rm ${PATH_DATA}/emphchronbronc_selfrepdocdiagnosed_6152.txt


#2.self-reported doctor diagnosed emphysema in Data-Field 22128;
#3.self-reported doctor diagnosed chronic bronchitis in Data-Field 22129
#previous biobank version (/rfs/TobinGroup/data/UKBiobank/application_56607/ukb44204.csv) has datafield 22128 and 22129, Kath extracted for me, so I have  .csv file for each data-field:
cut -d "," -f 2- ${PATH_APPL}/22128.csv | grep -w "1" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/22128.csv > ${PATH_DATA}/emphysema_selfrepdocdiagnosed_22128.csv
cut -d "," -f 2- ${PATH_APPL}/22129.csv | grep -w "1" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/22129.csv > ${PATH_DATA}/chrbronch_selfrepdocdiagnosed_22129.csv

#Exclude any withdrawn participants:
awk -F "." {'print $1'} ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt | grep -v -F -f - \
    ${PATH_DATA}/emphysema_selfrepdocdiagnosed_22128.csv > ${PATH_DATA}/QC_emphysema_selfrepdocdiagnosed_22128.csv
awk -F "." {'print $1'} ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt | grep -v -F -f - \
    ${PATH_DATA}/chrbronch_selfrepdocdiagnosed_22129.csv > ${PATH_DATA}/QC_chrbronch_selfrepdocdiagnosed_22129.csv
rm  ${PATH_DATA}/emphysema_selfrepdocdiagnosed_22128.csv
rm ${PATH_DATA}/chrbronch_selfrepdocdiagnosed_22129.csv

#4.FROM PRIMARY CARE CLINICAL RECORDS (Readv2 and ReadCTV3)
#Readv2 from Data-Coding 1834; Read CTV3 from Data-Coding 1835
#Download from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1834 on my local computer
#Download from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1835 on my local computer
#then use: scp /home/noemipiga/Downloads/coding1834.tsv nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
#then use: scp /home/noemipiga/Downloads/coding1835.tsv nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
# ${PATH_DATA}/readv2_ICD10_datacoding1834.tsv; ecb:emphysema-chronic-bronchitis
awk -F "\t" '{if ($2 == "J40" || $2 == "J41" || $2 == "J42" || $2 == "J43") print $1}' ${PATH_DATA}/coding1834.tsv > ${PATH_DATA}/ecb_readv2_codes
awk -F "\t" '{if ($2 == "J40" || $2 == "J41" || $2 == "J42" || $2 == "J43") print $1}' ${PATH_DATA}/coding1835.tsv > ${PATH_DATA}/ecb_readCTV3_codes
#Filter for Readv2 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/ecb_readv2_codes -n | awk -F ":" '{print $1}' | \
    awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/primary_care/gp_clinical.txt \
     > ${PATH_DATA}/Readv2_ecb_gp_clinical.txt

#Filter	for ReadCTV3 asthma clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/ecb_readCTV3_codes -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - ${PATH_APPL}/primary_care/gp_clinical.txt > ${PATH_DATA}/ReadCTV3_ecb_gp_clinical.txt

#Merge results from Readv2 and ReadCTV3:
cat ${PATH_DATA}/Readv2_ecb_gp_clinical.txt ${PATH_DATA}/ReadCTV3_ecb_gp_clinical.txt | \
    sort -u > ${PATH_DATA}/ecb_gp_clinical.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/ecb_gp_clinical.txt > ${PATH_DATA}/QC_ecb_gp_clinical.txt
rm ${PATH_DATA}/ecb_gp_clinical.txt

#5.FROM HES RECORDS (including all levels, level 1, level 2)
#use of ICD-9 and ICD-10 codes
awk -F "\t" '{if ($5 == "491" || $5 == "492" || $7 == "J40" || $7 == "J41" || $7 == "J42" || $7 == "J43") print}' \
    ${PATH_APPL}/hes/hesin_diag.txt  > ${PATH_DATA}/hesin_diag_ecb.txt

##Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/hesin_diag_ecb.txt > ${PATH_DATA}/QC_hesin_diag_ecb.txt
rm ${PATH_DATA}/hesin_diag_ecb.txt

#6.FROM CAUSE of DEATH
#PRIMARY CAUSE - field 40001
grep "J40\|J41\|J42\|J43" ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt > ${PATH_DATA}/QC_ecb_PrimaryCauseOfDeath_40001.txt
#SECONDARY CAUSE - field 40002
grep "J40\|J41\|J42\|J43" ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt > ${PATH_DATA}/QC_ecb_SecondaryCauseOfDeath_40002.txt

#Merge participants for emphysema/chronic bronchitis:
awk -F '","' '{print $1}' ${PATH_DATA}/QC_emphchronbronc_selfrepdocdiagnosed_6152.txt | \
    sed 's/"//g' > ${PATH_DATA}/eid_ecb_6152.txt

awk -F '","' '{print $1}' ${PATH_DATA}/QC_emphysema_selfrepdocdiagnosed_22128.csv | \
    sed 's/"//g' > ${PATH_DATA}/eid_ecb_22128.txt

awk -F '","' '{print $1}' ${PATH_DATA}/QC_chrbronch_selfrepdocdiagnosed_22129.csv | \
    sed 's/"//g' > ${PATH_DATA}/eid_ecb_22129.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_ecb_gp_clinical.txt | sort -u > ${PATH_DATA}/eid_ecb_gp_clinical.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_hesin_diag_ecb.txt| sort -u > ${PATH_DATA}/eid_ecb_hesin_diag.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_ecb_PrimaryCauseOfDeath_40001.txt | sort -u > ${PATH_DATA}/eid_ecb_40001.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_ecb_SecondaryCauseOfDeath_40002.txt | sort -u > ${PATH_DATA}/eid_ecb_40002.txt

cat \
   ${PATH_DATA}/eid_ecb_6152.txt \
   ${PATH_DATA}/eid_ecb_22128.txt \
   ${PATH_DATA}/eid_ecb_22129.txt \
   ${PATH_DATA}/eid_ecb_hesin_diag.txt \
   ${PATH_DATA}/eid_ecb_gp_clinical.txt \
   ${PATH_DATA}/eid_ecb_40001.txt \
   ${PATH_DATA}/eid_ecb_40002.txt | sort -u > ${PATH_DATA}/eid_union_ecb_ATLEAST_1_evidence.txt


#exclude ecb diagnosis participants from asthma diagnosis participants (all, genotyped only):
#all participants
grep -v -w -F -f ${PATH_DATA}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_OUTPUT}/Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt > ${PATH_DATA}/eid_excl_ecb_asthma_diagnosis.txt


#print read code and ICD-10 code just to have these files in the supplementary material on onedrive:
awk -F "\t" '{if ($2 == "J40" || $2 == "J41" || $2 == "J42" || $2 == "J43") print}' ${PATH_DATA}/coding1834.tsv > ${PATH_DATA}/ecb_readv2_ICD10.tsv
awk -F "\t" '{if ($2 == "J40" || $2 == "J41" || $2 == "J42" || $2 == "J43") print}' ${PATH_DATA}/coding1835.tsv > ${PATH_DATA}/ecb_readCTV3_ICD10.tsv

#Move output files into output folder:
mv -t ${PATH_OUTPUT}/ ${PATH_DATA}/eid_union_ecb_ATLEAST_1_evidence.txt \
    ${PATH_DATA}/eid_excl_ecb_asthma_diagnosis.txt \


#Compare my ecb ICD-10/9, readv2 and readCTV3 codes to Richard Packer's ones:
#on my local computer to copy on spectre:
#scp /home/noemipiga/Documents/PhD/Severe_Asthma_Project/emphysema_codes_rated.csv \
#     nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
awk -F ',' '{ print $6}' ${PATH_DATA}/emphysema_codes_rated.csv | sort | uniq -c
awk -F ',' '{ if ($6 == "V3") print $4}' ${PATH_DATA}/emphysema_codes_rated.csv | grep -w -F -f ${PATH_DATA}/ecb_readv2_codes | wc -l
awk -F ',' '{ if ($6 == "V3") print $4}' ${PATH_DATA}/emphysema_codes_rated.csv | grep -w -F -f ${PATH_DATA}/ecb_readCTV3_codes | wc -l
