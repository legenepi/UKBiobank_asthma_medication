#!/usr/bin/env Rscript

library(tidyverse)
library(VennDiagram)
library(gplots)
library(UpSetR)

feb_2021 <- read.table("/rfs/TobinGroup/data/UKBiobank/application_56607/w56607_20210201.csv",header=F)
aug_2021 <- read.table("/rfs/TobinGroup/data/UKBiobank/application_56607/w56607_20210809.csv",header=F)
feb_2022 <- read.table("/rfs/TobinGroup/data/UKBiobank/application_56607/w56607_20220222.csv",header=F)

listInput <- list(
       feb_2021 %>% select(V1) %>% distinct() %>% unlist(),
       aug_2021 %>% select(V1) %>% distinct() %>% unlist(),
       feb_2022 %>% select(V1) %>% distinct() %>% unlist()
      )

venn.diagram(
     x = listInput,
     category.names = c("feb_2021", "aug_2021", "feb_2022"),
     filename = '../data/venn_withdrawns.png',
     output = TRUE ,
             imagetype="png" ,
             height = 800 ,
             width = 800 ,
             resolution = 400,
             compression = "lzw",
             lwd = 1,
             col=c("#440154ff", "#21908dff", "#fde725ff"),
             fill = c(alpha("#440154ff",0.3), alpha("#21908dff",0.3), alpha("#fde725ff",0.3)),
             cex = 0.5,
             fontfamily = "sans",
             cat.cex = 0.3,
             cat.default.pos = "outer")


ItemsList <- venn(listInput, show.plot = FALSE, category.names = c("feb_2022", "aug_2021", "feb_2022"))

#write into an output file the intercsection:
for (i in seq(1,length(attributes(ItemsList)$intersections))) {
write.table(attributes(ItemsList)$intersections[i],
"/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/Eid_intersection_withdrawn_participants.txt",append=T,row.names = FALSE, quote=FALSE)
}
