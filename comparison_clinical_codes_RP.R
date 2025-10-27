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

#ASTHMA
V2 <- fread(paste0(path_prefix,"Readv2_AsthmaP2_algorithm_outcome_codes"),header=FALSE)
V2_RP <- fread(paste0(path_prefix,"V2_asthma_codes_rated.csv"),header=FALSE)
V3 <- fread(paste0(path_prefix,"ReadCTV3_Asthma_codes"),header=FALSE)
V3_RP <- fread(paste0(path_prefix,"V3_asthma_codes_rated.csv"),header=FALSE)
ICD9 <- fread(paste0(path_prefix,"ICD9_AsthmaP2_algorithm_outcome_codes"),header=FALSE)
ICD9_RP <- fread(paste0(path_prefix,"ICD9_asthma_codes_rated.csv"),header=FALSE)
ICD10 <- fread(paste0(path_prefix,"ICD10_AsthmaP2_algorithm_outcome_codes"),header=FALSE)
ICD10_RP <- fread(paste0(path_prefix,"ICD10_asthma_codes_rated.csv"),header=FALSE)

#edit of some values to be able to compare them:
ICD10$V1 <- gsub("\\.","",ICD10$V1)
ICD10$V1 <- gsub("J46X","J46",ICD10$V1)
ICD9$V1 <- gsub("\\.","",ICD9$V1)

#venn diagrams asthma clinical codes
## Initiate writing to PDF file
#pdf(paste0(path_prefix,"asthma_clinical_codes_RP_venndiagram.pdf"), height = 8, width = 20, paper = "letter")
png(paste0(path_prefix,"asthma_clinical_codes_RP_venndiagram.png"))
#V2

V2_venn <- venn.diagram(
   x = list(
     V2 %>% select(V1) %>% distinct() %>% unlist(),
     V2_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("V2","V2_RP"),
   main = "V2 venn diagram",
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

V3_venn <- venn.diagram(
   x = list(
     V3 %>% select(V1) %>% distinct() %>% unlist(),
     V3_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("V3","V3_RP"),
   main = "V3 venn diagram",
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

ICD9_venn <- venn.diagram(
   x = list(
     ICD9 %>% select(V1) %>% distinct() %>% unlist(),
     ICD9_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("ICD9","ICD9_RP"),
   main = "ICD9 venn diagram",
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

ICD10_venn <- venn.diagram(
   x = list(
     ICD10 %>% select(V1) %>% distinct() %>% unlist(),
     ICD10_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("ICD10","ICD10_RP"),
   main = "ICD10 venn diagram",
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

pushViewport(plotViewport(layout=grid.layout(2, 2)))
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=1))
grid.draw(V2_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=1))
grid.draw(V3_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=2))
grid.draw(ICD9_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=2))
grid.draw(ICD10_venn)

## Stop writing to the PDF file
dev.off()


#use venn() in package gplots to obtain the list of codes for each intersection:
listInput <- list(V2 %>% select(V1) %>% distinct() %>% unlist(),
     V2_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("V2","V2_RP"))
#write into an output file the intersection:
file.create(paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"))
code_type <- "V2"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(V3 %>% select(V1) %>% distinct() %>% unlist(),
     V3_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("V3","V3_RP"))
code_type <- "V3"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(ICD9 %>% select(V1) %>% distinct() %>% unlist(),
     ICD9_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("ICD9","ICD9_RP"))
code_type <- "ICD9"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(ICD10 %>% select(V1) %>% distinct() %>% unlist(),
     ICD10_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("ICD10","ICD10_RP"))
code_type <- "ICD10"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_asthma.txt"),append=T,row.names = FALSE, quote=FALSE)}

#######################################################################################################################
#emphysema/chronic bronchitis
#ICD10: J40,J41,J42,J43
#ICD9: 491,492
#readv2: ${PATH_DATA}/ecb_readv2_codes
#readCTV3: ${PATH_DATA}/ecb_readCTV3_codes

V2 <- fread(paste0(path_prefix,"ecb_readv2_codes"),header=FALSE)
V2_RP <- fread(paste0(path_prefix,"V2_COPD_codes_rated.csv"),header=FALSE)
V3 <- fread(paste0(path_prefix,"ecb_readCTV3_codes"),header=FALSE)
V3_RP <- fread(paste0(path_prefix,"V3_COPD_codes_rated.csv"),header=FALSE)
V1 = c("491", "492")
ICD9 <- data.frame(V1)
ICD9_RP <- fread(paste0(path_prefix,"ICD9_COPD_codes_rated.csv"),header=FALSE)
V1 = c("J40", "J41", "J42", "J43")
ICD10 <- as.data.frame(V1)
ICD10_RP <- fread(paste0(path_prefix,"ICD10_COPD_codes_rated.csv"),header=FALSE)

#venn diagrams emphysema/chronic bronchitis clinical codes
## Initiate writing to PDF file
#pdf(paste0(path_prefix,"ecb_clinical_codes_RP_venndiagram.pdf"), height = 8, width = 20, paper = "letter")
png(paste0(path_prefix,"ecb_clinical_codes_RP_venndiagram.png"))
#V2
V2_venn <- venn.diagram(
   x = list(
     V2 %>% select(V1) %>% distinct() %>% unlist(),
     V2_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("V2","V2_RP"),
   main = "V2 venn diagram",
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

V3_venn <- venn.diagram(
   x = list(
     V3 %>% select(V1) %>% distinct() %>% unlist(),
     V3_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("V3","V3_RP"),
   main = "V3 venn diagram",
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

ICD9_venn <- venn.diagram(
   x = list(
     ICD9 %>% select(V1) %>% distinct() %>% unlist(),
     ICD9_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("ICD9","ICD9_RP"),
   main = "ICD9 venn diagram",
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

ICD10_venn <- venn.diagram(
   x = list(
     ICD10 %>% select(V1) %>% distinct() %>% unlist(),
     ICD10_RP %>% select(V1) %>% distinct() %>% unlist()
    ),
   category.names = c("ICD10","ICD10_RP"),
   main = "ICD10 venn diagram",
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

pushViewport(plotViewport(layout=grid.layout(2, 2)))
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=1))
grid.draw(V2_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=1))
grid.draw(V3_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=1, layout.pos.row=2))
grid.draw(ICD9_venn)
popViewport()
pushViewport(plotViewport(layout.pos.col=2, layout.pos.row=2))
grid.draw(ICD10_venn)

## Stop writing to the PDF file
dev.off()


#use venn() in package gplots to obtain the list of participants for each intersection:
listInput <- list(V2 %>% select(V1) %>% distinct() %>% unlist(),
     V2_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("V2","V2_RP"))
#write into an output file the intersection:
file.create(paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"))
code_type <- "V2"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(V3 %>% select(V1) %>% distinct() %>% unlist(),
     V3_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("V3","V3_RP"))
code_type <- "V3"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(ICD9 %>% select(V1) %>% distinct() %>% unlist(),
     ICD9_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("ICD9","ICD9_RP"))
code_type <- "ICD9"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE, quote=FALSE)}


listInput <- list(ICD10 %>% select(V1) %>% distinct() %>% unlist(),
     ICD10_RP %>% select(V1) %>% distinct() %>% unlist())
ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("ICD10","ICD10_RP"))
code_type <- "ICD10"
write.table(code_type, paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE,
    col.names = FALSE, quote=FALSE)
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
paste0(path_prefix,"clinical_codes_RP_intersection_ecb.txt"),append=T,row.names = FALSE, quote=FALSE)}