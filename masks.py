### This script creates gray matter, white matter and CSF masks for each of the
### input aseg dseg images.
###
### Ellyn Butler
### November 12, 2020 - March 16, 2021

import nibabel as nib
import numpy as np
import pandas as pd
import os
from copy import deepcopy
#from scipy import binary_dilation
from scipy import ndimage

# List the available aseg images
subjs = os.listdir('/data/input/fmriprep')
asegs = []
for subj in subjs:
    for ses in os.listdir('/data/input/fmriprep/'+subj):
        for file in os.listdir('/data/input/fmriprep/'+subj+'/'+ses+'/anat'):
            if 'desc-aseg' in file:
                asegs.append('/data/input/fmriprep/'+subj+'/'+ses+'/anat/'+file)

# Read in tissue classes
tissue_df = pd.read_csv('/data/input/tissueClasses.csv')

# Loop over asegs, and create GM, WM and CSF images
for aseg in asegs:
    aseg_img = nib.load(aseg)
    aseg_gmcort = aseg_img.get_fdata()
    # Get the corresponding mask
    fmriprepdir = os.path.dirname(aseg)
    mask = [file for file in os.listdir(fmriprepdir) if '_desc-brain_mask.nii.gz' in file and 'MNI' not in file][0]
    mask_img = nib.load(fmriprepdir+'/'+mask)
    mask_array = mask_img.get_fdata()
    # Dilate the mask
    mask_array_dilated = ndimage.binary_dilation(mask_array, iterations=4).astype(mask_array.dtype)
    #https://www.programcreek.com/python/example/93929/scipy.ndimage.binary_dilation
    #https://nilearn.github.io/manipulating_images/manipulating_images.html
    ### Call all area that is in the dilated mask but not in the original mask CSF (24)
    # 1.) Get the voxels that are in mask_array_dilated but not in the aseg image
    aseg_binary = deepcopy(aseg_gmcort)
    aseg_binary[aseg_binary > 0] = 1
    mask_array_intersection = mask_array_dilated - aseg_binary
    # 2.) Multiply the intersection by 24 (the value of CSF in freesurfer's aseg image)
    mask_array_csf = mask_array_intersection*24
    # 3.) Add the intersection to the aseg image
    aseg_gmcort_old = deepcopy(aseg_gmcort)
    aseg_gmcort = aseg_gmcort + mask_array_csf
    # Copy gm_cort for all the other tissue classes
    aseg_wmcort = deepcopy(aseg_gmcort)
    aseg_csf = deepcopy(aseg_gmcort)
    aseg_gmdeep = deepcopy(aseg_gmcort)
    aseg_bstem = deepcopy(aseg_gmcort)
    aseg_cereb = deepcopy(aseg_gmcort)
    # Change the values in aseg (with exterior CSF) to their tissue classes
    for i in tissue_df.Number:
        aseg_gmcort[aseg_gmcort == i] = tissue_df[tissue_df['Number'] == i].GMCortical.values[0]
        aseg_wmcort[aseg_wmcort == i] = tissue_df[tissue_df['Number'] == i].WMCortical.values[0]
        aseg_csf[aseg_csf == i] = tissue_df[tissue_df['Number'] == i].CSF.values[0]
        aseg_gmdeep[aseg_gmdeep == i] = tissue_df[tissue_df['Number'] == i].GMDeep.values[0]
        aseg_bstem[aseg_bstem == i] = tissue_df[tissue_df['Number'] == i].Brainstem.values[0]
        aseg_cereb[aseg_cereb == i] = tissue_df[tissue_df['Number'] == i].Cerebellum.values[0]
    if np.array_equal(np.unique(aseg_gmcort), np.array([0, 1])):
        print('All values in the aseg image have successfully been converted to 0 or 1')
    else:
        print('Oh no! There is a value in one of your aseg images that is not in tissueClasses.csv')
        break
    gmcort_img = nib.Nifti1Image(aseg_gmcort, affine=aseg_img.affine)
    wmcort_img = nib.Nifti1Image(aseg_wmcort, affine=aseg_img.affine)
    csf_img = nib.Nifti1Image(aseg_csf, affine=aseg_img.affine)
    gmdeep_img = nib.Nifti1Image(aseg_gmdeep, affine=aseg_img.affine)
    bstem_img = nib.Nifti1Image(aseg_bstem, affine=aseg_img.affine)
    cereb_img = nib.Nifti1Image(aseg_cereb, affine=aseg_img.affine)
    aseg_filename = os.path.basename(aseg)
    gmcort_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'GMCortical_mask'))
    wmcort_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'WMCortical_mask'))
    csf_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'CSF_mask'))
    gmdeep_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'GMDeep_mask'))
    bstem_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'Brainstem_mask'))
    cereb_img.to_filename('/data/output/'+aseg_filename.replace('desc-aseg_dseg', 'Cerebellum_mask'))

# Sanity check: After adding the external CSF, are the number of non-zero voxels
# the same as in the dilated mask? If so, then none of the original labels were
# changed in the process of adding external CSF (run after line 49)
#aseg_gmcort_binary_old = aseg_gmcort_old
#aseg_gmcort_binary_old[aseg_gmcort_binary_old > 0] = 1
#aseg_gmcort_binary = aseg_gmcort
#aseg_gmcort_binary[aseg_gmcort_binary > 0] = 1
#np.sum(aseg_gmcort_binary_old) #1392893.0
#np.sum(aseg_gmcort_binary) #1721507.0
#np.sum(mask_array_dilated) #1721507.0
#np.sum(mask_array) #1522108.0... so the mask is bigger than the aseg labels

# Export
#aseg_gmcort_binary_old = nib.Nifti1Image(aseg_gmcort_binary_old, affine=aseg_img.affine)
#aseg_gmcort_binary = nib.Nifti1Image(aseg_gmcort_binary, affine=aseg_img.affine)
#mask_array_dilated = nib.Nifti1Image(mask_array_dilated, affine=aseg_img.affine)
#mask_array = nib.Nifti1Image(mask_array, affine=aseg_img.affine)

#aseg_gmcort_binary_old.to_filename('/data/output/aseg_gmcort_binary_old.nii.gz')
#aseg_gmcort_binary.to_filename('/data/output/aseg_gmcort_binary.nii.gz')
#mask_array_dilated.to_filename('/data/output/mask_array_dilated.nii.gz')
#mask_array.to_filename('/data/output/mask_array.nii.gz')



# There are -1's in mask_array_intersection, which means there are voxels in the aseg
# that are not in the brain mask... in first sub for set 5 (99, 108, 89)...
# Trying more dilation to fix this, but weird that it ever happened...
# Dilating fixed problem





#
