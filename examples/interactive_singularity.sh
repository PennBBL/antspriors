#!/bin/bash

# Run singularity container interactively
singularity shell --cleanenv --writable-tmpfs --containall \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
    -B ~/ants_pipelines/data/ANTsLongitudinal/0.1.0/:/data/output \
    ~/ants_pipelines/images/antspriors_0.1.0.sif


# Example 1: Run singularity container (non-interactive).
singularity run --cleanenv --writable-tmpfs --containall \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
    -B ~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
    -B ~/ants_pipelines/data/ANTsLongitudinal/0.1.0/:/data/output \
    ~/ants_pipelines/images/antspriors_0.1.0.sif --project ExtraLong --seed 1

# Example 2: Run singularity container (non-interactive).
# Note: 
#       If not running step 3 (tissue prior creation) it is not necessary to bind fmriprep 
#       input dirs for each subject. Instead pass in a list of subject labels to indicate
#       subjects for GT inclusion.
singularity run --cleanenv --writable-tmpfs --containall \
    -B ~/ants_pipelines/data/ANTsLongitudinal/0.1.0/:/data/output \
    ~/ants_pipelines/images/antspriors_0.1.0.sif --project ExtraLong --seed 1 -m 1 \
    sub-85392 sub-91404 sub-93811 sub-100079 sub-107903 sub-108315 sub-114990 sub-116147