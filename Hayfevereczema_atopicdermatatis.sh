#!/bin/env/bash

#work on venv environment
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_APPL="/rfs/TobinGroup/data/UKBiobank/application_56607"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"
PATH_OUTPUT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output"



#1.FROM SELF-REPORTED DOCTOR DIAGNOSED
#field 6152 -Blood clot, DVT, bronchitis, emphysema, asthma, rhinitis, eczema, allergy diagnosed by doctor- in ukb48371.csv; code 6 is for emphysema/chronic bronchitis:
#ACE touchscreen question "Has a doctor ever told you that you have had any of the following conditions? (You can select more than one answer)"
cut -d "," -f 2- ${PATH_APPL}/self_reported_6152.csv | grep -w "9" -n | awk -F ":" {'print $1'} | \
    awk -F '","' 'NR==FNR{ pos[$1]; next }FNR in pos' - ${PATH_APPL}/self_reported_6152.csv \
    > ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfrepdocdiagnosed_6152.txt
#Exclude any withdrawn participants:
awk -F "." {'print $1'} ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt | \
    grep -v -F -f - ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfrepdocdiagnosed_6152.txt > ${PATH_DATA}/QC_hayfev_rhinitis_eczema_derma_selfrepdocdiagnosed_6152.txt
rm ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfrepdocdiagnosed_6152.txt


#FROM SELF-REPORTED datafield 20002:
#Data-Coding 6: 1387 hayfever/allergic rhinitis, 1452 eczema/dermatitis
#${PATH_DATA}/selfreported_20002.txt
grep -w '1452\|1453\|1387\|1374\|1668\|1386\|1385\|1670\|1669\|1671' \
    ${PATH_DATA}/selfreported_20002.txt \
    > ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfreported_20002.txt
#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfreported_20002.txt \
    > ${PATH_DATA}/QC_hayfev_rhinitis_eczema_derma_selfreported_20002.txt
rm ${PATH_DATA}/hayfev_rhinitis_eczema_derma_selfreported_20002.txt


#4.FROM PRIMARY CARE CLINICAL RECORDS (Readv2 and ReadCTV3)
#Readv2 from Data-Coding 1834; Read CTV3 from Data-Coding 1835
#Download from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1834 on my local computer
#Download from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1835 on my local computer
#then use: scp /home/noemipiga/Downloads/coding1834.tsv nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
#then use: scp /home/noemipiga/Downloads/coding1835.tsv nnp5@spectre2.le.ac.uk:/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/
# ${PATH_DATA}/readv2_ICD10_datacoding1834.tsv;
#create file data/ICD10_allergic with ICD10 codes from CameronChristie et al. allergic phenotype
dos2unix ${PATH_DATA}/ICD10_allergic
module unload R/4.2.1
module load R/4.1.0
dos2unix ${PATH_SCRIPT}/Hayfevereczema_atopicdermatatis.R
chmod o+x ${PATH_SCRIPT}/Hayfevereczema_atopicdermatatis.R
Rscript ${PATH_SCRIPT}/Hayfevereczema_atopicdermatatis.R

#Filter	for Readv2 clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/readv2_dermaecz_rhinit -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - ${PATH_APPL}/primary_care/gp_clinical.txt > ${PATH_DATA}/Readv2_dermaecz_rhinit_gp_clinical.txt

#Filter	for ReadCTV3 clinical code in gp_clinical.txt:
awk -F " " {'print $4'} ${PATH_APPL}/primary_care/gp_clinical.txt | \
    grep -w -F -f ${PATH_DATA}/readv3_dermaecz_rhinit -n | awk -F ":" '{print $1}' | awk -F " " 'NR==FNR{ pos[$1]; next }FNR in pos' \
    - ${PATH_APPL}/primary_care/gp_clinical.txt > ${PATH_DATA}/ReadCTV3_dermaecz_rhinit_gp_clinical.txt

#Merge results from Readv2 and ReadCTV3:
cat ${PATH_DATA}/Readv2_dermaecz_rhinit_gp_clinical.txt ${PATH_DATA}/ReadCTV3_dermaecz_rhinit_gp_clinical.txt | \
    sort -u > ${PATH_DATA}/dermaecz_rhinit_gp_clinical.txt

#Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/dermaecz_rhinit_gp_clinical.txt > ${PATH_DATA}/QC_dermaecz_rhinit_gp_clinical.txt
rm ${PATH_DATA}/dermaecz_rhinit_gp_clinical.txt

#5.FROM HES RECORDS (including all levels, level 1, level 2)
#use of ICD-9(col5) and ICD-10(col7) codes
awk -F "\t" '{if ($5 == "69180" || $5 == "7080" || $5 == "6918" || $5 == "4770" || \
    $7 == "L409" || $7 == "L309" || $7 == "6961" || $7 == "J310" ||\
    $7 == "J30`" || $7 == "4779" || $7 == "J450" || $7 == "L500" || \
    $7 == "L239" || $7 == "L400" || $7 == "J304" || $7 == "L208" || \
    $7 == "J303" || $7 == "J300" || $7 == "6929" || $7 == "L259" || \
    $7 == "L209" || $7 == "4778" || $7 == "D690" || $7 == "L231" || \
    $7 == "6928" || $7 == "L235" || $7 == "L308" || $7 == "J302" || \
    $7 == "4720" || $7 == "L408" || $7 == "L22" || $7 == "L249" || $7 == "L234" ) print}' \
    ${PATH_APPL}/hes/hesin_diag.txt  > ${PATH_DATA}/hesin_diag_dermaecz_rhinit.txt

##Exclude any withdrawn participants:
grep -v -F -f ${PATH_DATA}/Eid_withdrawn_participants_upFeb2022.txt ${PATH_DATA}/hesin_diag_dermaecz_rhinit.txt > ${PATH_DATA}/QC_hesin_diag_dermaecz_rhinit.txt
rm ${PATH_DATA}/hesin_diag_dermaecz_rhinit.txt

#6.FROM CAUSE of DEATH
#PRIMARY CAUSE - field 40001
grep "L409\|L309\|6961\|J310\|J301\|4779\|J450\|L500\|L239\|L400\|J304\|L208\|J303\|J300\|6929\|L259\|L209\|4778\|D690\|L231\|6928\|L235\|L308\|J302\|4720\|L408\|L22\|L249\|L234" \
    ${PATH_DATA}/PrimaryCauseOfDeath_40001.txt > ${PATH_DATA}/QC_dermaecz_rhinit_PrimaryCauseOfDeath_40001.txt
#SECONDARY CAUSE - field 40002
grep "L409\|L309\|6961\|J310\|J301\|4779\|J450\|L500\|L239\|L400\|J304\|L208\|J303\|J300\|6929\|L259\|L209\|4778\|D690\|L231\|6928\|L235\|L308\|J302\|4720\|L408\|L22\|L249\|L234" \
    ${PATH_DATA}/SecondaryCauseOfDeath_40002.txt > ${PATH_DATA}/QC_dermaecz_rhinit_SecondaryCauseOfDeath_40002.txt

#Merge participants for emphysema/chronic bronchitis:
awk -F '","' '{print $1}' ${PATH_DATA}/QC_hayfev_rhinitis_eczema_derma_selfrepdocdiagnosed_6152.txt | \
    sed 's/"//g' > ${PATH_DATA}/eid_hayfev_rhinitis_eczema_derma_6152.txt

awk -F ',' '{print $1}' ${PATH_DATA}/QC_hayfev_rhinitis_eczema_derma_selfreported_20002.txt | \
    sed 's/"//g' > ${PATH_DATA}/eid_hayfev_rhinitis_eczema_derma_20002.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_dermaecz_rhinit_gp_clinical.txt | sort -u > ${PATH_DATA}/eid_dermaecz_rhinit_gp_clinical.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_hesin_diag_dermaecz_rhinit.txt | sort -u > ${PATH_DATA}/eid_dermaecz_rhinit_hesin_diag.txt

awk -F "\t" '{print $1}' ${PATH_DATA}/QC_dermaecz_rhinit_PrimaryCauseOfDeath_40001.txt | sort -u > ${PATH_DATA}/eid_dermaecz_rhinit_40001.txt

awk -F "        " '{print $1}' ${PATH_DATA}/QC_dermaecz_rhinit_SecondaryCauseOfDeath_40002.txt | sort -u > ${PATH_DATA}/eid_dermaecz_rhinit_40002.txt

cat \
    ${PATH_DATA}/eid_hayfev_rhinitis_eczema_derma_6152.txt \
    ${PATH_DATA}/eid_hayfev_rhinitis_eczema_derma_20002.txt \
    ${PATH_DATA}/eid_dermaecz_rhinit_gp_clinical.txt \
    ${PATH_DATA}/eid_dermaecz_rhinit_hesin_diag.txt \
    ${PATH_DATA}/eid_dermaecz_rhinit_40001.txt \
    ${PATH_DATA}/eid_dermaecz_rhinit_40002.txt \
    | sort -u > ${PATH_DATA}/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt


grep -w -v -F -f ${PATH_DATA}/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt | awk '$68 == 1 {print $1, 1}' > \
    ${PATH_DATA}/eid_noallergy_EUR_pheno

grep -w -v -F -f ${PATH_DATA}/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt | awk '$68 == 0 {print $1, 0}' >> \
    ${PATH_DATA}/eid_noallergy_EUR_pheno

cp ${PATH_DATA}/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/

cp ${PATH_DATA}/eid_noallergy_EUR_pheno /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/

rm ${PATH_DATA}/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt ${PATH_DATA}/eid_noallergy_EUR_pheno


grep -w -v -F -f /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt | awk '$71 == 1 {print $1, 1}' > \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_noallergy_EUR_pheno_broadasthma

grep -w -v -F -f /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_union_hayfev_rhinitis_eczema_derma_ATLEAST_1_evidence.txt \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/demo_EUR_pheno_cov_broadasthma.txt | awk '$71 == 0 {print $1, 0}' >> \
    /data/gen1/UKBiobank_500K/severe_asthma/Noemi_PhD/data/eid_noallergy_EUR_pheno_broadasthma

module unload R/4.2.1
module load R/4.1.0
dos2unix /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/src/noallergy_pheno/noallergy_pheno_cov_EUR_file.R
chmod o+x /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/src/noallergy_pheno/noallergy_pheno_cov_EUR_file.R
Rscript /home/n/nnp5/PhD/PhD_project/REGENIE_assoc/src/noallergy_pheno/noallergy_pheno_cov_EUR_file.R