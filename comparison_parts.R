#!/usr/bin/env Rscript

#Comparison list of participants for my asthma diagnosis definition and Richard Packer's asthma definition
#based on his asthma code

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

#ASTHMA
selfrep_6125 <- fread(paste0(path_prefix_output,"QC_asthma_selfrepdocdiagnosed_6152.txt"),header = FALSE) %>% select(V1)
selfrep_22127 <- fread(paste0(path_prefix_output,"QC_asthma_selfrepdocdiagnosed_22127.txt"),header = FALSE) %>% select(V1)
selfrep_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_asthma_selfreported_20002.txt"),header = FALSE) %>% select(V1)
gp_clinical <- fread(paste0(path_prefix_output,"QC_asthma_gp_clinical.txt"),header = FALSE) %>% select(V1)
gp_clinical_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_asthma_gp_clinical.txt"),header = FALSE) %>% select(V1)
hesin_diag <- fread(paste0(path_prefix_output,"QC_hesin_diag_asthma.txt"),header = TRUE) %>% select(app56607_ids)
hesin_diag_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_hesin_diag_asthma.txt"),header = FALSE) %>% select(V1)
death_primary <- fread(paste0(path_prefix_output,"QC_asthma_PrimaryCauseOfDeath_40001.txt"),header = FALSE) %>% select(V1)
death_primary_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_asthma_PrimaryCauseOfDeath_40001.txt"),header = FALSE) %>% select(V1)
death_secondary <- fread(paste0(path_prefix_output,"QC_asthma_SecondaryCauseOfDeath_40002.txt"),header = FALSE,fill=TRUE) %>% select(V1)
death_secondary_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_asthma_SecondaryCauseOfDeath_40002.txt"),header = FALSE) %>% select(V1)

NP_code <- rbind(selfrep_6125,selfrep_22127,gp_clinical,hesin_diag,death_primary,death_secondary,use.names=FALSE) %>% distinct()

RP_code <- rbind(selfrep_RP,gp_clinical_RP,hesin_diag_RP,death_primary_RP,death_secondary_RP,use.names=FALSE) %>% distinct()




## Initiate writing to PDF file
#pdf(paste0(path_prefix_data,"asthma_RP_comparison_parts_venndiagram.pdf"), height = 22, width = 20, paper = "letter")
png(paste0(path_prefix_data,"asthma_RP_comparison_parts_venndiagram.png"), width = 465, height = 600)
#overall venn diagram:
all_venn <- venn.diagram(
   x = list(
     NP_code %>% select(V1) %>% distinct() %>% unlist(),
     RP_code %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main.cex = 1,
   main = "all",
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")

#selfrep
selfrep_venn <- venn.diagram(
   x = list(
     selfrep_6125 %>% unlist(),
     selfrep_22127 %>% unlist(),
     selfrep_RP %>% unlist()
    ),
   category.names = c("selrep_6125"," selrep_22127","selrep_20002"),
   main = "selfrep",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff', '#fde725ff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3), alpha('#fde725ff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#gp_clinical
gp_clinical_venn <- venn.diagram(
   x = list(
     gp_clinical %>% unlist(),
     gp_clinical_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "gp_clinical",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#hesin_diag
hesin_diag_venn <- venn.diagram(
   x = list(
     hesin_diag %>% unlist(),
     hesin_diag_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "hesin_diag",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#death_primary
death_primary_venn <- venn.diagram(
   x = list(
     death_primary %>% unlist(),
     death_primary_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "death_primary",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#death_secondary
death_secondary_venn <- venn.diagram(
   x = list(
     death_secondary %>% unlist(),
     death_secondary_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "death_secondary",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")

pushViewport(plotViewport(layout=grid.layout(3, 2)))
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=1))
grid.draw(all_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=2))
grid.draw(selfrep_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=3))
grid.draw(gp_clinical_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=1))
grid.draw(hesin_diag_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=2))
grid.draw(death_primary_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=3))
grid.draw(death_secondary_venn)

dev.off()

#EMPHYSEMA/CHRONIC BRONCHITIS
selfrep_6125 <- fread(paste0(path_prefix_data,"eid_ecb_6152.txt"),header = FALSE) %>% select(V1)
selfrep_22128 <- fread(paste0(path_prefix_data,"eid_ecb_22128.txt"),header = FALSE) %>% select(V1)
selfrep_22129 <- fread(paste0(path_prefix_data,"eid_ecb_22129.txt"),header = FALSE) %>% select(V1)
selfrep_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_ecb_selfreported_20002.txt"),header = FALSE) %>% select(V1)
gp_clinical <- fread(paste0(path_prefix_data,"eid_ecb_gp_clinical.txt"),header = FALSE) %>% select(V1)
gp_clinical_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_ecb_gp_clinical.txt"),header = FALSE) %>% select(V1)
hesin_diag <- fread(paste0(path_prefix_data,"eid_ecb_hesin_diag.txt"),header = FALSE) %>% select(V1)
hesin_diag_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_hesin_diag_ecb.txt"),header = FALSE) %>% select(V1)
death_primary <- fread(paste0(path_prefix_data,"../data/eid_ecb_40001.txt"),header = FALSE) %>% select(V1)
death_primary_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_ecb_PrimaryCauseOfDeath_40001.txt"),header = FALSE) %>% select(V1)
death_secondary <- fread(paste0(path_prefix_data,"../data/eid_ecb_40002.txt"),header = FALSE,fill=TRUE) %>% select(V1)
death_secondary_RP <- fread(paste0(path_prefix_data,"eid_QC_RP_ecb_SecondaryCauseOfDeath_40002.txt"),header = FALSE) %>% select(V1)

NP_code <- rbind(selfrep_6125,selfrep_22128,selfrep_22129,gp_clinical,hesin_diag,death_primary,death_secondary,use.names=FALSE) %>% distinct()

RP_code <- rbind(selfrep_RP,gp_clinical_RP,hesin_diag_RP,death_primary_RP,death_secondary_RP,use.names=FALSE) %>% distinct()




## Initiate writing to PDF file
#pdf(paste0(path_prefix_data,"ecb_RP_comparison_parts_venndiagram.pdf"), height = 22, width = 20, paper = "letter")
png(paste0(path_prefix_data,"ecb_RP_comparison_parts_venndiagram.png"), height = 600, width = 400)
#overall venn diagram:
all_venn <- venn.diagram(
   x = list(
     NP_code %>% select(V1) %>% distinct() %>% unlist(),
     RP_code %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "all",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")

#selfrep
selfrep_venn <- venn.diagram(
   x = list(
     selfrep_6125 %>% unlist(),
     selfrep_22128 %>% unlist(),
     selfrep_22129 %>% unlist(),
     selfrep_RP %>% unlist()
    ),
   category.names = c("selrep_6125","selrep_22128","selrep_22129","selrep_20002"),
   main = "selfrep",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff', '#fde725ff', 'Dark Olive Green 4'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3), alpha('#fde725ff',0.3), alpha('Dark Olive Green 4',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#gp_clinical
gp_clinical_venn <- venn.diagram(
   x = list(
     gp_clinical %>% unlist(),
     gp_clinical_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "gp_clinical",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#hesin_diag
hesin_diag_venn <- venn.diagram(
   x = list(
     hesin_diag %>% unlist(),
     hesin_diag_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "hesin_diag",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#death_primary
death_primary_venn <- venn.diagram(
   x = list(
     death_primary %>% unlist(),
     death_primary_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "death_primary",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")
#death_secondary
death_secondary_venn <- venn.diagram(
   x = list(
     death_secondary %>% unlist(),
     death_secondary_RP %>% unlist()
    ),
   category.names = c("NP_code","RP_code"),
   main = "death_secondary",
   main.cex = 1,
   main.just = c(0.5, 0.6),
   filename = NULL,
   #filename = paste0(path_prefix,"V2_comparison_asthma.png"),
   output = FALSE ,
           #imagetype="png" ,
           #height = 800 ,
           #width = 800 ,
           #resolution = 400,
           #compression = "lzw",
           #lwd = 1,
           col=c("#440154ff", '#21908dff'),
           fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3)),
           cex = 0.66,
           fontfamily = "sans",
           cat.cex = 0.7,
           cat.default.pos = "outer")

pushViewport(plotViewport(layout=grid.layout(3, 2)))
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=1))
grid.draw(all_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=2))
grid.draw(selfrep_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=3))
grid.draw(gp_clinical_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=1))
grid.draw(hesin_diag_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=2))
grid.draw(death_primary_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=3))
grid.draw(death_secondary_venn)

dev.off()