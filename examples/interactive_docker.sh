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

# Run docker container (non-interactive)
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