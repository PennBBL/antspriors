###############################################################################
### masks.py: This script creates gray matter, white matter, and
###           CSF masks from each of the input aseg dseg images.
### Maintainers: Ellyn Butler, Katja Zoner
### November 12, 2020 - March 16, 2021
###############################################################################

import os
import glob
import numpy as np
import pandas as pd
import nibabel as nib
from copy import deepcopy
from scipy import ndimage

# Path to fMRIPrep input directory
inDir= '/data/input'
# Path to output dir
outDir= '/data/output'

# Get list of fmriprep aseg files per subject/session
aseg_files = glob.glob(inDir + '/fmriprep/sub-*/ses-*/anat/*desc-aseg*.nii.gz')

# Error handling! Check that aseg_file were found
if not aseg_files:
    raise Exception("Error: fMRIPrep 'aseg-dseg' files could not be found")

# Read in tissueClasses.csv. This csv maps freesurfer aseg tissue labels
# to the 6 tissue classes used in Atropos segmentation.
# (CorticalGM, CorticalWM, CSF, DeepGM, Brainstem, Cerebellum).
tissue_df = pd.read_csv(inDir + '/tissueClasses.csv')

# Loop over aseg images, and create GM, WM and CSF images
for aseg_file in aseg_files:

    # Check if session has been included in ANTsLongitudinal Pipeline... 
    aseg_filename = os.path.basename(aseg_file)
    sub = aseg_filename.split("_")[0]
    ses = aseg_filename.split("_")[1]
    
    # If session path doesn't exist, this session wasnt included in the SST, so skip processing this aseg
    sesDir = os.path.join(outDir, 'subjects', sub, 'sessions', ses)
    if not os.path.isdir(sesDir):
        print(f"skipping {sub} {ses}!")
        continue

    # Load image data via nibabel
    aseg_img = nib.load(aseg_file)
    aseg = aseg_img.get_fdata()

    # Binarize the aseg image.
    aseg_binary = deepcopy(aseg)
    aseg_binary[aseg_binary > 0] = 1

    # Get the corresponding mask
    fmriprep_dir = os.path.dirname(aseg_file)
    mask_file = [file for file in glob.glob(fmriprep_dir + '/*desc-brain_mask.nii.gz') if 'MNI' not in file][0]
    mask_img = nib.load(mask_file)
    mask = mask_img.get_fdata()

    # Try to get external_csf_mask, if -1's present, increase dilation and retry.
    done = False
    iterations=5
    while not done:

        # Only attempt up to 10 iterations before breaking with error message
        assert iterations <= 10, f"Could not generate External CSF Mask for {sub} {ses}! Values outside [0,1] present even after additional dilation."
        
        # Dilate the mask to include external CSF
        dilated_mask = ndimage.binary_dilation(mask, iterations=iterations).astype(mask.dtype)
        #https://www.programcreek.com/python/example/93929/scipy.ndimage.binary_dilation
        #https://nilearn.github.io/manipulating_images/manipulating_images.html
        
        # Locate external csf --> voxels that are in dilated mask but not in the aseg image.
        external_csf_mask = dilated_mask - aseg_binary
        
        # If external_csf_mask values are only [0,1], we're good to continue. 
        if np.array_equal(np.unique(external_csf_mask), np.array([0, 1])):
            done = True
        
        # If -1's are present, retry dilation with additional iteration.
        else:
            iterations+=1

    # Multiply the external csf binary mask by 24 (CSF value in FreeSurfer aseg), to
    # label voxels in the dilated mask but not in the original mask as CSF (24).
    external_csf_mask = external_csf_mask*24

    # Add the external csf labels to the aseg image.
    # NOTE: Before adding external CSF: np.count_nonzero(aseg==24) --> 959
    # NOTE: After adding external CSF: np.count_nonzero(aseg==24) --> 409059
    aseg = aseg + external_csf_mask

    # For each tissue class, initialze tissue mask using aseg.
    aseg_gmcort = deepcopy(aseg)
    aseg_wmcort = deepcopy(aseg)
    aseg_csf = deepcopy(aseg)
    aseg_gmdeep = deepcopy(aseg)
    aseg_bstem = deepcopy(aseg)
    aseg_cereb = deepcopy(aseg)

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
        raise Exception(f'Error: There is a value in one of your aseg images that is not in tissueClasses.csv. \n Please check {aseg_filename}.')

    gmcort_img = nib.Nifti1Image(aseg_gmcort, affine=aseg_img.affine)
    wmcort_img = nib.Nifti1Image(aseg_wmcort, affine=aseg_img.affine)
    csf_img = nib.Nifti1Image(aseg_csf, affine=aseg_img.affine)
    gmdeep_img = nib.Nifti1Image(aseg_gmdeep, affine=aseg_img.affine)
    bstem_img = nib.Nifti1Image(aseg_bstem, affine=aseg_img.affine)
    cereb_img = nib.Nifti1Image(aseg_cereb, affine=aseg_img.affine)
    
    # Export tissue masks to .nii.gz files
    gmcort_img.to_filename(f'/data/output/masks/{sub}_{ses}_GMCortical-mask')
    wmcort_img.to_filename(f'/data/output/masks/{sub}_{ses}_WMCortical-mask')
    csf_img.to_filename(f'/data/output/masks/{sub}_{ses}_CSF-mask')
    gmdeep_img.to_filename(f'/data/output/masks/{sub}_{ses}_GMDeep-mask')
    bstem_img.to_filename(f'/data/output/masks/{sub}_{ses}_Brainstem-mask')
    cereb_img.to_filename(f'/data/output/masks/{sub}_{ses}_Cerebellum-mask')

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

# There are -1's in mask_array_intersection, which means there are voxels in the aseg
# that are not in the brain mask... in first sub for set 5 (99, 108, 89)...
# Trying more dilation to fix this, but weird that it ever happened...
# Dilating more (4 iterations) fixed problem.





#
