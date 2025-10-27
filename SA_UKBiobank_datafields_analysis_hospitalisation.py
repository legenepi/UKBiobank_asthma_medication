#!/usr/bin/env python

#load library
import pandas as pd
import numpy as np


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
#retrieve for hesin diagnosed with ICD-10 as asthma
hesin_diag_J45 = hesin_diag[mask_icd10_J45]
hesin_diag_J45['hesin_diag_asthma'] = 2
#retrieve for hesin diagnosed with ICD-10 as 'status asthmaticus'
hesin_diag_J46 = hesin_diag[mask_icd10_J46]
hesin_diag_J46['hesin_diag_asthma'] = 3

#create file with all hopsitalisation for asthma
hesin_diag_asthma = pd.concat([hesin_diag_J46,hesin_diag_J45]).drop_duplicates().reset_index(drop=True)
hesin_diag_asthma = pd.DataFrame(pd.concat([hesin_diag_asthma,hesin_diag_493]).drop_duplicates().reset_index(drop=True))
hesin_diag_asthma = hesin_diag_asthma.rename(columns={'eid' : 'app56607_ids'})
hesin_diag_asthma["app56607_ids"] = pd.to_numeric(hesin_diag_asthma["app56607_ids"])
#saving as a .txt file to be used to find data of hospitalisation from hesin.txt and/or hesin_critical.txt:
hesin_diag_asthma.to_csv('/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/hesin_diag_asthma.txt', sep ='\t', index=False)
