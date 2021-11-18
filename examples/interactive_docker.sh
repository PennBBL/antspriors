#!/bin/bash

# Run docker container interactively
docker run -it --rm --entrypoint=/bin/bash  \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
    -v /Users/kzoner/BBL/projects/ANTS/data/ANTsLongitudinal/0.1.0:/data/output \
    katjz/antspriors:0.1.0 -i 

# Example 1: Run docker container (non-interactive).
docker run -it --rm \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
    -v /Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
    -v /Users/kzoner/BBL/projects/ANTS/data/ANTsLongitudinal/0.1.0:/data/output \
    katjz/antspriors:0.1.0 --project ExtraLong --seed 1

# Example 2: Run docker container (non-interactive).
# Note: 
#       If not running step 3 (tissue prior creation) it is not necessary to bind fmriprep 
#       input dirs for each subject. Instead pass in a list of subject labels to indicate
#       subjects for GT inclusion.
docker run -it --rm \
    -v /Users/kzoner/BBL/projects/ANTS/data/ANTsLongitudinal/0.1.0:/data/output \
    katjz/antspriors:0.1.0 --project ExtraLong --seed 1 -m 1 \
    sub-85392 sub-91404 sub-93811 sub-100079 sub-107903 sub-108315 sub-114990 sub-116147
    