# ANTsPriors

This image takes in the output from the anatomical stream from fMRIPrep and
the output of ANTsSST to create a group template from the single subject templates
provided, and tissue-class priors using an average of the individual sessions'
Freesurfer segmentations (e.g., sub-SUBLABEL_ses-SESLABEL_desc-aseg_dseg.nii.gz).
It also performs joint label fusion to get the DKT labels defined on the OASIS brains
into the group template space.

As of March 25, 2021, ANTsPriors has only been tested with the output of
fMRIPrep v 20.0.5 and ANTsSST v 0.0.7. If the structure of the output changes
for either of these pipelines in later versions, ANTsPriors may not work.

## Docker
### Setting up
You must [install Docker](https://docs.docker.com/get-docker/) to use the ANTsPriors
Docker image.

After Docker is installed, pull the ANTsPriors image by running the following command:
`docker pull pennbbl/antspriors:0.0.36`.

Typically, Docker is used on local machines and not clusters because it requires
root access. If you want to run the container on a cluster, follow the Singularity
instructions.

### Running ANTsPriors
Here is an example from one of Ellyn's runs:
```
docker run --rm -ti -e projectName="ExtraLong" -e NumSSTs=8 -e atlases="nowhitematter" \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079:/data/input/antssst/sub-100079 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-107903:/data/input/antssst/sub-107903 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-108315:/data/input/antssst/sub-108315 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-114990:/data/input/antssst/sub-114990 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-116147:/data/input/antssst/sub-116147 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-85392:/data/input/antssst/sub-85392 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-91404:/data/input/antssst/sub-91404 \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-93811:/data/input/antssst/sub-93811 \
  -v /Users/butellyn/Documents/ExtraLong/data/groupTemplates/antspriors:/data/output \
  -v /Users/butellyn/Documents/ExtraLong/data/mindboggleVsBrainCOLOR_Atlases:/data/input/mindboggleVsBrainCOLOR_Atlases \
  pennbbl/antspriors:0.0.36
```

- Line 1: Specify environment variables: the name of the project without any spaces
(`projectName`), the number of single subject templates that will go into the group
template (`NumSSTs`), and whether or not you want the hand-labeled images utilized
in joint label fusion to include white matter labels (`atlases`: whitematter/nowhitematter).
Note: From experience, cortical labels are substantially more accurate if the white
matter labels are not included.
- Line 2: Bind a subject's fMRIPrep output directory
(`/Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079`)
to the subject's fMRIPrep directory in the container (`/data/input/fmriprep/sub-100079`).
- Line 3: Bind a subject's ANTsSST output directory
(`/Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079`)
to the subject's ANTsSST directory in the container (`/data/input/antssst/sub-100079`).
Note that the `antssst` directory outside of the container must start with the string
`antssst`, but after that can contain any other characters. Ellyn has it as `antssst5`
because she got good output on her fifth try.
- Line 18: Bind the directory where you want your ANTsPriors output to end up
(`/Users/butellyn/Documents/ExtraLong/data/groupTemplates/antspriors`)
to the output directory in the container (`/data/output`).
- Line 19: Bind the labeled atlases. The pipeline is configured to run using the
label set including white matter labels from
[here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/XCCE9Q),
but the labeled images that work well with only cortical labels are not currently
publicly available.
- Line 20: Specify the Docker image and version. Run `docker images` to see if you
have the correct version pulled.

Substitute your own values for the files/directories to bind.

## Singularity
### Setting up
You must [install Singularity](https://singularity.lbl.gov/docs-installation) to
use the ANTsPriors Singularity image.

After Singularity is installed, pull the ANTsPriors image by running the following command:
`singularity pull docker://pennbbl/antspriors:0.0.36`.

Note that Singularity does not work on Macs, and will almost surely have to be
installed by a system administrator on your institution's computing cluster.

### Running ANTsPriors
Here is an example from one of Ellyn's runs:
```
SINGULARITYENV_projectName=ExtraLong SINGULARITYENV_NumSSTs=8 SINGULARITYENV_atlases=nowhitematter singularity run --writable-tmpfs --cleanenv \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079:/data/input/fmriprep/sub-100079 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079:/data/input/antssst/sub-100079 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-107903:/data/input/fmriprep/sub-107903 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-107903:/data/input/antssst/sub-107903 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-108315:/data/input/fmriprep/sub-108315 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-108315:/data/input/antssst/sub-108315 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-114990:/data/input/fmriprep/sub-114990 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-114990:/data/input/antssst/sub-114990 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-116147:/data/input/fmriprep/sub-116147 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-116147:/data/input/antssst/sub-116147 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-85392:/data/input/fmriprep/sub-85392 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-85392:/data/input/antssst/sub-85392 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-91404:/data/input/fmriprep/sub-91404 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-91404:/data/input/antssst/sub-91404 \
  -B /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-93811:/data/input/fmriprep/sub-93811 \
  -B /project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-93811:/data/input/antssst/sub-93811 \
  -B /project/ExtraLong/data/groupTemplates/antspriors:/data/output \
  -B /project/ExtraLong/data/mindboggleVsBrainCOLOR_Atlases:/data/input/mindboggleVsBrainCOLOR_Atlases \
  /project/ExtraLong/images/antspriors_0.0.36.sif
```

- Line 1: Specify environment variables: the name of the project without any spaces
(`projectName`), the number of single subject templates that will go into the group
template (`NumSSTs`), and whether or not you want the hand-labeled images utilized
in joint label fusion to include white matter labels (`atlases`: whitematter/nowhitematter).
Note: From experience, cortical labels are substantially more accurate if the white
matter labels are not included.
- Line 2: Bind a subject's fMRIPrep output directory
(`/project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100079`)
to the subject's fMRIPrep directory in the container (`/data/input/fmriprep/sub-100079`).
- Line 3: Bind a subject's ANTsSST output directory
(`/project/ExtraLong/data/singleSubjectTemplates/antssst5/sub-100079`)
to the subject's ANTsSST directory in the container (`/data/input/antssst/sub-100079`).
Note that the `antssst` directory outside of the container must start with the string
`antssst`, but after that can contain any other characters. Ellyn has it as `antssst5`
because she got good output on her fifth try.
- Line 18: Bind the directory where you want your ANTsPriors output to end up
(`/project/ExtraLong/data/groupTemplates/antspriors`)
to the output directory in the container (`/data/output`).
- Line 19: Bind the labeled atlases. The pipeline is configured to run using the
label set including white matter labels from
[here](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/XCCE9Q),
but the labeled images that work well with only cortical labels are not currently
publicly available.
- Line 20: Specify the Singularity image file.

Substitute your own values for the files/directories to bind.

## Example Scripts
See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/ANTsLong/submitANTsPriors_v0.0.36.py)
for an example of building a launch script. `/project/ExtraLong/data/groupTemplates/subjsFromN752_set5.csv`
contains the following columns: `bblid` and `seslabel`. `bblid` is the subject labels
for the single subject templates that are to comprise the group template. Note
that you do not need to call this column `bblid`. In fact, if you are not part of
the BBL, it would be more sensible to call it `sublabel`.

## Notes
1. For details on how ANTsPriors was utilized for the ExtraLong project (all
longitudinal T1w data in the BBL), see [this wiki](https://github.com/PennBBL/ExtraLong/wiki).

## Future Directions
1. Set home directory in Dockerfile.
2. Make sure number of ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS is working in Docker
and Singularity.
3. Set the PEXEC flag for `antsMultivariateTemplateConstruction2` based on the
number of SSTs supplied (currently manually assuming 8).
4. Use the `pad` function in c3d to prevent the template from drifting (Phil Cook).
5. Use the [publicly available version of the mindboggle images](https://www.synapse.org/#!Synapse:syn18486916)
that Phil Cook shared via box and configure paths and file names accordingly.
6. Implement joint label fusion using the labeled images with only cortical labels,
and with cortical, white matter and subcortical labels.
7. Currently, the exterior CSF is substantially overcalled to the extent that
parts of the skulls are getting called CSF in the priors. This was done because
even after a dilation of 2, there was one voxel in one of the aseg images that
was not within the mask. This is mysterious, because there shouldn't be any voxels
outside of the original mask in any segmentation. This is an fMRIPrep v 20.0.5 problem.
To avoid this, all voxels outside of the original mask in the aseg image can be
zero'ed out.
