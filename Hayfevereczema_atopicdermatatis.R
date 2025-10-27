#!/usr/bin/env Rscript

#run this file as:
#source /home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/venv/bin/activate
#module unload R/4.2.1
#module load R/4.1.0

#upload required libraries
library(data.table)
library(tidyverse)

read2 <- read.table("data/coding1834.tsv",header=T)
read3 <- read.table("data/coding1835.tsv",header=T)
ICD_10 <- read.table("data/ICD10_allergic_reduced",header=T)

read2_dermaecz_rhinit <- inner_join(read2,ICD_10,by="meaning") %>% select(coding)
read3_dermaecz_rhinit <- inner_join(read3,ICD_10,by="meaning") %>% select(coding)

write.table(read2_dermaecz_rhinit,"data/readv2_dermaecz_rhinit",quote=F,row.names=F)
write.table(read3_dermaecz_rhinit,"data/readv3_dermaecz_rhinit",quote=F,row.names=F)