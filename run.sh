#!/bin/bash

## To input directory bind:
#   - ANTsSST output dir for each subject going into group template (need warp and SST)
#   - fMRIPrep output dir for each subject going into group template (need aseg img)
#   - OASIS atlases directory for joint label fusion

## To output dir bind:
#   - /path/to/project/data/groupTemplates

InDir=/data/input
OutDir=/data/output 

###############################################################################
#######################      0. Parse Cmd Line Args      ######################
###############################################################################
VERSION=0.1.0

usage () {
    cat <<- HELP_MESSAGE
      usage:  $0 [--help] [--version] [--column <SUBJECT COLUMN>]
              --subject <SUBJECT LABEL> --session <SESSION LABEL>
      -h  | --help        Print this message and exit.
      -v  | --version     Print version and exit.
      -p  | --project     Project name for template naming.
      -s  | --seed        Random seed for ANTs registration. 
      -l  | --all-labels  Use non-cortical/whitematter labels. Default: False.

HELP_MESSAGE
}

# Display usage message if no args are given
if [[ $# -eq 0 ]] ; then
  usage
  exit 1
fi

# Parse cmd line options
while (( "$#" )); do
  case "$1" in
    -h | --help)
        usage
        exit 0
      ;;
    -v | --version)
        echo $VERSION
        exit 0
      ;;
    -p | --project)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        projectName=$2
        shift 2
      else
        echo "$0: Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -s | --seed)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        seed=$2
        shift 2
      else
        echo "$0: Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -l | --all-labels)
      useAllLabels=1
      shift
      ;;
    -*|--*=) # unsupported flags
      echo "$0: Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

# Default: if no project name given, use "Group".
if [[ -z "$projectName" ]]; then
  projectName=Group
fi

# Default: set random seed to 1.
if [[ -z "$seed" ]]; then
  seed=1
fi

# Set env vars for ANTs
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ANTS_RANDOM_SEED=$seed 

###############################################################################
##########  1. For each timepoint, create and pad 6 tissue masks.   ###########
###############################################################################

# 1. Generate tissue masks for each of the 6 tissue types.
#### This script takes the sub-*_ses-*_desc-aseg_dseg.nii.gz images from
#### fMRIPrep as input, and uses the label mapping defined in tissueClasses.csv
#### to output 6 tissue masks (GMCortical, WMCortical, CSF, GMDeep, Brainstem, 
#### and Cerebellum) per timepoint.
python /scripts/masks.py

# Old way of generating tissues masks!
# https://github.com/ANTsX/ANTs/blob/master/Scripts/antsCookTemplatePriors.sh 

# Pad the tissue masks so that they're in the same space as the padded T1w images.
masks=`find ${OutDir}/* -name "*mask*.nii.gz"`
for mask in ${masks}; do
  ImageMath 3 ${mask} PadImage ${mask} 25;
done

###############################################################################
############  2. Create group template from the selected SSTs.   ##############
###############################################################################

# Make csv of SSTs to pass to group template construction script.
ssts=`find ${InDir} -name "sub*template0.nii.gz"`
for image in ${ssts}; do echo "${image}" >> ${OutDir}/tmp_subjlist.csv ; done

# Get number of SSTs going into group template.
numSSTs=`echo $ssts | wc -l`

# Specify reference template. 
REFTMP="MNI-1x1x1Head" # TODO: make this an argument to the container

# Pad reference template.
ImageMath 3 ${OutDir}/${REFTMP}_pad.nii.gz PadImage ${InDir}/templates/${REFTMP}.nii.gz 25

# Get the dimensions of the padded reference template.
voxdim=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep "Voxel Spacing" | cut -d "[" -f 2 | cut -d "]" -f 1 | sed -r 's/,//g'`
min=`python /scripts/minMax.py ${voxdim} --min`
imgdim1=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[1\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim2=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[2\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim3=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[3\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
max=`python /scripts/minMax.py ${imgdim1} ${imgdim2} ${imgdim3}`

# Calculate smoothing and shrinkage parameters for template construction.
iterinfo=`/scripts/minc-toolkit-extras/ants_generate_iterations.py --min ${min} --max ${max}`

# Parse output to create flags for antsMultivariateTemplateConstruction2.sh
iterinfo=`echo ${iterinfo} | sed -e 's/--convergence\+/-q/g' | sed -e 's/--shrink-factors\+/-f/g' | sed -e 's/--smoothing-sigmas\+/-s/g'`
iterinfo=`echo ${iterinfo} | sed -e 's/\\\\\+//g' | sed -e 's/\]\+//g' | sed -e 's/\[\+//g'`

# Group template construction using antsMultivariateTemplateConstruction2.sh
antsMultivariateTemplateConstruction2.sh -d 3 -o "${OutDir}/${projectName}Template_" \
  -n 0 -i 5 -c 2 -j ${numSSTs} -g .15 -m CC[2] ${iterinfo} \
  -z ${OutDir}/MNI-1x1x1Head_pad.nii.gz ${OutDir}/tmp_subjlist.csv
#-a 0 -A 2
# February 28, 2021 Syn step might be too aggressive

rm ${OutDir}/tmp_subjlist.csv

###############################################################################
######  3. Create composite warp from session space to group space       ######
######     for each timepoint that went into the GT.                     ######
###############################################################################

Native_to_SST_warps=`find ${InDir} -name "*padscale*Warp.nii.gz" -not -name "*Inverse*"`

for Native_to_SST_warp in ${sesToSSTwarps}; do
  subid=`echo ${Native_to_SST_warp} | cut -d "/" -f 7 | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${Native_to_SST_warp} | cut -d "/" -f 7 | cut -d "_" -f 2 | cut -d "-" -f 2`;
  SST_to_GT_warp=`find ${OutDir}/ -name "${projectName}Template_sub-${subid}_template*Warp.nii.gz" -not -name "*Inverse*"`;
  SST_to_GT_affine=`find ${OutDir}/ -name "${projectName}Template_sub-${subid}_template*Affine.mat" -not -name "*Inverse*"`;
  Native_to_SST_affine=`find ${InDir}/ -name "sub-${subid}_ses-${sesid}_desc-preproc_T1w_padscale*Affine.txt"`; #!!!!!!!
  
  # Combine transforms from T1w space to SST space to group template space into 
  # the composite warp. Note, transform order matters!! List in reverse order.
  # 1. SST-to-GT warp
  # 2. SST-to-GT affine
  # 3. Native-to-SST warp
  # 4. Native-to-SST affine
  antsApplyTransforms \
   -d 3 \
   -e 0 \
   -o [${OutDir}/sub-${subid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz, 1] \
   -r ${OutDir}/${projectName}Template_template0.nii.gz \
   -t ${SST_to_GT_warp} \
   -t ${SST_to_GT_affine} \
   -t ${Native_to_SST_warp} \
   -t ${Native_to_SST_affine};
done

###############################################################################
#### 4. Convert tissue masks from each timepoint to group template space,  ####
####    using the composite warps, then average to generate tissue priors. ####
###############################################################################

masks=`find ${OutDir} -name "*mask.nii.gz"`

for mask in ${masks}; do
  subid=`echo ${mask} | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${mask} | cut -d "_" -f 2 | cut -d "-" -f 2`;
  masktype=`echo ${mask} | cut -d "_" -f 3`;

  # Apply composite warp to take tissue mask from T1w space to GT space.
  antsApplyTransforms -d 3 -e 0 -o ${OutDir}/sub-${subid}_ses-${sesid}_${masktype}_mask_Normalizedto${projectName}Template.nii.gz \
    -i ${mask} -t ${OutDir}/sub-${subid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz \
    -r ${OutDir}/${projectName}Template_template0.nii.gz;
done

# Clean warped masks by converting all values < 0.2 to 0.
python /scripts/cleanWarpedMasks.py

# Create tissue priors by averaging all tissue classification image in GT space.
# (divide by sum of the voxels if they are all non-zero, and do nothing otherwise)
# Script outputs 6 tissue priors total, e.g. 'CSF_NormalizedtoExtraLongTemplate_prior.nii.gz'
python /scripts/scaleMasks.py

###############################################################################
####  5. Run joint label fusion to map DKT labels onto the group template. ####
###############################################################################

# OLD: Extract the group template brain.
#antsRegistrationSyN.sh -d 3 -f ${OutDir}/${projectName}Template_template0.nii.gz \
#  -m ${InDir}/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0.nii.gz \
#  -o ${OutDir}/MICCAITemplate_to_${projectName}Template

# Skull-strip the group template to get brain mask.
antsBrainExtraction.sh -d 3 -a ${OutDir}/${projectName}Template_template0.nii.gz \
  -e ${InDir}/OASIS_PAC/T_template0.nii.gz \
  -m ${InDir}/OASIS_PAC/T_template0_BrainCerebellumProbabilityMask.nii.gz \
  -o ${OutDir}/${projectName}Template_

# Construct call to antsJointLabelFusion.sh
atlas_args=""

# Loop through each atlas dir in OASIS dir
find ${InDir}/OASIS-TRT-20_volumes/OASIS-TRT* -type d | while read atlas_dir; do
  # Get T1w brain
  brain="${atlas_dir}/t1weighted_brain.nii.gz"
  
  # Get corresponding labels if using all labels (cort, wm, non-cort).
  if [[ ${useAllLabels} ]]; then
    labels=${atlas_dir}/labels.DKT31.manual+aseg.nii.gz;
  
  # Get corresponding labels if using only cortical labels. (Default)
  else
    labels=${atlas_dir}/labels.DKT31.manual.nii.gz;
  fi

  # Append current atlas and label to argument string
  atlas_args=${atlas_args}"-g ${brain} -l ${labels} ";
done

# Run JLF to map DKT labels onto group template
antsJointLabelFusion.sh -d 3 -t ${OutDir}/${projectName}Template_template0.nii.gz \
  -o ${OutDir}/${projectName}Template_malf -c 2 -j 8 -k 1 \
  -x ${OutDir}/ExtraLongTemplate_BrainExtractionMask.nii.gz \
  -p ${OutDir}/malfPosteriors%04d.nii.gz ${atlas_args}

###############################################################################
#################  6. Organize output directory and cleanup. ##################
###############################################################################

# Make subdir for joint label fusion output
mkdir ${OutDir}/malf
mv ${OutDir}/malfPost* ${OutDir}/malf
mv ${OutDir}/*malf*.txt ${OutDir}/malf

if [[ ${useAllLabels} ]]; then
  mv ${OutDir}/*_malft1weighted_* ${OutDir}/malf
else
  mv ${OutDir}/*_malfOASIS-* ${OutDir}/malf
fi

# Make subdir for tissue mask output
mkdir ${OutDir}/masks
mv ${OutDir}/*mask.nii.gz ${OutDir}/masks

# Make subdir for tissue priors
mkdir ${OutDir}/priors
mv ${OutDir}/*prior.nii.gz ${OutDir}/priors

# Make subdir for ????????
mkdir ${OutDir}/Normalizedto${projectName}Template
mv ${OutDir}/*Normalizedto${projectName}Template.nii.gz ${OutDir}/Normalizedto${projectName}Template

# Make subdir for single subject templates
mkdir ${OutDir}/SST
mv ${OutDir}/*sub-* ${OutDir}/SST

# Make subdir for jobscripts
mkdir ${OutDir}/jobs
mv ${OutDir}/job*.sh ${OutDir}/jobs
