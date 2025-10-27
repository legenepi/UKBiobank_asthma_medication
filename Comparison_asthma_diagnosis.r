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
asthma_selfrepdocdiagnosed_6251_file <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_asthma_selfrepdocdiagnosed_6152.txt"
asthma_selfrepdocdiagnosed_6251 <- fread(asthma_selfrepdocdiagnosed_6251_file, sep=",")

asthma_selfrepdocdiagnosed_22127_file <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_asthma_selfrepdocdiagnosed_22127.txt"
asthma_selfrepdocdiagnosed_22127 <- fread(asthma_selfrepdocdiagnosed_22127_file,sep=",")

asthma_selfrepdocdiagnosed <- full_join(asthma_selfrepdocdiagnosed_6251, asthma_selfrepdocdiagnosed_22127, by="V1")

asthma_gpclincal <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_asthma_gp_clinical.txt"
asthma_gpclincal <- fread(asthma_gpclincal,header=F,sep="\t")

asthma_hes_file <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_hesin_diag_asthma.txt"
asthma_hes <- fread(asthma_hes_file,header=T)
asthma_hes_L1 <- asthma_hes %>% filter(level == 1) 
asthma_hes_L2 <- asthma_hes %>% filter(level == 2)

asthma_primary_death_file <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_asthma_PrimaryCauseOfDeath_40001.txt"
asthma_primary_death <- fread(asthma_primary_death_file,header=F)

asthma_secondary_death_file <- "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/QC_asthma_SecondaryCauseOfDeath_40002.txt"
asthma_secondary_death <- fread(asthma_secondary_death_file,header=F,fill=T)

asthma_death <- full_join(asthma_primary_death,asthma_secondary_death,by="V1")

#still waiting for amalgamated emphysema/chronic bronchitis

#venn diagram with combined self-reported fields, HES level 1 only and with combined cause of death
venn.diagram(
   x = list(
     asthma_selfrepdocdiagnosed %>% select(V1) %>% distinct() %>% unlist(),
     asthma_gpclincal %>% select(V1) %>% distinct() %>% unlist(),
     asthma_hes_L1 %>% select(app56607_ids) %>% distinct() %>% unlist(),
     asthma_death %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("selrep", "gp_clinical", "HES_L1", "cause_death"),
   filename = '../data/Venn_asthma_diagnosis.png',
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

#Use upset diagram to show all the datsets:
listInput <- list(
selfrep_6251 = c(asthma_selfrepdocdiagnosed_6251 %>% select(V1) %>% distinct() %>% unlist()),
selfrep_22127 = c(asthma_selfrepdocdiagnosed_22127 %>% select(V1) %>% distinct() %>% unlist()),
gp_clinical = c(asthma_gpclincal %>% select(V1) %>% distinct() %>% unlist()),
hes = c(asthma_hes %>% select(app56607_ids) %>% distinct() %>% unlist()),
hes_L1 = c(asthma_hes_L1 %>% select(app56607_ids) %>% distinct() %>% unlist()),
hes_L2 = c(asthma_hes_L2 %>% select(app56607_ids) %>% distinct() %>% unlist()),
primary_death = c(asthma_primary_death %>% select(V1) %>% distinct() %>% unlist()),
secondary_death = c(asthma_secondary_death %>% select(V1) %>% distinct() %>% unlist())
)

pdf(file="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/UpSet_asthma_diagnosis.pdf", height = 10, width = 44, onefile=FALSE)
upset(fromList(listInput), nsets = 8, order.by = "freq", number.angles = 0, point.size = 1.8, line.size = 0.5,
mainbar.y.label = "UK Biobank Participants Intersections", sets.x.label = "Participants Per asthma diagnosis type",
empty.intersections = "on", group.by = "sets", set_size.show = TRUE, set_size.angles = -45, text.scale = c(3,1.8,2,1.4,2.5,1.7))
dev.off()


#use venn() in package gplots to obtain the list of participants for each intersection:
listInput <- list(
asthma_selfrepdocdiagnosed_6251 %>% select(V1) %>% distinct() %>% unlist(),
asthma_selfrepdocdiagnosed_22127 %>% select(V1) %>% distinct() %>% unlist(),
asthma_gpclincal %>% select(V1) %>% distinct() %>% unlist(),
asthma_hes %>% select(app56607_ids) %>% distinct() %>% unlist(),
asthma_hes_L1 %>% select(app56607_ids) %>% distinct() %>% unlist(),
asthma_hes_L2 %>% select(app56607_ids) %>% distinct() %>% unlist(),
asthma_primary_death %>% select(V1) %>% distinct() %>% unlist(),
asthma_secondary_death %>% select(V1) %>% distinct() %>% unlist()
)
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("selrep_6251","selfrep_22127", "gp_clinical", 
"hes", "hes_L1", "hes_L2", "primary_death", "secondary_death"))

#write into an output file the intersection:
file.create("/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/Eid_intersection_asthma_diagnosis.txt")
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
"/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/Eid_intersection_asthma_diagnosis.txt",append=T,row.names = FALSE, quote=FALSE)
}


#SMALL TUTORIAL
#find counts for each intersection :
#lengths(attributes(ItemsList)$intersections)
#get the actual elements (participants' eid in my case) for each intersection:
#attributes(ItemsList)$intersections
#to retrieve a particular intersection:
#attributes(ItemsList)$intersections$'column_name'
#OR
#attributes(ItemsList)$intersections$[2] #index of the column
#to retrieve more than one intersection:
#attributes(ItemsList)$intersections[c(3,4)] #index of the columns

