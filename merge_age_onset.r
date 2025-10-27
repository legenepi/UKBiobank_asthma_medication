#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"

demo_file <- paste0(path_prefix,"gen_demographics.txt")

demo <- fread(demo_file,sep="\t")

demo <- demo %>% mutate(age_onset_merge = ifelse(!is.na(demo$age_onset_doc), demo$age_onset_doc,
ifelse(demo$age_onset == -1, as.numeric(demo$age_onset_merge),
ifelse(demo$age_onset == -3, as.numeric(demo$age_onset_merge),
ifelse(!is.na(demo$age_onset),demo$age_onset,as.numeric(demo$age_onset_merge))))))

#age <18 'early onset', age >= 18 'adult onset':
demo <- demo %>% mutate(category_onset = ifelse(is.na(demo$age_onset_merge),as.numeric(demo$category_onset),
ifelse(demo$age_onset_merge < 18, "onset_early", "onset_adult")))

write.table(demo,paste0(path_prefix,"demographics.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep="\t", na = "NA")