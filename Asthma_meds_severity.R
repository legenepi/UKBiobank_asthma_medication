#!/usr/bin/env Rscript

#WAITING FOR LIST OF MEDS DIVIDED IN GROUPS FROM MIKE

#Divide into 4 disease group the list of asthma prescription found by Mike and apply same approach to the list of asthma
#medication from self-reported medication (data-field 2003)

#upload required libraries
library(data.table)
library(tidyverse)
library(VennDiagram)
library(gplots)
library(UpSetR)
#avoid log file for venn diagrams
futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")

#load input:
path_prefix_data <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
path_prefix_output <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output/"
path_prefix_gen1 <- "/data/gen1/UKBiobank_500K/severe_asthma/data/"

asthma_meds_file <- "Codes_for_asthma_diagnosis.txt"
modsevasthma_meds_file <- "Codes_for_severe_asthma_diagnosis.txt"
asthma_scripts_file <- "QC_Asthma_Meds.txt"

asthma_meds <- fread(paste0(path_prefix_output,asthma_meds_file),header = FALSE)
modsevasthma_meds <- fread(paste0(path_prefix_output,modsevasthma_meds_file),header = FALSE)
asthma_scripts <- fread(paste0(path_prefix_data,asthma_scripts_file),header = FALSE)




