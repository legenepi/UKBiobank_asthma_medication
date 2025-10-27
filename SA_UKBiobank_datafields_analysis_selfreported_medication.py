#!/usr/bin/env python

#load library
import pandas as pd
import numpy as np

#load self-reported medication file:
selfrep_meds_file = "/rfs/TobinGroup/data/UKBiobank/application_56607/20003_self_meds.csv.csv"
selfrep_meds = pd.read_csv(selfrep_meds_file,sep=",", index_col = False, header = 0)

#load medication for asthma and moderate-severe asthma (OLD version for medication)
asthma_meds_file = "/data/gen1/UKBiobank_500K/severe_asthma/data/Codes_for_asthma_diagnosis.txt"
modsevasthma_meds_file="/data/gen1/UKBiobank_500K/severe_asthma/data/Codes_for_severe_asthma_diagnosis.txt"
asthma_meds = pd.read_csv(asthma_meds_file,sep="\t", index_col = False, header = None)
asthma_meds = asthma_meds.rename(columns={0: 'Code', 1: 'Name'})
modsevasthma_meds = pd.read_csv(modsevasthma_meds_file,sep="\t", index_col = False, header = None)
modsevasthma_meds = modsevasthma_meds.rename(columns={0: 'Code', 1: 'Name'})

#some quality analysis: duplicated rows, comparison between the two medication lists
asthma_meds.loc[asthma_meds.Code.duplicated()] # two medications are repeated, therefore use unique() to get rid of duplicated rows
asthma_meds = asthma_meds.drop_duplicates(keep="first")
asthma_meds.shape
modsevasthma_meds.loc[modsevasthma_meds.Code.duplicated()] # two medications are repeated, therefore use unique() to get rid of duplicated rows
modsevasthma_meds = modsevasthma_meds.drop_duplicates(keep="first")
modsevasthma_meds.shape

#are the two list mutually exclusive ?
common_meds = pd.merge(asthma_meds,modsevasthma_meds, on = ["Code","Name"], how = "inner")
common_meds.shape # all the 65 medication(either code or name) for moderate-severe asthma are present for asthma
#each code is unique for one Name?  Yes, we have same number for Code and Name and they are the same numbers of indexes.

#retrieve patient with asthma medication
list_asthma_meds = asthma_meds['Code'].tolist()
#selfrep_meds['20003-0.0'].isin(list_asthma_meds) #gives a boolean vector for the specific column according to presence or absence of values in list_asthma_meds
#selfrep_meds.isin(list_asthma_meds) gives a dataframe with boolean values according to presence of absence of vales in list_asthma_meds
#list of booleans that I can use as filter on index to keep only participants with at least one asthma medication
bool_filter_asthma_meds = selfrep_meds.isin(list_asthma_meds).any(1).tolist() 
#use the boolean to filter participants with at least one asthma medication
asthma_selfrep_meds = selfrep_meds[bool_filter_asthma_meds]
#look at how many participants with at least one asthma medication
asthma_selfrep_meds.shape
#save
asthma_selfrep_meds.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/asthma_selfrep_meds.txt',index=False,sep="\t",float_format='%.0f')

#retrieve patient with moderate-severe asthma medication
list_modsevasthma_meds = modsevasthma_meds['Code'].tolist()
#list of booleans that I can use as filter on index to keep only participants with at least one moderate-severe asthma medication
bool_filter_modsevasthma_meds = selfrep_meds.isin(list_modsevasthma_meds).any(1).tolist()
#use the boolean to filter participants with at least one moderate-severe asthma medication
modsevasthma_selfrep_meds = selfrep_meds[bool_filter_modsevasthma_meds]
#look at how many participants with at least one moderate-severe asthma medication
modsevasthma_selfrep_meds.shape
modsevasthma_selfrep_meds.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/modsevasthma_selfrep_meds.txt',index=False,sep="\t",float_format='%.0f')
