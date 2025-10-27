#!/usr/bin/env Rscript

#upload required libraries
library(data.table)
library(tidyverse)
library(VennDiagram)
library(gplots)
library(UpSetR)
#avoid log file for venn diagrams
futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")

#load input:
path_prefix <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"

asthma_diagnosis_file <- paste0(path_prefix,"Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence.txt")
asthma_diagnosis <- fread(asthma_diagnosis_file)

asthma_date_of_report_file <- paste0(path_prefix,"Date_of_asthma_report_42014.csv")
asthma_date_of_report <- fread(asthma_date_of_report_file,sep=",")
#remove NAs:
asthma_date_of_report <- na.omit(asthma_date_of_report)
colnames(asthma_date_of_report)[2] <- "field_42014"
#remove records with 1900-01-01 'Date is unknown' and 1999-01-01 'Date is invalid'
asthma_date_of_report <- subset(asthma_date_of_report, field_42014 != as.Date("1900-01-01") & field_42014 != as.Date("1999-01-01"))

asthma_source_of_report_file <- paste0(path_prefix,"Source_of_report_of_J45_J46_131495_131497.csv")
asthma_source_of_report <- fread(asthma_source_of_report_file,sep=",")
asthma_source_of_report_J45 <- na.omit(asthma_source_of_report %>% select('eid','131495-0.0'))
asthma_source_of_report_J46 <- na.omit(asthma_source_of_report %>% select('eid','131497-0.0'))

#venn diagram asthma diagnosis VS date of report VS source of report J45 VS source of report J46
venn.diagram(
   x = list(
     asthma_diagnosis %>% select(V1) %>% distinct() %>% unlist(),
     asthma_date_of_report %>% select(eid) %>% distinct() %>% unlist(),
     asthma_source_of_report_J45 %>% select(eid) %>% distinct() %>% unlist(),
     asthma_source_of_report_J46 %>% select(eid) %>% distinct() %>% unlist()
    ),
   category.names = c("diagnosis", "date of report", "source of report J45", "source of report J46"),
   filename = paste0(path_prefix,"Venn_asthma_phenotypes.png"),
   output = TRUE ,
           imagetype="png" ,
           height = 800 ,
           width = 800 ,
           resolution = 400,
           compression = "lzw",
           lwd = 1,
           col=c("#440154ff", '#21908dff', '#fde725ff', '#add8e6'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3), alpha('#fde725ff',0.3), alpha('#add8e6',0.3)),
           cex = 0.5,
           fontfamily = "sans",
           cat.cex = 0.3,
           cat.default.pos = "outer")

#use venn() in package gplots to obtain the list of participants for each intersection:
listInput <- list(asthma_diagnosis %>% select(V1) %>% distinct() %>% unlist(),
     asthma_date_of_report %>% select(eid) %>% distinct() %>% unlist(),
     asthma_source_of_report_J45 %>% select(eid) %>% distinct() %>% unlist(),
     asthma_source_of_report_J46 %>% select(eid) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("diagnosis", "date of report", "source of report J45",
"source of report J46"))
#write into an output file the intersection:
file.create(paste0(path_prefix,"Eid_intersection_asthma_phenotypes.txt"))
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"Eid_intersection_asthma_phenotypes.txt"),append=T,row.names = FALSE, quote=FALSE)}

#write in a file the participants in asthma diagnosis phenotype definition only
write.table(attributes(ItemsList)$intersections$'A',paste0(path_prefix,"Eid_asthma_diagnosis_only.txt"),
row.names = FALSE, col.names = FALSE ,quote=FALSE)

#SetUp plot with each category in the asthma diagnosis phenotype to understand at which category the participants in
#asthma diagnosis only belong to
#load input:
asthma_selfrepdocdiagnosed_6251_file <- paste0(path_prefix,"QC_asthma_selfrepdocdiagnosed_6152.txt")
asthma_selfrepdocdiagnosed_6251 <- fread(asthma_selfrepdocdiagnosed_6251_file, sep=",")

asthma_selfrepdocdiagnosed_22127_file <- paste0(path_prefix,"QC_asthma_selfrepdocdiagnosed_22127.txt")
asthma_selfrepdocdiagnosed_22127 <- fread(asthma_selfrepdocdiagnosed_22127_file,sep=",")

asthma_gpclincal <- paste0(path_prefix,"QC_asthma_gp_clinical.txt")
asthma_gpclincal <- fread(asthma_gpclincal,header=F,sep="\t")

asthma_hes_file <- paste0(path_prefix,"QC_hesin_diag_asthma.txt")
asthma_hes <- fread(asthma_hes_file,header=T)
asthma_hes_L1 <- asthma_hes %>% filter(level == 1)
asthma_hes_L2 <- asthma_hes %>% filter(level == 2)

asthma_primary_death_file <- paste0(path_prefix,"QC_asthma_PrimaryCauseOfDeath_40001.txt")
asthma_primary_death <- fread(asthma_primary_death_file,header=F)

asthma_secondary_death_file <- paste0(path_prefix,"QC_asthma_SecondaryCauseOfDeath_40002.txt")
asthma_secondary_death <- fread(asthma_secondary_death_file,header=F,fill=T)

listInput <- list(
selfrep_6251 = c(asthma_selfrepdocdiagnosed_6251 %>% select(V1) %>% distinct() %>% unlist()),
selfrep_22127 = c(asthma_selfrepdocdiagnosed_22127 %>% select(V1) %>% distinct() %>% unlist()),
gp_clinical = c(asthma_gpclincal %>% select(V1) %>% distinct() %>% unlist()),
hes = c(asthma_hes %>% select(app56607_ids) %>% distinct() %>% unlist()),
hes_L1 = c(asthma_hes_L1 %>% select(app56607_ids) %>% distinct() %>% unlist()),
hes_L2 = c(asthma_hes_L2 %>% select(app56607_ids) %>% distinct() %>% unlist()),
primary_death = c(asthma_primary_death %>% select(V1) %>% distinct() %>% unlist()),
secondary_death = c(asthma_secondary_death %>% select(V1) %>% distinct() %>% unlist()),
diagnosis_only = c(as.data.frame(attributes(ItemsList)$intersections$'A') %>% distinct() %>% unlist())
)

pdf(file=paste0(path_prefix,"UpSet_asthma_diagnosis_only_categories.pdf"), height = 30, width = 120, onefile=FALSE)
upset(fromList(listInput), nsets = 9, order.by = "freq", number.angles = 0, point.size = 2, line.size = 0.5,
mainbar.y.label = "UK Biobank Participants Intersections", sets.x.label = "Participants Per asthma phenotype and/or diagnosis type",
empty.intersections = "on", group.by = "sets",
set_size.show = TRUE, set_size.angles = -45, text.scale = c(3.5,2,2.5,1.8,3,2))
dev.off()

