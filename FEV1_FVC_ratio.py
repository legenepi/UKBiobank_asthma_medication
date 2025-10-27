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

#lung_function_FEV1/FVC

#lung_function_raw_FEV1
lung_function_raw_FEV1 = pd.read_csv(os.path.join(homefolder,'Best_measure_FEV1_20150.txt'),sep=",", index_col = False,
                                     header = 0)
lung_function_raw_FEV1 = lung_function_raw_FEV1.rename(columns={'20150-0.0': 'best_FEV1'})

#Forced_vital_capacity_FVC
FVC = pd.read_csv(os.path.join(homefolder,'Forced_vital_capacity_FVC_20151.txt'),sep=",", index_col = False,
                                     header = 0)
FVC = FVC.rename(columns={'20151-0.0': 'best_FVC'})
data_frames = [lung_function_raw_FEV1, FVC]

#ratio
FEV1_FVC = reduce(lambda  left,right: pd.merge(left,right,on=['eid'],
                                            how='outer'), data_frames).fillna('NaN')
FEV1_FVC = FEV1_FVC.convert_objects(convert_numeric=True)
FEV1_FVC.loc[~FEV1_FVC['best_FEV1'].isnull() &
             ~FEV1_FVC['best_FVC'].isnull(),
             'ratio_FEV1_FVC'] = FEV1_FVC['best_FEV1']/FEV1_FVC['best_FVC']
FEV1_FVC_ratio = FEV1_FVC[['eid', 'ratio_FEV1_FVC']]
FEV1_FVC_ratio.to_csv(os.path.join(homefolder,'Best_FEV1_FVC_ratio_20150_20151.txt'), sep='\t', index=False)
