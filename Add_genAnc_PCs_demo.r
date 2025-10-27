#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"

gen_file <- paste0(path_prefix,"genetic_ancestry_cluster_PCs.txt")
demo_file <- paste0(path_prefix,"tmp_demographics.txt")

gen <- fread(gen_file,sep="\t")
demo <- fread(demo_file,sep="\t")

demo_gen <- demo_gen <- left_join(demo, gen, by="eid")

write.table(demo_gen,paste0(path_prefix,"gen_demographics.txt"),
row.names = FALSE, col.names = TRUE ,quote=FALSE, sep="\t", na = "NA")

