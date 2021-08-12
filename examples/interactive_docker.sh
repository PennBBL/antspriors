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
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-85392:/data/input/antssst/sub-85392 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-91404:/data/input/antssst/sub-91404 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-93811:/data/input/antssst/sub-93811 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-100079:/data/input/antssst/sub-100079 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-107903:/data/input/antssst/sub-107903 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-108315:/data/input/antssst/sub-108315 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-114990:/data/input/antssst/sub-114990 \
    -v /Users/kzoner/BBL/projects/ANTS/data/singleSubjectTemplates/antssst-0.1.0/sub-116147:/data/input/antssst/sub-116147 \
    -v /Users/kzoner/BBL/projects/ANTS/data/groupTemplates/antspriors-0.1.0:/data/output \
    katjz/antspriors:0.1.0 -i