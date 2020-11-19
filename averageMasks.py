### This script averages all of the masks that have been warped to the group template
###
### Ellyn Butler
### November 17, 2020 - November 19, 2020


import nibabel as nib
import numpy as np
import pandas as pd
import os
from copy import deepcopy

# List the masks in group template space
files = os.listdir('/data/output/')

for tissue in ['Brainstem', 'CSF', 'Cerebellum', 'GMCortical', 'GMDeep', 'WMCortical']:
    masks = [file for file in files if tissue+'_mask_Normalizedto' in file]
    projectName = masks[0].split('_')[4].split('.')[0].replace('Normalizedto', '').replace('Template', '')
    masks_array = []
    for mask in masks:
        img = nib.load('/data/output/'+mask)
        img_array = img.get_fdata()
        masks_array.append(img_array)
    mask_average_array = np.average(masks_array, axis=0)
    mask_average = nib.Nifti1Image(mask_average_array, affine=img.affine)
    mask_average.to_filename('/data/output/'+tissue+'_Normalizedto'+projectName+'Template_averageMask.nii.gz')
