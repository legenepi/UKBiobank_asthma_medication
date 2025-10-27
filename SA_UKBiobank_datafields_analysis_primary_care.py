#!/usr/bin/env python

#load library
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import re

#AIM:RETRIEVE READV2 AND DMD CODE OF PRIMARY CARE PRESCRIPTION FOR ASTHMA USING KEY TERM IN DRUG NAME FROM ASTHMA MEDICATION FROM SELF_REPORTED DATA


#1 Read v2 - Retrieve Read v2 code for asthma medication from a look up table of Read v2 code for prescription
#Upload asthma_meds_key_term
asthma_meds_key_term = pd.read_table("/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/asthma_meds_key_term.txt",header=None)
asthma_meds_key_term = asthma_meds_key_term.rename(columns={0: 'key_term'})
#and create the safe match
asthma_meds_key_term_list = asthma_meds_key_term.key_term.unique().tolist()
safe_match_asthma_meds_key_term = [re.escape(m) for m in [str(x) for x in asthma_meds_key_term_list]]
#Upload the readv2 code for drug (aka read v2 for prescription)
all_lkps_maps_v3_file = "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/all_lkps_maps_v3.xlsx"
read_v2_drugs = pd.read_excel(all_lkps_maps_v3_file, sheetname="read_v2_drugs_lkp")
read_v2_drugs = read_v2_drugs.applymap(str)
asthma_read_v2_drugs = read_v2_drugs[read_v2_drugs["term_description"].str.contains('|'.join(safe_match_asthma_meds_key_term),case=False)]
asthma_read_v2_drugs_code = asthma_read_v2_drugs.read_code.unique().tolist()
asthma_read_v2_drugs.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/asthma_code_read_v2_drugs.txt',index=False,sep="\t")


#2 DM+D - Retrieve dm+d code for asthma medication from a look up table of dm+d code for prescription
dmd = pd.read_excel(all_lkps_maps_v3_file, sheetname="dmd_lkp")
dmd = dmd.applymap(str)
asthma_dmd = dmd[dmd["term"].str.contains('|'.join(safe_match_asthma_meds_key_term),case=False)]
asthma_dmd.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/asthma_code_dmd.txt',index=False,sep="\t")
