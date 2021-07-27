### Average all of the tissue classication images in the group template space
### to create tissue class priors (divide by sum of the voxels if they are all
### non-zero, and do nothing otherwise)
###
### Ellyn Butler
### November 17, 2020 - February 4, 2021


import os
import glob
import numpy as np
import pandas as pd
import nibabel as nib
from copy import deepcopy
from numpy import inf

# Path to masks dir
maskDir= '/data/output/masks/'

tissues_dict = {
    'Brainstem':[], 'CSF':[], 'Cerebellum':[], 
    'GMCortical':[], 'GMDeep':[], 'WMCortical':[]}

# Declare an empty array in shape of tissue mask images.
maskFile = glob.glob(maskDir + "*" + tissue + "-clean_WarpedTo*Template.nii.gz")[0]
img = nib.load(maskFile)
img_array = img.get_fdata()
sum_all_tissues = np.zeros(img_array.shape)

# For each tissue type, sum mask arrays and story in dict.
for tissue in tissues_dict.keys():
    
    # Get all cleaned, normalized masks of current tissue type
    masks = glob.glob(maskDir + "*" + tissue + "-clean_WarpedTo*Template.nii.gz")
        
    mask_arrays = []
    for mask in masks:
        img = nib.load(mask)
        img_array = img.get_fdata()
        mask_arrays.append(img_array)
    
    # Sum values across all masks of given tissue type.
    tissues_dict[tissue] = np.sum(mask_arrays, axis=0)

    # Add sum for current tissue type to overall tissues sum
    sum_all_tissues = sum_all_tissues + tissues_dict[tissue]

# For each tissue type, get weighted (scaled?) avg by 
# dividing sum for given tissue type by sum of all tissues @ each voxel.
for tissue in tissues_dict.keys():

    # Get weighted average mask for tissue type
    tissues_dict[tissue] = np.true_divide(tissues_dict[tissue], sum_all_tissues)

    # Convert all NaN to 0
    tissues_dict[tissue][np.isnan(tissues_dict[tissue])] = 0

    # Output average tissue mask to priors subdirectory.
    avg_mask = nib.Nifti1Image(tissues_dict[tissue], affine=img.affine)
    avg_mask.to_filename('/data/output/priors/' + projectName + 'Template_' + tissue + '-prior.nii.gz')


#This should just be 0s and 1s:
#np.unique(tissues_dict['Brainstem'] + tissues_dict['CSF'] + tissues_dict['Cerebellum'] + tissues_dict['GMCortical'] + tissues_dict['GMDeep'] + tissues_dict['WMCortical'])
