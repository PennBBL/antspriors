# ANTsPriors

This image takes in the output from the anatomical stream from fMRIPrep and
the output of ANTsSST to create a group template from the indicated single subject templates, and tissue-class priors using an average of the individual sessions'
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
`docker pull pennbbl/antspriors:0.1.0`.

Typically, Docker is used on local machines and not clusters because it requires
root access. If you want to run the container on a cluster, follow the Singularity
instructions.

### Running ANTsPriors via Docker Image
Here is an example:
```
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
```

In this call:
1. For each subject going into the group template, bind the subject's fMRIPrep output directory (e.g. `/Users/kzoner/BBL/projects/ANTS/data/fmriprep/sub-85392/`) to the fmriprep input directory in the container (`/data/input/fmriprep/sub-85392`).

2. Bind the overarching ANTsLongitudinal output directory (`/Users/kzoner/BBL/projects/ANTS/data/ANTsLongitudinal/0.1.0/`) to the output directory in the container (`/data/output`).

3. Specify the Docker image and version. Run `docker images` to see if you have the correct version pulled.

4. Pass in command line arguments to the container run script. e.g. `--project <ProjectName>` to use for group template naming conventions. Use the `--help` flag to print a usage message to see other available arugments.

## Singularity
### Setting up
You must [install Singularity](https://singularity.lbl.gov/docs-installation) to
use the ANTsPriors Singularity image.

After Singularity is installed, pull the ANTsPriors image by running the following command:
`singularity pull docker://pennbbl/antspriors:0.0.36`.

Note that Singularity does not work on Macs, and will almost surely have to be
installed by a system administrator on your institution's computing cluster.

### Running ANTsPriors via Singularity Image
Here is an example:
```
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

```

In this call:
1. For each subject going into the group template, bind the subject's fMRIPrep output directory (e.g. `/~/ants_pipelines/data/freesurferCrossSectional/fmriprep/sub-85392`) to the fmriprep input directory in the container (`/data/input/fmriprep/sub-85392`).

2. Bind the overarching ANTsLongitudinal output directory (`~/ants_pipelines/data/ANTsLongitudinal/0.1.0/`) to the output directory in the container (`/data/output`).

3. Specify the Singularity image file.

4. Pass in command line arguments to the container run script. e.g. `--project <ProjectName>` to use for group template naming conventions. Use the `--help` flag to print a usage message to see other available arugments.


<!-- ## Example Scripts
See [this script](https://github.com/PennBBL/ExtraLong/blob/master/scripts/process/ANTsLong/submitANTsPriors_v0.0.36.py)
for an example of building a launch script.  -->

## Notes
1. For details on how ANTsPriors was utilized for the ExtraLong project (all
longitudinal T1w data in the BBL), see [this wiki](https://github.com/PennBBL/ExtraLong/wiki).

## Future Directions

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
