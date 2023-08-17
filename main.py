
#%%

import matlab.engine
import mne
import numpy as np
import pandas as pd
import scipy.io as sio




# %%
f = open('./Results/sub1/sub101.txt')
import csv

# %%
import pandas as pd

# for i in range(1,5):
#     account = pd.read_csv(f'./Results/pilot1/Timo{i}.txt',delimiter = '\t')
#     account.to_csv(f'Timo{i}.csv', index=False)

for i in range(1):
    for j in range(1,5):
        account = pd.read_csv(f'./Results/sub{i}/sub{i}{j}.txt',delimiter = '\t')
        account.to_csv(f'./Results/sub{i}/sub{i}{j}.csv', index=False)
    
    




# %%
