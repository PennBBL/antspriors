### This script cleans the tissue class masks that have been warped to the
### group template space
###
### Ellyn Butler
### February 3, 2021

import os
import glob
import numpy as np
import pandas as pd
import nibabel as nib
from copy import deepcopy

# Path to masks dir
maskDir= "/data/output/masks/"

# Get list of all warped tissue masks
warped_masks = glob.glob(maskDir + "*WarpedTo*Template.nii.gz")

# Clean each mask by converting values <= 0.2 to 0.0
for mask in warped_masks:
    mask_img = nib.load(mask)
    mask_data = mask_img.get_fdata()
    #mask_data[mask_data > .5] = 1.0
    mask_data[mask_data <= .2] = 0.0
    bin_mask_img = nib.Nifti1Image(mask_data, affine=mask_img.affine)
    bin_mask_img.to_filename(mask.replace('-mask_', '-clean_'))
