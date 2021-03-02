# dataverse_files needs to be added to the python script that constructs the call

docker run --rm -ti --entrypoint=/bin/bash -e projectName="ExtraLong" -e NumSSTs=8 -e atlases="nowhitematter" \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Affine.txt:/data/input/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Warp.nii.gz:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Affine.txt:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC1/anat/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC2/anat/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/sub-113054_template0.nii.gz:/data/input/sub-113054_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/mindboggle/dataverse_files:/data/input/dataverse_files \
  -v /Users/butellyn/Documents/ExtraLong/data/mindboggleVsBrainCOLOR_Atlases:/data/input/mindboggleVsBrainCOLOR_Atlases \
  -v /Users/butellyn/Documents/ExtraLong/data/groupTemplates/versionLocalSixteen:/data/output \
  pennbbl/antspriors:0.0.27

SINGULARITYENV_projectName=ExtraLong SINGULARITYENV_NumSSTs=8 singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Affine.txt:/data/input/sub-100079_ses-motive1_desc-preproc_T1w_padscale0Affine.txt \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Warp.nii.gz:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Affine.txt:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w_padscale0Affine.txt \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w_padscale1Affine.txt \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC1/anat/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC2/anat/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/sub-113054_template0.nii.gz:/data/input/sub-113054_template0.nii.gz \
  -B /project/ExtraLong/data/mindboggle/dataverse_files:/data/input/dataverse_files \
  -B /project/ExtraLong/data/groupTemplates/versionEighteen:/data/output \
  /project/ExtraLong/images/antspriors_0.0.25.sif
