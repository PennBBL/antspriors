#!/bin/bash

# Run docker container interactively
singularity exec --cleanenv --writable-tmpfs --containall \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-85392:/data/input/antssst/sub-85392 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-91404:/data/input/antssst/sub-91404 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-93811:/data/input/antssst/sub-93811 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-100079:/data/input/antssst/sub-100079 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-107903:/data/input/antssst/sub-107903 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-108315:/data/input/antssst/sub-108315 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-114990:/data/input/antssst/sub-114990 \
    -B ~/ants_pipelines/data/singleSubjectTemplates/antssst-0.1.0/sub-116147:/data/input/antssst/sub-116147 \
    -B ~/ants_pipelines/data/groupTemplates/antspriors-0.1.0:/data/output \
    -B ~/ants_pipelines/run_this.sh:/scripts/run_this.sh \
    ~/ants_pipelines/images/antspriors_0.1.0.sif /scripts/run_this.sh