#Global variable:
PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"

#extract eis for application 56607, diagnosed asthma and diagnosed asthma without obstructive pulmonary diseases from the previous master table:
#awk '{print $49, $50, $52}' /data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample > asthma_ukbiobank_master_app56607.sample

#SELF-REPORTED MEDICATION

##ASTHMA
echo "Compare participants with self-reported medication for asthma VS participants with diagnosed asthma:"
awk '{print $1}' ${PATH_DATA}/asthma_selfrep_meds.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

echo "Compare participants with self-reported medication for asthma VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk '{print $1}' ${PATH_DATA}/asthma_selfrep_meds.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

##MODERATE-SEVERE ASTHMA
echo "Compare participants with self-reported medication for moderate-severe asthma VS participants with diagnosed asthma:"
awk '{print $1}' ${PATH_DATA}/modsevasthma_selfrep_meds.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

echo "Compare participants with self-reported medication for moderate-severe asthma VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk '{print $1}' ${PATH_DATA}/modsevasthma_selfrep_meds.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c


#PRIMARY CARE PRESCRIPTION
##ASTHMA
echo "Compare participants with primary care prescription for asthma VS participants with diagnosed asthma:"
awk -F "$" '{print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

echo "Compare participants with primary care prescription for asthma VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only read v2:
echo "Compare participants with primary care prescription for asthma only read v2 VS participants with diagnosed asthma:"
awk -F "$" '{if ($4 != "nan") print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c
#Only dm+d code
echo "Compare participants with primary care prescription for asthma only dm+d VS participants with diagnosed asthma:"
awk -F "$" '{if ($6 != "nan") print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

#Only drug name
echo "Compare participants with primary care prescription for asthma only drug name VS participants with diagnosed asthma:"
awk -F "$" '{if (($4 == "nan") && ($6 == "nan")) print}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

#Only read v2:
echo "Compare participants with primary care prescription for asthma only read v2 VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if ($4 != "nan") print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only dm+d code
echo "Compare participants with primary care prescription for asthma only dm+d VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if ($6 != "nan") print $1}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only drug name
echo "Compare participants with primary care prescription for asthma only drug name VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if (($4 == "nan") && ($6 == "nan")) print}' ${PATH_DATA}/QC_asthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c


#MODERATE-SEVERE ASTHMA
echo "Compare participants with primary care prescription for moderate-severe asthma VS participants with diagnosed asthma:"
awk -F "$" '{print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

echo "Compare participants with primary care prescription for moderate-severe asthma with participants VS diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ${PATH_DATA}/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only read v2:
echo "Compare participants with primary care prescription for moderate-severe asthma only read v2 VS participants with diagnosed asthma:"
awk -F "$" '{if ($4 != "nan") print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

#Only dm+d code
echo "Compare participants with primary care prescription for moderate-severe asthma only dm+d VS participants with diagnosed asthma:"
awk -F "$" '{if ($6 != "nan") print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

#Only drug name
echo "Compare participants with primary care prescription for moderate-severe asthma only drug name VS participants with diagnosed asthma:"
awk -F "$" '{if (($4 == "nan") && ($6 == "nan")) print}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $1}' | sort | uniq -c

#Only read v2:
echo "Compare participants with primary care prescription for moderate-severe asthma only read v2 VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if ($4 != "nan") print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only dm+d code
echo "Compare participants with primary care prescription for moderate-severe asthma only dm+d VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if ($6 != "nan") print $1}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c

#Only drug name
echo "Compare participants with primary care prescription for moderate-severe asthma only drug name VS participants with diagnosed asthma without obstructive pulmonary diseases:"
awk -F "$" '{if (($4 == "nan") && ($6 == "nan")) print}' ${PATH_DATA}/QC_modsevasthma_gp_scripts.txt | sort -u | awk -F "$" '{print $1".0"}' | grep -w -F -f - ../data/asthma_ukbiobank_master_app56607.sample | awk '{print $2}' | sort | uniq -c




#Medication in QC_asthma_gp_scripts and in the key term from the asthma list of medication:
echo "Medication in QC_asthma_gp_scripts and in the key term from the asthma list of medication:"
awk -F "$" '{print $7}' ../data/QC_asthma_gp_scripts.txt | grep -i -f ../data/asthma_meds_key_term.txt | sort -u | wc -l


#Venn Diagram in R to compare participants with the three different source for asthma medication (drug_name, dmd_code, readv2_code):
module load R
Rscript ${PATH_SCRIPTS}/venn_diagram.R
