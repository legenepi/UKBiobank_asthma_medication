#!/usr/bin/env python

#load package
import numpy as np
import pandas as pd
import os
from functools import reduce

#suffix for path
homefolder="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
datafolder="/data/gen1/UKBiobank_500K/severe_asthma/data/"
outputfolder="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output/"
asthmastratfolder="/home/n/nnp5/PhD/PhD_project/UKBiobank_asthmaMeds_stratification/data/"

#load files

#eid to be taken from basket ukb48371 using to biobank tools, so I already have the data without withdrawns !

#asthma diagnosis eid
asthma_eid = pd.read_csv(os.path.join(asthmastratfolder,
                         'Eid_intersection_asthma_diagnosis_ATLEAST_1_evidence_noecb_noCOPD_nowithdrawns.txt'),
                         sep=",", index_col = False, header = None)
asthma_eid = asthma_eid.rename(columns={0: 'eid'})
asthma_eid['asthma_diagnosis'] = 1

#cases eid
cases_eid = pd.read_csv(os.path.join(asthmastratfolder,
                                      'eid_bts2019_4plus'),sep=",",index_col = False, header = None)
cases_eid = cases_eid.rename(columns={0: 'eid'})
cases_eid['cases'] = 1

#controls eid
controls_eid = pd.read_csv(os.path.join(homefolder,
                                      'Eid_control_respiratoryfree.txt'),sep=",",index_col = False, header = None)
controls_eid = controls_eid.rename(columns={0: 'eid'})
controls_eid['controls'] = 1

#smoking_status
smoking_status = pd.read_csv(os.path.join(homefolder, 'Smoking_status_20116.txt'),sep=",", index_col = False,
                        header=0)

source_col_loc = smoking_status.columns.get_loc('20116-0.0')
smoking_status['collated'] = smoking_status.iloc[:,source_col_loc:source_col_loc+3].apply(
    lambda x: "".join(x.astype(str)), axis=1)
smoking_status['collated'] = smoking_status.collated.replace('nan','', regex=True)
smoking_status['smoking_status'] = smoking_status['collated'].str[-3:]
smoking_status['smoking_status'] = smoking_status.smoking_status.replace('3.0','-3.0', regex=True)
smoking_status['smoking_status'] = smoking_status.smoking_status.replace('','NaN', regex=True)
smoking_status = smoking_status[['eid','smoking_status']]

#cigarette_pack_years
cigarette_pack_years = pd.read_csv(os.path.join(homefolder, 'Pack_years_of_smoking_20161.txt'), sep=",", index_col=False,
                            header=0)
source_col_loc = cigarette_pack_years.columns.get_loc('20161-0.0')
cigarette_pack_years['collated'] = cigarette_pack_years.iloc[:,source_col_loc:source_col_loc+3].apply(
    lambda x: ",".join(x.astype(str)), axis=1)
cigarette_pack_years['collated'] = cigarette_pack_years.collated.replace(',nan','', regex=True)
cigarette_pack_years['collated'] = cigarette_pack_years.collated.replace('nan','', regex=True)
cigarette_pack_years['cigarette_pack_years'] = cigarette_pack_years['collated'].str.split(',').str[-1]
cigarette_pack_years = cigarette_pack_years.convert_objects(convert_numeric=True)
cigarette_pack_years = cigarette_pack_years[['eid','cigarette_pack_years']]

#age at recruitment
age_at_recruitment = pd.read_csv(os.path.join(homefolder, 'Age_at_recruitment_21022.txt'),sep=",", index_col = False,
                        header=0)
age_at_recruitment = age_at_recruitment.rename(columns={'21022-0.0': 'age_at_recruitment'})

#genetic sex
genetic_sex = pd.read_csv(os.path.join(homefolder, 'Genetic_sex_22001.txt'),sep="\t", index_col = False, header = 0)
#withdrawn participants
withdrawns = pd.read_csv(os.path.join(homefolder,'Eid_withdrawn_participants_upFeb2022.txt'),sep=",", index_col = False,
                         header = None)
withdrawns = withdrawns.rename(columns={0: 'eid'})
qc_genetic_sex = genetic_sex[~genetic_sex.eid.isin(withdrawns.eid)]
qc_genetic_sex = qc_genetic_sex.rename(columns={'22001-0.0': 'genetic_sex'})


#BMI
BMI = pd.read_csv(os.path.join(homefolder,'BMI_23104.txt'),sep=",", index_col = False, header = 0)
source_col_loc = BMI.columns.get_loc('23104-0.0')
BMI['collated'] = BMI.iloc[:,source_col_loc:source_col_loc+3].apply(
    lambda x: ",".join(x.astype(str)), axis=1)
BMI['collated'] = BMI.collated.replace(',nan','', regex=True)
BMI['collated'] = BMI.collated.replace('nan','', regex=True)
BMI['BMI'] = BMI['collated'].str.split(',').str[-1]
BMI = BMI.convert_objects(convert_numeric=True)
BMI = BMI[['eid','BMI']]

#exhacerbation

#exhacerbation_frequency

#lung_function_raw_FEV1
lung_function_raw_FEV1 = pd.read_csv(os.path.join(homefolder,'Best_measure_FEV1_20150.txt'),sep=",", index_col = False,
                                     header = 0)
lung_function_raw_FEV1 = lung_function_raw_FEV1.rename(columns={'20150-0.0': 'best_FEV1'})

#lung_function_percent_predict_FEV1
lung_function_percent_predict_FEV1 = pd.read_csv(os.path.join(homefolder,'Predicted_percentage_FEV1_20154.txt'),sep=",",
                                                 index_col = False, header = 0)
lung_function_percent_predict_FEV1 = lung_function_percent_predict_FEV1.rename(columns={'20154-0.0': 'perc_pred_FEV1'})

#lung_function_FEV1/FVC
FEV1_FVC_ratio = pd.read_csv(os.path.join(homefolder, 'Best_FEV1_FVC_ratio_20150_20151.txt'),sep="\t", index_col = False,
                        header=0)

#Age onset asthma
#datafield 3786
age_onset = pd.read_csv(os.path.join(homefolder, 'Age_asthma_diagnosed_3786.txt'),sep=",", index_col = False,
                        header=0)
source_col_loc = age_onset.columns.get_loc('3786-0.0')
age_onset['collated'] = age_onset.iloc[:,source_col_loc:source_col_loc+3].apply(
    lambda x: ",".join(x.astype(str)), axis=1)
age_onset['collated'] = age_onset.collated.replace(',nan','', regex=True)
age_onset['collated'] = age_onset.collated.replace('nan','', regex=True)
age_onset['age_onset'] = age_onset['collated'].str.split(',').str[-1]
age_onset = age_onset.convert_objects(convert_numeric=True)
age_onset = age_onset[['eid','age_onset']]


#datafield 22147
age_onset_doc = pd.read_csv(os.path.join(homefolder, 'Age_asthma_diagnosed_doctor_22147.txt'),sep="\t",
    index_col = False, header = 0)
qc_age_onset_doc = age_onset_doc[~age_onset_doc.eid.isin(withdrawns.eid)]
qc_age_onset_doc = qc_age_onset_doc.rename(columns={'22147.0.0': 'age_onset_doc'})
qc_age_onset_doc = qc_age_onset_doc.convert_objects(convert_numeric=True)
"""qc_age_onset_doc.loc[(qc_age_onset_doc['age_onset_doc'] < 18), 'category_age_doc'] = 'early_onset'
qc_age_onset_doc.loc[(qc_age_onset_doc['age_onset_doc'] >= 18), 'category_age_doc'] = 'adult_onset'"""

#Ethnic background
ethnic_background = pd.read_csv(os.path.join(homefolder, 'Ethnic_background_21000.txt'),sep=",", index_col = False,
                        header=0)
source_col_loc = ethnic_background.columns.get_loc('21000-0.0')
ethnic_background['collated'] = ethnic_background.iloc[:,source_col_loc:source_col_loc+3].apply(
    lambda x: ",".join(x.astype(str)), axis=1)
ethnic_background['collated'] = ethnic_background.collated.replace(',nan','', regex=True)
ethnic_background['ethnic_background'] = ethnic_background['collated'].str.split(',').str[-1]
ethnic_background['ethnic_background'] = ethnic_background.ethnic_background.replace('','NaN', regex=True)
ethnic_background = ethnic_background[['eid','ethnic_background']]



#genetic_ancestry_cluster and PCs
genetic_ancestry_cluster_PCs = pd.read_csv(os.path.join(datafolder, 'ukbiobank_master_app56607.sample'),sep=" ",
                        index_col = False, header=0)
genetic_ancestry_cluster_PCs = genetic_ancestry_cluster_PCs.drop(["app648_ids","array","age_at_recruitment",
                                                          "age_at_recruitment2","EVERSMK","PY","asthma",
                                                          "asthma_excl", "withdrawn","withdrawals_aug21"], axis = 1)
genetic_ancestry_cluster_PCs['app56607_ids'] = genetic_ancestry_cluster_PCs['app56607_ids'].astype('str')
genetic_ancestry_cluster_PCs['app56607_ids'] = genetic_ancestry_cluster_PCs['app56607_ids'].astype(str).apply(lambda x: x.replace('.0',''))
genetic_ancestry_cluster_PCs = genetic_ancestry_cluster_PCs.rename(columns={'app56607_ids': 'eid'})
genetic_ancestry_cluster_PCs.to_csv(os.path.join(homefolder,'genetic_ancestry_cluster_PCs.txt'), sep='\t', index=False)



# compile the list of dataframes to merge
data_frames = [cases_eid,controls_eid,asthma_eid,
               smoking_status,cigarette_pack_years,age_at_recruitment,
               qc_genetic_sex,BMI,lung_function_raw_FEV1,lung_function_percent_predict_FEV1,
               FEV1_FVC_ratio,age_onset,qc_age_onset_doc,ethnic_background]

demo_df = reduce(lambda  left,right: pd.merge(left,right,on=['eid'],
                                            how='outer'), data_frames).fillna('NaN')

#save demographic df:
demo_df.to_csv(os.path.join(homefolder,'tmp_demographics.txt'), sep='\t', index=False)



