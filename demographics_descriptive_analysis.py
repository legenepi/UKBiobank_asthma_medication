#!/usr/bin/env python

import numpy as np
import pandas as pd
import os
from functools import reduce
import matplotlib.pyplot as plt

#suffix for path
homefolder="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/data/"
datafolder="/data/gen1/UKBiobank_500K/severe_asthma/data/"
outputfolder="/home/n/nnp5/PhD/PhD_project/UKBiobank_datafields/output/"

#load files
demo = pd.read_csv(os.path.join(homefolder, 'demographics.txt'),sep="\t", index_col = False,
                        header=0)

