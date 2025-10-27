#!/usr/bin/env Rscript
library(tidyverse)
library(VennDiagram)
library(data.table)

#load the primary care scripts for asthma
asthma_scripts <- fread("../data/QC_asthma_gp_scripts.txt",sep="$")

venn.diagram(
  x = list(
    asthma_scripts %>% filter(drug_name !="nan") %>% select(eid) %>% distinct() %>% unlist() , 
    asthma_scripts %>% filter(dmd_code !="NaN") %>% select(eid) %>% distinct() %>% unlist() , 
    asthma_scripts %>% filter(read_2 !="nan") %>% select(eid) %>% distinct() %>% unlist()
    ),
  category.names = c("drug_name" , "dmd_code" , "read_v2_code"),
  filename = '../data/QC_asthma_gp_scripts_venn_participants.png',
  output = TRUE ,
          imagetype="png" ,
          height = 480 , 
          width = 480 , 
          resolution = 300,
          compression = "lzw",
          lwd = 1,
          col=c("#440154ff", '#21908dff', '#fde725ff'),
          fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3), alpha('#fde725ff',0.3)),
          cex = 0.5,
          fontfamily = "sans",
          cat.cex = 0.3,
          cat.default.pos = "outer",
          cat.pos = c(-27, 27, 135),
          cat.dist = c(0.055, 0.055, 0.085),
          cat.fontfamily = "sans",
          cat.col = c("#440154ff", '#21908dff', '#fde725ff'),
          rotation = 1
        )

#load asthma diagnosed and asthma diagnosed without obtructive pulmonary diseases
asthma_UKBB <- fread("../data/asthma_ukbiobank_master_app56607.sample")
colnames(asthma_UKBB) <- c("asthma", "asthma_excl", "eid")

#merge primary care data and asthma from UKBB :
merge_asthma <- left_join(asthma_UKBB,asthma_scripts,by="eid")


merge_asthma$drug_name_Bool <- ifelse(merge_asthma$drug_name != "nan", 1, 0)
merge_asthma$dmd_code_Bool <- ifelse(merge_asthma$dmd_code != "NaN", 1, 0)
merge_asthma$read_2_code_Bool <- ifelse(merge_asthma$read_2 != "nan", 1, 0)
