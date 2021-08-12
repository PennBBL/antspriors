#!/bin/bash

## To input directory bind:
#   - ANTsSST output dir for each subject going into group template (need warp and SST)
#   - fMRIPrep output dir for each subject going into group template (need aseg img)
#   - OASIS atlases directory for joint label fusion

## To output dir bind:
#   - /path/to/project/data/groupTemplates

InDir=/data/input
OutDir=/data/output 

tmpdir="${OutDir}/tmp"
mkdir -p ${tmpdir}

###############################################################################
#######################      0. Parse Cmd Line Args      ######################
###############################################################################
VERSION=0.1.0

usage () {
    cat <<- HELP_MESSAGE
      usage:  $0 [--help] [--version] [--project <PROJECT NAME>]
              [--seed <RANDOM SEED>] [--all-labels]
      -h  | --help        Print this message and exit.
      -v  | --version     Print version and exit.
      -p  | --project     Project name for template naming.
      -s  | --seed        Random seed for ANTs registration. 
      -j  | --jlf         Run JLF on Group Template. (Default: False)
      -l  | --all-labels  Use non-cortical/whitematter labels for JLF. (Default: False)

HELP_MESSAGE
}

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
    -j | --jlf)
      runJLF=1
      shift
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
mkdir -p ${OutDir}/masks
python /scripts/masks.py

# Old way of generating tissues masks!
# https://github.com/ANTsX/ANTs/blob/master/Scripts/antsCookTemplatePriors.sh 

# Pad the tissue masks so that they're in the same space as the padded T1w images.
masks=`find ${OutDir}/masks -type f`
for mask in ${masks}; do
  ImageMath 3 ${mask} PadImage ${mask} 25;
done

###############################################################################
############  2. Create group template from the selected SSTs.   ##############
###############################################################################

# Make csv of SSTs to pass to group template construction script.
SSTs=`find ${InDir} -name "sub*template0.nii.gz"`
for image in ${SSTs}; do echo "${image}" >> ${tmpdir}/sst_list.csv ; done

# Get number of SSTs going into group template.
numSSTs=`cat ${tmpdir}/sst_list.csv | wc -l`

# Specify reference template. 
REFTMP="MNI-1x1x1Head" # TODO: make this an argument to the container
REFTMP_PAD="${tmpdir}/${REFTMP}_pad.nii.gz"

# Pad reference template.
ImageMath 3 ${REFTMP_PAD} PadImage ${InDir}/${REFTMP}.nii.gz 25

# Get the dimensions of the padded reference template.
voxdim=`PrintHeader ${REFTMP_PAD} | grep "Voxel Spacing" | cut -d "[" -f 2 | cut -d "]" -f 1 | sed -r 's/,//g'`
min=`python /scripts/minMax.py ${voxdim} --min`
imgdim1=`PrintHeader ${REFTMP_PAD} | grep " dim\[1\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim2=`PrintHeader ${REFTMP_PAD} | grep " dim\[2\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim3=`PrintHeader ${REFTMP_PAD} | grep " dim\[3\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
max=`python /scripts/minMax.py ${imgdim1} ${imgdim2} ${imgdim3}`

# Calculate smoothing and shrinkage parameters for template construction.
iterinfo=`/scripts/minc-toolkit-extras/ants_generate_iterations.py --min ${min} --max ${max}`

# Parse output to create flags for antsMultivariateTemplateConstruction2.sh
iterinfo=`echo ${iterinfo} | sed -e 's/--convergence\+/-q/g' | sed -e 's/--shrink-factors\+/-f/g' | sed -e 's/--smoothing-sigmas\+/-s/g'`
iterinfo=`echo ${iterinfo} | sed -e 's/\\\\\+//g' | sed -e 's/\]\+//g' | sed -e 's/\[\+//g'`

# Group template construction using antsMultivariateTemplateConstruction2.sh
antsMultivariateTemplateConstruction2.sh -d 3 \
  -o "${OutDir}/" \
  -n 0 \
  -i 5 \
  -c 2 \
  -j ${numSSTs} \
  -g .15 \
  -m CC[2] \
  ${iterinfo} \
  -z ${REFTMP_PAD} \
  ${tmpdir}/sst_list.csv

###############################################################################
######  3. Group Template construction cleanup / reorganization.         ######                   ######
###############################################################################

# Make subdir for single subject templates
mkdir -p ${OutDir}/SST-to-GT
mv ${OutDir}/*sub-* ${OutDir}/SST-to-GT

# Rename GT and transform files to include project name.
mv ${OutDir}/template0.nii.gz ${OutDir}/${projectName}_template0.nii.gz
mv ${OutDir}/templatewarplog.txt ${OutDir}/${projectName}_templatewarplog.txt
mv ${OutDir}/template0GenericAffine.mat ${OutDir}/${projectName}_template0GenericAffine.mat
mv ${OutDir}/template0warp.nii.gz ${OutDir}/${projectName}_template0warp.nii.gz

# Rename SST-to-GT warps and affines
files=`find ${OutDir}/SST-to-GT -name "sub-*"`
for f in $files; do
  name=`echo $f | sed "s/template[0-9]*/to${projectName}Template_/"`
  mv $f $name
done

# Rename SSTs warped to group template
files=`find ${OutDir}/SST-to-GT -name "template0*"`
for f in $files;do
  sub=`basename $f | cut -d _ -f 1 | sed "s/template0//"`
  mv $f ${sub}_WarpedTo${projectName}Template.nii.gz
done

# Make subdir for jobscripts
mkdir -p ${OutDir}/jobs
mv ${OutDir}/job*.sh ${OutDir}/jobs

GT=${OutDir}/${projectName}_template0.nii.gz

###############################################################################
######  3. Create composite warp from session space to group space       ######
######     for each timepoint that went into the GT.                     ######
###############################################################################

# Make subdir for native-to-GT composite warps
mkdir ${OutDir}/Native-to-GT

Native_to_SST_warps=`find ${InDir} -name "*toSST_Warp.nii.gz" -not -name "*Inverse*"`

# For each timepoint, create composite warp from Native to GT space.
for Native_to_SST_warp in ${Native_to_SST_warps}; do

  sub=`basename ${Native_to_SST_warp} | cut -d "_" -f 1`
  ses=`basename ${Native_to_SST_warp} | cut -d "_" -f 2`

  # TODO: Fix naming convention for antssst.
  Native_to_SST_affine=`find ${InDir} -name "${sub}_${ses}_toSST_Affine.txt"`
  SST_to_GT_warp=`find ${OutDir} -name "${sub}_to${projectName}Template_Warp.nii.gz" -not -name "*Inverse*"`;
  SST_to_GT_affine=`find ${OutDir} -name "${sub}_to${projectName}Template_GenericAffine.mat"`;

  # Name of composite warp being created.
  Native_to_GT_warp="${OutDir}/Native-to-GT/${sub}_${ses}_to${projectName}Template_CompositeWarp.nii.gz"
  
  # Combine transforms from T1w space to SST space to group template space into 
  # the composite warp. Note, transform order matters!! List in reverse order.
  # 1. SST-to-GT warp
  # 2. SST-to-GT affine
  # 3. Native-to-SST warp
  # 4. Native-to-SST affine
  antsApplyTransforms \
   -d 3 \
   -e 0 \
   -o [${Native_to_GT_warp}, 1] \
   -r ${GT} \
   -t ${SST_to_GT_warp} \
   -t ${SST_to_GT_affine} \
   -t ${Native_to_SST_warp} \
   -t ${Native_to_SST_affine};
done

###############################################################################
#### 4. Convert tissue masks from each timepoint to group template space,  ####
####    using the composite warps, then average to generate tissue priors. ####
###############################################################################

#masks=`find ${OutDir} -name "*mask.nii.gz"`

for mask in ${masks}; do

  sub=`basename ${mask} | cut -d _ -f 1`
  ses=`basename ${mask} | cut -d _ -f 2`
  maskType=`basename ${mask} | cut -d _ -f 3 | cut -d . -f 1`

  # Name of warped mask to be created.
  warped_mask="${OutDir}/masks/${sub}_${ses}_${maskType}_WarpedTo${projectName}Template.nii.gz"

  # Composite warp to transform mask from native to GT space.
  Native_to_GT_warp="${OutDir}/Native-to-GT/${sub}_${ses}_to${projectName}Template_CompositeWarp.nii.gz"

  # Apply composite warp to take tissue mask from native T1w space to GT space.
  antsApplyTransforms -d 3 -e 0 \
    -i ${mask} \
    -o ${warped_mask} \
    -t ${Native_to_GT_warp} \
    -r ${GT};
done

# Clean warped masks by converting all values < 0.2 to 0.
python /scripts/cleanWarpedMasks.py

# Create tissue priors by averaging all tissue classification image in GT space.
# (divide by sum of the voxels if they are all non-zero, and do nothing otherwise)
# Script outputs 6 tissue priors total, e.g. 'CSF_NormalizedtoExtraLongTemplate_prior.nii.gz'
mkdir -p ${OutDir}/priors
python /scripts/scaleMasks.py

###############################################################################
####  5. Run joint label fusion to map DKT labels onto the group template. ####
###############################################################################

BrainExtractionTemplate="${InDir}/OASIS_PAC/T_template0.nii.gz"
BrainExtractionProbMask="${InDir}/OASIS_PAC/T_template0_BrainCerebellumProbabilityMask.nii.gz"

# Skull-strip the group template to get brain mask.
antsBrainExtraction.sh -d 3 \
  -a ${GT} \
  -e ${BrainExtractionTemplate} \
  -m ${BrainExtractionProbMask} \
  -o ${OutDir}/${projectName}Template_

# Optionally, run JLF on the SST.
if [[ ${runJLF} ]]; then

  # Construct atlas arguments for call to antsJointLabelFusion.sh
  # by looping through each atlas dir in OASIS dir to get brain and labels.
  atlas_args=""

  # If using mindboggleVsBrainCOLOR atlases...
  if [[ -d "${InDir}/atlases/mindboggleHeads" ]]; then

    # Loop thru mindboggle brains to build arglist of atlas brains + labels
    while read brain; do
      labels=`basename ${brain} | sed "s/.nii.gz/_DKT31.nii.gz/"`
      labels=${InDir}/atlases/mindboggleLabels/${labels}

      # Append current atlas and label to argument string
      atlas_args=${atlas_args}"-g ${brain} -l ${labels} "
    done <<< $(find ${InDir}/atlases/mindboggleHeads -name "OASIS-TRT*")

  # Else if using OASIS-TRT-20_volumes...
  else

    # Loop thru OASIS atlas dirs to build arglist of atlas brains + labels
    while read atlas_dir; do

      # Get T1w brain
      brain="${atlas_dir}/t1weighted_brain.nii.gz"
      
      if [[ ${useAllLabels} ]]; then
        # Get corresponding labels if using all labels (cort, wm, non-cort).
        labels=${atlas_dir}/labels.DKT31.manual+aseg.nii.gz;
      else
        # Get corresponding labels if using only cortical labels (default).
        labels=${atlas_dir}/labels.DKT31.manual.nii.gz;
      fi

      # Append current atlas and label to argument string
      atlas_args=${atlas_args}"-g ${brain} -l ${labels} ";
    done <<< $(find ${InDir}/atlases/OASIS-TRT* -type d)

  fi

  # Make malk output directory
  mkdir ${OutDir}/malf

  # Run JLF to map DKT labels onto the group template.
  antsJointLabelFusion.sh \
    -d 3 -c 2 -j 8 -k 1 \
    -t ${GT} \
    -o ${OutDir}/malf/${projectName}Template_malf \
    -x ${OutDir}/malf/${projectName}Template_BrainExtractionMask.nii.gz \
    -p ${OutDir}/malf/malfPosteriors%04d.nii.gz \
    ${atlas_args}

fi

# Move DKT-labeled SST to main output dir and rename to match DKT-labeled T1w image
mv ${OutDir}/malf/${projectName}Template_malf

# Move DKT-labeled SST to main output dir and rename to match other DKT-labeled images.
GT_labels=${OutDir}/${projectName}Template_DKT.nii.gz
mv ${OutDir}/malf/${projectName}Template_malfLabels.nii.gz ${SST_labels}

###############################################################################
#################  6. Organize output directory and cleanup. ##################
###############################################################################

# # Make subdir for joint label fusion output
# mkdir ${OutDir}/malf
# mv ${OutDir}/malfPost* ${OutDir}/malf
# mv ${OutDir}/*malf*.txt ${OutDir}/malf

# if [[ ${useAllLabels} ]]; then
#   mv ${OutDir}/*_malft1weighted_* ${OutDir}/malf
# else
#   mv ${OutDir}/*_malfOASIS-* ${OutDir}/malf
# fi

rm -rf ${tmpdir}
