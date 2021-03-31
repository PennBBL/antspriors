docker run --rm -ti --entrypoint=/bin/bash -e projectName="ExtraLong" -e NumSSTs=8 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079:/data/input/antssst/sub-100079 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054:/data/input/antssst/sub-113054 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054:/data/input/fmriprep/sub-113054 \
  -v /Users/butellyn/Documents/ExtraLong/data/mindboggle/dataverse_files:/data/input/dataverse_files \
  -v /Users/butellyn/Documents/ExtraLong/data/groupTemplates/antspriors:/data/output \
  pennbbl/antspriors:0.0.36

SINGULARITYENV_projectName=ExtraLong SINGULARITYENV_NumSSTs=8 singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079:/data/input/antssst/sub-100079 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-113054:/data/input/antssst/sub-113054 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-113054:/data/input/fmriprep/sub-113054 \
  -B /project/ExtraLong/data/mindboggle/dataverse_files:/data/input/dataverse_files \
  -B /project/ExtraLong/data/groupTemplates/antspriors:/data/output \
  /project/ExtraLong/images/antspriors_0.0.36.sif
