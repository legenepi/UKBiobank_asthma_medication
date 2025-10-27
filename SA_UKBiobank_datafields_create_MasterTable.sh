#!/bin/bash

#PBS -N SA_UKBB_create_MasterTable
#PBS -j oe
#PBS -o SA_UKBB_create_MasterTable_log
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

#interactively:
#cp ${PATH_APPL}/ukb44204.csv ${PATH_DATA}

## using of Altaf's ukbiobank tool python package:
### import ukbiobank genotyped dataset with all the fields for application 56607:
#want to have the parquet file in data folder: '--force' because I already have an imported ukb file and I have to update it
cd ${PATH_SA_DATA}
#only once:
#biobank import /rfs/TobinGroup/data/UKBiobank/application_56607/ukb48371.csv

# exclude withdrawn participants - only once
biobank exclude /rfs/TobinGroup/data/UKBiobank/application_56607/w56607_*.csv

#smoking status datafield 20116
biobank select 20116 --output  ${PATH_DATA}/Smoking_status_20116.txt

#Pack years of smoking datafield 20161
biobank select 20161 --output  ${PATH_DATA}/Pack_years_of_smoking_20161.txt

#age at recruitment
biobank select 21022 --output  ${PATH_DATA}/Age_at_recruitment_21022.txt

#lung_function_raw_FEV1: Forced expiratory volume in 1-second (FEV1), Best measure, datafield  20150
biobank select 20150 --output  ${PATH_DATA}/Best_measure_FEV1_20150.txt

#lung_function_percent_predict_FEV1 : Forced expiratory volume in 1-second (FEV1), predicted percentage, datafield 20154
biobank select 20154 --output  ${PATH_DATA}/Predicted_percentage_FEV1_20154.txt

#lung_function_FEV1/FVC : FEV1/FVC : datafield20150/datafield20151
#Forced vital capacity (FVC), Best measure datafield 20151
biobank select 20151 --output  ${PATH_DATA}/Forced_vital_capacity_FVC_20151.txt

#and in SA_UKBiobank_datafields_create_MasterTable.py calculate ratio with datafield 20150/datafield 20151

#BMI datafield 21001
biobank select 21001 --output  ${PATH_DATA}/BMI_21001.txt

#BMI datafield 23104 (Richard Packer uses this one)
biobank select 23104 --output  ${PATH_DATA}/BMI_23104.txt


#asthma age onset datafield 3786
biobank select 3786 --output  ${PATH_DATA}/Age_asthma_diagnosed_3786.txt

cd ${PATH_SCRIPT}
#genetic sex
head -n 1 ${PATH_APPL}/ukb44204.txt | tr "\t" "\n" | grep -n "22001"
#index column: 1847
awk -F "\t" {'print $1848'} ${PATH_APPL}/ukb44204.txt | sed s/"22003-0.0"/"22001-0.0"/g > \
    ${PATH_DATA}/tmp_Genetic_sex_22001.txt
awk {'print $1'} ${PATH_APPL}/ukb44204.txt | \
    paste - ${PATH_DATA}/tmp_Genetic_sex_22001.txt > \
    ${PATH_DATA}/Genetic_sex_22001.txt

#gender: not possible to retrieve the gender from UK Biobank

#exacerbation still waiting data

#exacerbation frequency still waiting data

#Age asthma diagnosed by doctor datafield 22147
#interactive
#cp /rfs/TobinGroup/data/UKBiobank/application_56607/ukb44204.txt ${PATH_DATA}/ukb44204.txt
head -n 1 ${PATH_APPL}/ukb44204.txt | tr "\t" "\n" | grep -n "22147"
#index column: 1957, but I need to take column 1958 to retrieve the real value for datafield 22147.
#I checked it on R comparing the mean and median and length of items (records not 'NA')
awk -F '\t' {'print $1958'} ${PATH_APPL}/ukb44204.txt | sed s/"22148.0.0"/"22147.0.0"/g > \
    ${PATH_DATA}/tmp_Age_asthma_diagnosed_doctor_22147.txt
awk {'print $1'} ${PATH_APPL}/ukb44204.txt | \
    paste - ${PATH_DATA}/tmp_Age_asthma_diagnosed_doctor_22147.txt > \
    ${PATH_DATA}/Age_asthma_diagnosed_doctor_22147.txt

#ethnic background
cd ${PATH_SA_DATA}
biobank select 21000 --output  ${PATH_DATA}/Ethnic_background_21000.txt
cd ${PATH_SCRIPT}

#genetic ethnic grouping as in datafield 22006 (Caucasian)
#'Indicates samples who self-identified as 'White British' according to Field 21000
#and have very similar genetic ancestry based on a principal components analysis of the genotypes.'
#It is not useful. 'Caucasian' whats mean and they have mixed the concept of genetic with ethnicity.
#So, I will not include it in the demographic table neither use it for analysis or to describe the population.

#genetic_ancestry_cluster
cp /data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample ${PATH_DATA}
dos2unix ${PATH_DATA}/ukbiobank_master_app56607.sample
#then modify in SA_UKBiobank_datafields_create_MasterTable.py and save it


#controls
qsub ${PATH_SCRIPT}/control_definition.sh
qsub ${PATH_SCRIPT}/control_definition_V2.sh

#move to SA_UKBiobank_datafields_create_MasterTable.py script
chmod o+x ${PATH_SCRIPT}/SA_UKBiobank_datafields_create_MasterTable.py
module load python
python ${PATH_SCRIPT}/SA_UKBiobank_datafields_create_MasterTable.py

#launch Add_genAnc_PCs_demo.r to add the genetically inferred ancestry and PCs to the demographic table:
chmod o+x ${PATH_SCRIPT}/Add_genAnc_PCs_demo.r
module unload R/4.2.1
module load R/4.1.0
Rscript ${PATH_SCRIPT}/Add_genAnc_PCs_demo.r

#launch merge_age_onset.r to merge asthma age onset self reported with doctor diagnosed and create column 'category onset'
chmod o+x ${PATH_SCRIPT}/merge_age_onset.r
Rscript ${PATH_SCRIPT}/merge_age_onset.r

