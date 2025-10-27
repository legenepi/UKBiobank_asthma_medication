#!/usr/bin/env python

#load library
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

##SAMPLE FILE
#load sample file
sample_file = "/data/gen1/UKBiobank_500K/severe_asthma/data/ukbiobank_master_app56607.sample"
sample = pd.read_csv(sample_file,sep=" ", index_col = False, header = 0)

#extract app648_ids app56607_ids columns for merging with EHRs:
sample_ids = sample[['app648_ids','app56607_ids']]

##filter withdrawls after having collect all the info into the Master file.

##SELF-REPORTED MEDICATION
#load self-reported medication file
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

#retrieve patient with moderate-severe asthma medication
list_modsevasthma_meds = modsevasthma_meds['Code'].tolist()
#list of booleans that I can use as filter on index to keep only participants with at least one moderate-severe asthma medication
bool_filter_modsevasthma_meds = selfrep_meds.isin(list_modsevasthma_meds).any(1).tolist()
#use the boolean to filter participants with at least one moderate-severe asthma medication
modsevasthma_selfrep_meds = selfrep_meds[bool_filter_modsevasthma_meds]
#look at how many participants with at least one moderate-severe asthma medication
modsevasthma_selfrep_meds.shape

#compare asthma_selfrep_meds with modsevasthma_selfrep_meds
#only common participant:
same_participants = pd.merge(asthma_selfrep_meds,modsevasthma_selfrep_meds, on = "eid", how = "inner")
same_participants.shape

#flag participants with asthma medication from sample file
asthma_selfrep_meds['selfrep_meds_asthma'] = 1
asthma_selfrep_meds_eidstatus = asthma_selfrep_meds[['eid','selfrep_meds_asthma']]
asthma_selfrep_meds_eidstatus = asthma_selfrep_meds_eidstatus.rename(columns={'eid' : 'app56607_ids'})
sample_ids_asthma_selfrep_meds = pd.merge(sample_ids,asthma_selfrep_meds_eidstatus,on='app56607_ids',how='left')
sample_ids_asthma_selfrep_meds['selfrep_meds_asthma'] = sample_ids_asthma_selfrep_meds['selfrep_meds_asthma'].fillna(0)

#flag participants with moderate-severe asthma medication from sample file:
modsevasthma_selfrep_meds['selfrep_meds_asthma'] = 2
modsevasthma_selfrep_meds_eidstatus = modsevasthma_selfrep_meds[['eid','selfrep_meds_asthma']]
modsevasthma_selfrep_meds_eidstatus = modsevasthma_selfrep_meds_eidstatus.rename(columns={'eid' : 'app56607_ids'})
sample_ids_asthma_selfrep_meds.set_index('app56607_ids', inplace=True)
sample_ids_asthma_selfrep_meds.update(modsevasthma_selfrep_meds_eidstatus.set_index('app56607_ids'))
sample_ids_asthmaANDmodsev_selfrep_meds = sample_ids_asthma_selfrep_meds.reset_index()  # to recover the initial structure

##HOSPITAL INPATIENT DATA
hesin_diag_file = "/rfs/TobinGroup/data/UKBiobank/application_56607/hes/hesin_diag.txt"
hesin_diag = pd.read_csv(hesin_diag_file,sep="\t", index_col = False, header = 0)
hesin_diag = hesin_diag.applymap(str)
#create the boolean vector (aka mask) for diagnosis:
mask_icd9_493 = hesin_diag["diag_icd9"].str.contains('493').tolist()
mask_icd10_J45 = hesin_diag["diag_icd10"].str.contains('J45').tolist()
mask_icd10_J46 = hesin_diag["diag_icd10"].str.contains('J46').tolist()
#retrieve for hesin diagnosed with ICD-9 as asthma
hesin_diag_493 = hesin_diag[mask_icd9_493]
hesin_diag_493['hesin_diag_asthma'] = "1"
#hesin_diag_493 = hesin_diag_493[['hesin_diag_asthma','eid','level']]
#retrieve for hesin diagnosed with ICD-10 as asthma
hesin_diag_J45 = hesin_diag[mask_icd10_J45]
hesin_diag_J45['hesin_diag_asthma'] = 2
#hesin_diag_J45 = hesin_diag_J45[['hesin_diag_asthma','eid','level']]
#retrieve for hesin diagnosed with ICD-10 as 'status asthmaticus'
hesin_diag_J46 = hesin_diag[mask_icd10_J46]
hesin_diag_J46['hesin_diag_asthma'] = 3
#hesin_diag_J46 = hesin_diag_J46[['hesin_diag_asthma','eid','level']]

#create file with all hospitalisation for asthma 
hesin_diag_asthma = pd.concat([hesin_diag_J46,hesin_diag_J45]).drop_duplicates().reset_index(drop=True)
hesin_diag_asthma = pd.DataFrame(pd.concat([hesin_diag_asthma,hesin_diag_493]).drop_duplicates().reset_index(drop=True))
hesin_diag_asthma = hesin_diag_asthma.rename(columns={'eid' : 'app56607_ids'})
hesin_diag_asthma["app56607_ids"] = pd.to_numeric(hesin_diag_asthma["app56607_ids"])
#saving as a .txt file to be used to find data of hospitalisation from hesin.txt and/or hesin_critical.txt:
hesin_diag_asthma.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/hesin_diag_asthma.txt', sep ='\t', index=False)

#flag sample file participants with at least 1 hospitalisation event:
hesin_diag_asthma_status = pd.DataFrame(hesin_diag_asthma['app56607_ids']).drop_duplicates().reset_index(drop=True)
hesin_diag_asthma_status['hesin_diag_asthma'] = 1
sample_ids_hesin_diag_asthma = pd.merge(sample_ids,hesin_diag_asthma_status,on='app56607_ids',how='left')
sample_ids_hesin_diag_asthma['hesin_diag_asthma'] = sample_ids_hesin_diag_asthma['hesin_diag_asthma'].fillna(0)

#flag sample file participants with at least 1 hospitalisation event with diagnosis of asthma (493 OR J45 OR J46) AND with level 1:
hesin_diag_asthma_L1 = hesin_diag_asthma[hesin_diag_asthma['level'] == "1"]
hesin_diag_asthma_L1 = hesin_diag_asthma_L1[['app56607_ids','level']].drop_duplicates().reset_index(drop=True)
hesin_diag_asthma_L1 = hesin_diag_asthma_L1.rename(columns = {'level' : 'hesin_diag_asthma_level1'})
sample_ids_hesin_diag_asthma_L1 = pd.merge(sample_ids,hesin_diag_asthma_L1,on='app56607_ids',how='left')
sample_ids_hesin_diag_asthma_L1['hesin_diag_asthma_level1'] = sample_ids_hesin_diag_asthma_L1['hesin_diag_asthma_level1'].fillna(0)

#put info regarding self-medication and hospitalisation into the Master Table:
Master_Table = pd.concat([sample,
			  sample_ids_asthmaANDmodsev_selfrep_meds['selfrep_meds_asthma'],
			  sample_ids_hesin_diag_asthma['hesin_diag_asthma'],
			  sample_ids_hesin_diag_asthma_L1['hesin_diag_asthma_level1']],axis=1)
#contingency table of self-reported medication + hospitalisation for asthma and hospitalisation with asthma as level 1:
pd.crosstab([Master_Table.selfrep_meds_asthma,Master_Table.hesin_diag_asthma], Master_Table.hesin_diag_asthma_level1, margins=True)

#compare with Rahma's result (with caveat that I also included ICD-9 code for hospitalisation):
rahma = pd.read_csv("/data/gen1/UKBiobank_500K/severe_asthma/data/internship",sep=" ", index_col = False, header = 0)
pd.crosstab([rahma.med_asthma,rahma.all_hosp], rahma.level1_hosp, margins=True)

#the results look quite similar. Need to check if he number are the same without ICD-9 code for hospitalisation.

#Hospitalisation: episode start date (or admission date) retrieval from hesin.txt and hesin_critical.txt files


#PRIMARY CARE (PRESCRIPTION)
Primary care data are available for 45% (~230,000 participants) of the total biobank.
There are three main file:

 * gp_clinical.txt : about diagnosis, history, symptoms, etc.

 * gp_scripts.txt : about prescription (NB: they can be prescribed but not taken by the participants)

 * gp_registrations.txt : about admin information, referrals to specialists

There are minor exceptions with  non-coded, unstructered data.

#Upload primary care data gp_scripts.txt ##in a job scripts ! here teh test for the first 1,000,000 rows !

#in the .sh script ./SA_UKBiobank_datafields_analysis_primary_care.sh to edit the file with the correct delimiter and columns and to run as a job SA_UKBiobank_datafields_analysis_primarycare.py

###python
gp_scripts_file = "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/test_gp_scripts_edit.txt"
gp_scripts = pd.read_csv(gp_scripts_file, )

##READ V2
#Retrieve Read v2 code for asthma from Resource 594 UK Biobank:
phase2_codelist_file = "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/algorithm_outcome_codes.xlsx"
asthma_phase2_codelist = pd.read_excel(phase2_codelist_file, sheetname="Asthma - P2", skiprows=[0,1,2,3,4])
asthma_phase2_codelist_readv2 = asthma_phase2_codelist[asthma_phase2_codelist['Code Type'] == "Read V2"]
asthma_phase2_codelist_readv2_list = asthma_phase2_codelist_readv2.Code.tolist()

#Upload read_v2_lkp table from all_lkps_maps_v3.xlsx to retrieve information for synonyms terms with the same Read code V2.
#Those marked with ‘0’ in the 'term_code' column denote the preferred term. Those marked with ‘11’, ‘12’ … are synonyms.
all_lkps_maps_v3_file = "/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/all_lkps_maps_v3.xlsx"
read_v2_lkp = pd.read_excel(all_lkps_maps_v3_file, sheetname="read_v2_lkp")
#Filter only for Read code v2 for asthma:
asthma_read_v2_lkp = read_v2_lkp[read_v2_lkp['read_code'].isin(asthma_phase2_codelist_readv2_list)]

#Upload read_v2_icd9 and read_v2_icd10 from all_lkps_maps_v3.xlsx to map Read code V2 to ICD-9 and ICD-10 codes with respect to asthma condition
read_v2_icd9 = pd.read_excel(all_lkps_maps_v3_file, sheetname="read_v2_icd9")
asthma_read_v2_icd9 = read_v2_icd9[read_v2_icd9['read_code'].isin(asthma_phase2_codelist_readv2_list)]
read_v2_icd10 = pd.read_excel(all_lkps_maps_v3_file, sheetname="read_v2_icd10")
asthma_read_v2_icd10 = read_v2_icd10[read_v2_icd10['read_code'].isin(asthma_phase2_codelist_readv2_list)]

#try to map icd-9 to icd-10 codes through read code v2
asthma_read_v2_maps_icd9_TO_icd10 = pd.merge(asthma_read_v2_icd9,asthma_read_v2_icd10,on='read_code')
#and retrieve the defination for each read code v2 from asthma_phase2_codelist_readv2
asthma_phase2_codelist_readv2_tomerge = asthma_phase2_codelist_readv2[['Code','Code Description']]
asthma_phase2_codelist_readv2_tomerge = asthma_phase2_codelist_readv2_tomerge.rename(columns={'Code' : 'read_code'})
asthma_read_v2_maps_icd9_TO_icd10_withDefReadcodev2 = pd.merge(asthma_read_v2_maps_icd9_TO_icd10,asthma_phase2_codelist_readv2_tomerge,on='read_code')

##BNF
#from drug Name
bnf_lkp = pd.read_excel(all_lkps_maps_v3_file, sheetname="bnf_lkp")
bnf_lkp = bnf_lkp.applymap(str)
#initialize asthma_meds_Name_bnf_lkp
asthma_meds_Name_bnf_lkp = pd.DataFrame()
for el in asthma_meds_Name_list:
	asthma_meds_Name_bnf_lkp_tmp = bnf_lkp[bnf_lkp["BNF_Presentation"].str.lower().str.contains(el)]
	asthma_meds_Name_bnf_lkp = pd.concat([asthma_meds_Name_bnf_lkp,asthma_meds_Name_bnf_lkp_tmp])

#from read code v2


##DM+D

