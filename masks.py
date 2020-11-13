### This script creates gray matter, white matter and CSF masks for each of the
### input aseg dseg images.
###
### Ellyn Butler
### November 12, 2020

import nibabel as nib
import numpy as np
import pandas as pd
import os

# List the available aseg images
files = os.listdir('/data/input/')
asegs = [file for file in files if 'aseg' in file]

# Read in tissue classes
tissue_df = pd.read_csv('/data/input/tissueClasses.csv')

# Loop over asegs, and create GM, WM and CSF images
for aseg in asegs:
    aseg_img = nib.load('/data/input/'+aseg)
    aseg_gm = aseg_img.get_fdata()
    aseg_wm = aseg_gm
    aseg_csf = aseg_gm
    for i in tissue_df.Number:
        aseg_gm[aseg_gm == i] = tissue_df[tissue_df['Number'] == i].GrayMatter
        aseg_wm[aseg_wm == i] = tissue_df[tissue_df['Number'] == i].WhiteMatter
        aseg_csf[aseg_csf == i] = tissue_df[tissue_df['Number'] == i].CSF
    gm_img = nib.Nifti1Image(aseg_gm, affine=aseg_img.affine)
    wm_img = nib.Nifti1Image(aseg_wm, affine=aseg_img.affine)
    csf_img = nib.Nifti1Image(aseg_csf, affine=aseg_img.affine)
    gm_img.to_filename('/data/output/'+aseg.replace('desc-aseg_dseg', 'GM_mask'))
    wm_img.to_filename('/data/output/'+aseg.replace('desc-aseg_dseg', 'WM_mask'))
    csf_img.to_filename('/data/output/'+aseg.replace('desc-aseg_dseg', 'CSF_mask'))
