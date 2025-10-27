#!/bin/env/bash


#work on venv environment:
source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate

PATH_DATA="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data"
PATH_SCRIPT="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/scripts"

#Hospitalisation check



#Compare my asthma diagnosis definition with date of asthma report datafield (42014) and the two amalgamated asthma phenotype data fields (131495, 131496) from UK Biobank
#extract the datafields with the other asthma phenotype definition
# use biobank package, select the datafields of interest and save in a file
cd ${PATH_DATA}
biobank select 42014 --output ${PATH_DATA}/Date_of_asthma_report_42014.csv

biobank select 131495,131496 --output ${PATH_DATA}/Source_of_report_of_J45_J46_131495_131496.csv

#Actual comparison analysis in R with venn diagram:
#chmod ${PATH_SCRIPT}/Comparison_asthma_phenotypes.r
#Rscript ${PATH_SCRIPT}Comparison_asthma_phenotypes.r