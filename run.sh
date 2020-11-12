InDir=/data/input
OutDir=/data/output # Bind /project/ExtraLong/data/groupTemplates
# The input directory will contain all of the files, straight up

# Input needed from antssst (double check ANTs documentation):
# 1) Warp from T1w space (output of fMRIPrep) to SST space (to get GM/WM/CSF labels into SST space, and ultimately group template space):
# /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87563/ses-PNC1/sub-87563_ses-PNC1_desc-preproc_T1w1Warp.nii.gz
# 2) SST: /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87563/sub-87563_template0.nii.gz

# Input needed from fmriprep:
# 1) Segmentation from freesurfer, in the same space as sub-100088_ses-CONTE1_desc-preproc_T1w.nii.gz
# /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100088/ses-CONTE1/anat/sub-100088_ses-CONTE1_desc-aseg_dseg.nii.gz
# ^ The type of tissue will need to be determined for each label in this image (i.e., GM, WM, CSF)
# 2) ?

# Create GM, WM and CSF images for each segmentation
asegdseg=`find ${InDir} -name "*desc-aseg_dseg.nii.gz"`
for image in ${asegdseg}; do
  
