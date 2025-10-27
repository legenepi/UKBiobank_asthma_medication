#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(pastecs)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"

demo_file <- paste0(path_prefix,"demographics.txt")

demo <- fread(demo_file,sep="\t")

#remove any participant neither case nor control:
qc_demo <- demo %>% filter(pheno_)

#case/control and male/female subdivision

#quantitative traits:
age_at_recruitment