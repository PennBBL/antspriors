docker run --rm -ti --entrypoint=/bin/bash \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/ses-10597/sub-87346_ses-10597_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-87346_ses-10597_desc-preproc_T1w0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/ses-PNC1/sub-87346_ses-PNC1_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-87346_ses-PNC1_desc-preproc_T1w1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-87346/ses-10597/anat/sub-87346_ses-10597_desc-aseg_dseg.nii.gz:/data/input/sub-87346_ses-10597_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-87346/ses-PNC1/anat/sub-87346_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-87346_ses-PNC1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/sub-87346_template0.nii.gz:/data/input/sub-87346_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/tissueClasses.csv:/data/input/tissueClasses.csv \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates:/data/output \
  pennbbl/antspriors
  #pennbbl/antspriors:<TBD>
# ^ Download this data locally when done processing


singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/ses-10597/sub-87346_ses-10597_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-87346_ses-10597_desc-preproc_T1w0Warp.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/ses-PNC1/sub-87346_ses-PNC1_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-87346_ses-PNC1_desc-preproc_T1w1Warp.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-87346/ses-10597/anat/sub-87346_ses-10597_desc-aseg_dseg.nii.gz:/data/input/sub-87346_ses-10597_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-87346/ses-PNC1/anat/sub-87346_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-87346_ses-PNC1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87346/sub-87346_template0.nii.gz:/data/input/sub-87346_template0.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates:/data/output \
  /project/ExtraLong/images/antspriors_<TBD>.sif

# ^ write script to generate this using the output of pickSubjsForTemplate_onlytwo.R
