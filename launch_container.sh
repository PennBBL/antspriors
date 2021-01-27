
  #pennbbl/antspriors:<TBD>
# ^ Download this data locally when done processing
# dataverse_files needs to be added to the python construction script

docker run --rm -ti --entrypoint=/bin/bash -e projectName="ExtraLong" \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w0Affine.txt:/data/input/sub-100079_ses-motive1_desc-preproc_T1w0Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w1Affine.txt:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w1Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w0Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w0Affine.txt:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w0Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w1Affine.txt:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w1Affine.txt \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC1/anat/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC2/anat/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054/sub-113054_template0.nii.gz:/data/input/sub-113054_template0.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/mindboggle/dataverse_files:/data/input/dataverse_files \
  -v /Users/butellyn/Documents/chead_home/tmp/xcpEngine/space/MNI/MNI-1x1x1Head.nii.gz:/data/input/MNI-1x1x1Head.nii.gz \
  -v /Users/butellyn/Documents/ExtraLong/data/groupTemplates/versionNine:/data/output \
  pennbbl/antspriors:0.0.11
#  -v /Users/butellyn/Documents/antspriors/tissueClasses.csv:/data/input/tissueClasses.csv \

SINGULARITYENV_projectName=ExtraLong singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-motive1/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-100079_ses-motive1_desc-preproc_T1w0Warp.nii.gz \

  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/ses-PNC2/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-100079_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \

  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-motive1/anat/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-motive1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079/ses-PNC2/anat/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-100079_ses-PNC2_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-100079/sub-100079_template0.nii.gz:/data/input/sub-100079_template0.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-113054/ses-PNC1/sub-113054_ses-PNC1_desc-preproc_T1w0Warp.nii.gz:/data/input/sub-113054_ses-PNC1_desc-preproc_T1w0Warp.nii.gz \

  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-113054/ses-PNC2/sub-113054_ses-PNC2_desc-preproc_T1w1Warp.nii.gz:/data/input/sub-113054_ses-PNC2_desc-preproc_T1w1Warp.nii.gz \

  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC1/anat/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC1_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054/ses-PNC2/anat/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz:/data/input/sub-113054_ses-PNC2_desc-aseg_dseg.nii.gz \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-113054/sub-113054_template0.nii.gz:/data/input/sub-113054_template0.nii.gz \
  -B /project/ExtraLong/data/groupTemplates/versionOne:/data/output \
  /project/ExtraLong/images/antspriors_<TBD>.sif

# ^ write script to generate this using the output of pickSubjsForTemplate_onlytwo.R
