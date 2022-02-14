#!/bin/bash

# ANTsPriors: Group Template and Tissue Prior Creation
# Maintainer: Katja Zoner
# Updated:    09/10/2021

VERSION=0.1.0

###############################################################################
##########################      Usage Function      ###########################
###############################################################################
usage() {
    cat <<-HELP_MESSAGE
      usage:  $0 [--help] [--version] 
                 [--jlf ] [--all-labels]
                 [--project <PROJECT NAME>]
                 [--seed <RANDOM SEED>] 
                 [--manual-step <STEP NUM>]
                 SUB1 SUB2 [SUB3 ...]
      
      positional arguments:
        SUB |                   Subject label for subjects going into group template.

      optional arguments:
        -h  | --help            Print this message and exit.
        -j  | --jlf             Run JLF on Group Template. (Default: False)
        -l  | --all-labels      Use non-cortical/whitematter labels for JLF. (Default: False)
        -m  | --manual-step     Manually identify which steps to run. 
                                  1: group template creation, 
                                  2: native-to-GT composite warp creation,
                                  3: tissue prior creation,
                                  4: brain extraction, 
                                  5: joint label fusion
                                Use multiple times to select multiple steps. (e.g. -m 2 -m 3)
        -p  | --project         Project name for group template naming. (Default: "Group")
        -s  | --seed            Random seed for ANTs registration. 
        -v  | --version         Print version and exit.

HELP_MESSAGE
}

###############################################################################
###############      Error Handling and Cleanup Functions      ################
###############################################################################
clean_exit() {
    err=$?
    if [ $err -eq 0 ]; then
        echo "$0: ANTsPriors finished successfully!"
        cleanup
    else
        echo "$0: ${PROGNAME:-}: ${1:-"Exiting with error code $err"}" 1>&2
        cleanup
    fi
    exit $err
}

cleanup() {
    echo -e "\nRunning cleanup ..."
    rm -rf $tmpdir
    echo "Done."
}

control_c() {
    echo -en "\n\n*** User pressed CTRL + C ***\n\n"
}

# Write progress message ($1) to both stdout and stderrs
log_progress() {
    echo -e "\n************************************************************" | tee -a /dev/stderr
    echo -e "***************     $1" | tee -a /dev/stderr
    echo -e "************************************************************\n" | tee -a /dev/stderr
}

###############################################################################
##########    1. Construct group template from the selected SSTs.    ##########
###############################################################################
construct_gt() {

    log_progress "BEGIN: Running group template construction.\n"
    PROGNAME="antsMultivariateTemplateConstruction2"

    # Make csv of SSTs to pass to group template construction script.
    for sub in ${subjects};do
        image=$(find ${OutDir}/subjects/${sub} -name "sub*template0.nii.gz")
        echo "${image}" >>${tmpdir}/sst_list.csv
    done

    # Get number of SSTs going into group template.
    numSSTs=$(cat ${tmpdir}/sst_list.csv | wc -l)

    # Specify reference template.
    REFTMP="MNI-1x1x1Head" # TODO: make this an argument to the container
    REFTMP_PAD="${tmpdir}/${REFTMP}_pad.nii.gz"

    # Pad reference template.
    ImageMath 3 ${REFTMP_PAD} PadImage ${InDir}/${REFTMP}.nii.gz 25

    # Get the dimensions of the padded reference template.
    voxdim=$(PrintHeader ${REFTMP_PAD} | grep "Voxel Spacing" | cut -d "[" -f 2 | cut -d "]" -f 1 | sed -r 's/,//g')
    min=$(python /scripts/minMax.py ${voxdim} --min)
    imgdim1=$(PrintHeader ${REFTMP_PAD} | grep " dim\[1\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g')
    imgdim2=$(PrintHeader ${REFTMP_PAD} | grep " dim\[2\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g')
    imgdim3=$(PrintHeader ${REFTMP_PAD} | grep " dim\[3\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g')
    max=$(python /scripts/minMax.py ${imgdim1} ${imgdim2} ${imgdim3})

    # Calculate smoothing and shrinkage parameters for template construction.
    iterinfo=$(/scripts/minc-toolkit-extras/ants_generate_iterations.py --min ${min} --max ${max})

    # Parse output to create flags for antsMultivariateTemplateConstruction2.sh
    convergence=$(echo ${iterinfo} | cut -d \\ -f 1 | cut -d " " -f 3)
    shrink_factors=$(echo ${iterinfo} | cut -d \\ -f 2 | cut -d " " -f 3)
    smoothing_factors=$(echo ${iterinfo} | cut -d \\ -f 3 | cut -d " " -f 3)

    # iterinfo=$(echo ${iterinfo} | sed -e 's/--convergence\+/-q/g' | sed -e 's/--shrink-factors\+/-f/g' | sed -e 's/--smoothing-sigmas\+/-s/g')
    # iterinfo=$(echo ${iterinfo} | sed -e 's/\\\\\+//g' | sed -e 's/\]\+//g' | sed -e 's/\[\+//g')

    # Group template construction using antsMultivariateTemplateConstruction2.sh
    antsMultivariateTemplateConstruction2.sh \
        -d 3 \
        -i 5 \
        -c 2 \
        -n 0 \
        -g .15 \
        -m CC[2] \
        -q ${convergence} \
        -f ${shrink_factors} \
        -s ${smoothing_factors} \
        -j ${numSSTs} \
        -z ${REFTMP_PAD} \
        -o "${OutDir}/" \
        ${tmpdir}/sst_list.csv

    #############################################################################
    # Group Template construction cleanup / reorganization.
    #############################################################################

    # Rename GT and transform files to include project name.
    mv ${OutDir}/template0.nii.gz ${OutDir}/${projectName}_template0.nii.gz
    mv ${OutDir}/templatewarplog.txt ${OutDir}/${projectName}_templatewarplog.txt
    mv ${OutDir}/template0GenericAffine.mat ${OutDir}/${projectName}_template0GenericAffine.mat
    mv ${OutDir}/template0warp.nii.gz ${OutDir}/${projectName}_template0warp.nii.gz

    # Make subdir for jobscripts
    mkdir -p ${OutDir}/jobs
    mv ${OutDir}/job*.sh ${OutDir}/jobs

    # Save path to group template
    GT=${OutDir}/${projectName}_template0.nii.gz

    # For each sub, rename output files and move into subject-level dir
    for sub in $subjects; do

        # Get subject-level output dir
        SubDir=${OutDir}/subjects/${sub}

        # Rename and move SST-to-GT warps and affine
        files=$(find ${OutDir} -maxdepth 1 -name "${sub}_*")
        for f in $files; do
            name=$(basename $f | sed "s/template[0-9]*/to${projectName}Template_/")
            mv $f ${tmpdir}/${sub}/$name
        done

        # Rename and move SSTs warped to group template
        files=$(find ${OutDir} -maxdepth 1 -name "template0${sub}*")
        for f in $files; do
            name=${sub}_WarpedTo${projectName}Template.nii.gz
            mv $f ${tmpdir}/${sub}/$name
        done

    done

    log_progress "END: Finished group template construction."
}

###############################################################################
############    2. Create Native-to-GT composite warps for         ############
############       each timepoint that went into the GT.           ############
###############################################################################
construct_composite_warps() {
    log_progress "BEGIN: Constructing native-to-group template composite warps. \n"
    PROGNAME="antsApplyTransforms"

    # Get path to group template
    GT="${OutDir}/${projectName}_template0.nii.gz"

    # Get list of Native-to-SST warps for all subjects/sessions
    Native_to_SST_warps=`find ${OutDir}/subjects -name "*toSST_Warp.nii.gz"`
    # Native_to_SST_warps=$(find ${tmpdir} -name "*toSST_Warp.nii.gz")

    # For each timepoint, create composite warp from Native to GT space.
    for Native_to_SST_warp in ${Native_to_SST_warps}; do

        sub=$(basename ${Native_to_SST_warp} | cut -d "_" -f 1)
        ses=$(basename ${Native_to_SST_warp} | cut -d "_" -f 2)

        SubDir=${OutDir}/subjects/${sub}

        # Also get Native-to-SST affine, and SST-to-GT warp/affine
        Native_to_SST_affine=`find ${SubDir} -name "${sub}_${ses}_toSST_Affine.txt"`
        SST_to_GT_warp=$(find ${tmpdir} -name "${sub}_to${projectName}Template_Warp.nii.gz")
        SST_to_GT_affine=$(find ${tmpdir} -name "${sub}_to${projectName}Template_GenericAffine.mat")

        # Name of composite warp being created.
        Native_to_GT_warp="${SubDir}/sessions/${ses}/${sub}_${ses}_to${projectName}Template_CompositeWarp.nii.gz"

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
            -t ${Native_to_SST_affine}
    done

    log_progress "END: Finished constructing Native-to-GT composite warps."
}

###############################################################################
############    3. Create custom tissue priors in GT space.        ############
###############################################################################
make_tissue_priors() {

    log_progress "BEGIN: Creating tissue masks from FreeSurfer segmentation images."
    PROGNAME="masks.py"

    # For each timepoint, generate tissue masks for each of the 6 tissue types.
    #### This script takes the sub-*_ses-*_desc-aseg_dseg.nii.gz images from
    #### fMRIPrep as input, and uses the label mapping defined in tissueClasses.csv
    #### to output 6 tissue masks (GMCortical, WMCortical, CSF, GMDeep, Brainstem,
    #### and Cerebellum) per timepoint.
    mkdir -p ${OutDir}/masks
    python /scripts/createMasks.py

    # Old way of generating tissues masks!
    # https://github.com/ANTsX/ANTs/blob/master/Scripts/antsCookTemplatePriors.sh

    # Pad each tissue mask so that they're in the same space as the padded T1w images.
    masks=$(find ${OutDir}/masks -type f)
    for mask in ${masks}; do
        ImageMath 3 ${mask} PadImage ${mask} 25
    done

    log_progress "END: Finished creating tissue masks."

    ###############################################################################
    log_progress "BEGIN: Transforming tissue masks from native to group template space."
    PROGNAME="antsApplyTransforms"

    # Get path to group template
    GT="${OutDir}/${projectName}_template0.nii.gz"

    # Convert each tissue mask from native T1w to group template space, using
    # the previously generated composite warps.
    for mask in ${masks}; do

        sub=$(basename ${mask} | cut -d _ -f 1)
        ses=$(basename ${mask} | cut -d _ -f 2)
        SesDir="${OutDir}/subjects/${sub}/sessions/${ses}"

        maskType=$(basename ${mask} | cut -d _ -f 3 | cut -d . -f 1)

        # Name of warped mask to be created.
        warped_mask="${OutDir}/masks/${sub}_${ses}_${maskType}_WarpedTo${projectName}Template.nii.gz"

        # Composite warp to transform mask from native to GT space.
        Native_to_GT_warp=$(find ${SesDir} -name "*CompositeWarp.nii.gz")

        # Apply composite warp to take tissue mask from native T1w space to GT space.
        antsApplyTransforms \
            -d 3 \
            -e 0 \
            -i ${mask} \
            -o ${warped_mask} \
            -t ${Native_to_GT_warp} \
            -r ${GT}
    done

    ###############################################################################
    log_progress "BEGIN: Cleaning and averaging tissue masks to create tissue priors."
    PROGNAME="generatePriors.py"

    # Clean warped masks by converting all values < 0.2 to 0.
    python /scripts/cleanWarpedMasks.py

    # Create tissue priors by averaging all tissue classification image in GT space.
    # (divide by sum of the voxels if they are all non-zero, and do nothing otherwise)
    # Script outputs 6 tissue priors total, e.g. 'CSF_NormalizedtoExtraLongTemplate_prior.nii.gz'
    mkdir -p ${OutDir}/priors
    python /scripts/createPriors.py

    log_progress "END: Finished creating tissue priors."
}

###############################################################################
############   4. Run Ants Brain Extraction on the Group Template.  ###########
###############################################################################
run_brain_extraction() {
    log_progress "BEGIN: Running brain extraction on the group template."
    PROGNAME="antsBrainExtraction"

    GT="${OutDir}/${projectName}_template0.nii.gz"
    BrainExtractionTemplate="${InDir}/OASIS_PAC/T_template0.nii.gz"
    BrainExtractionProbMask="${InDir}/OASIS_PAC/T_template0_BrainCerebellumProbabilityMask.nii.gz"

    # Skull-strip the group template to get brain mask.
    antsBrainExtraction.sh -d 3 \
        -a ${GT} \
        -e ${BrainExtractionTemplate} \
        -m ${BrainExtractionProbMask} \
        -o ${OutDir}/${projectName}Template_

    log_progress "END: Finished brain extraction on the group template."
}

###############################################################################
#######   5. (Optional) Run joint label fusion on the group template.   #######
###############################################################################
run_jlf() {
    log_progress "BEGIN: Running joint label fusion."
    PROGNAME="antsJointLabelFusion"

    # Construct atlas arguments for call to antsJointLabelFusion.sh
    # by looping through each atlas dir in OASIS dir to get brain and labels.
    atlas_args=""

    # If using mindboggleVsBrainCOLOR atlases...
    if [[ -d "${InDir}/atlases/mindboggleHeads" ]]; then

        # Loop thru mindboggle brains to build arglist of atlas brains + labels
        while read brain; do
            labels=$(basename ${brain} | sed "s/.nii.gz/_DKT31.nii.gz/")
            labels=${InDir}/atlases/mindboggleLabels/${labels}

            # Append current atlas and label to argument string
            atlas_args=${atlas_args}"-g ${brain} -l ${labels} "
        done <<<$(find ${InDir}/atlases/mindboggleHeads -name "OASIS-TRT*")

    # Else if using OASIS-TRT-20_volumes...
    else

        # Loop thru OASIS atlas dirs to build arglist of atlas brains + labels
        while read atlas_dir; do

            # Get T1w brain
            brain="${atlas_dir}/t1weighted_brain.nii.gz"

            if [[ ${useAllLabels} ]]; then
                # Get corresponding labels if using all labels (cort, wm, non-cort).
                labels=${atlas_dir}/labels.DKT31.manual+aseg.nii.gz
            else
                # Get corresponding labels if using only cortical labels (default).
                labels=${atlas_dir}/labels.DKT31.manual.nii.gz
            fi

            # Append current atlas and label to argument string
            atlas_args=${atlas_args}"-g ${brain} -l ${labels} "
        done <<<$(find ${InDir}/atlases/OASIS-TRT* -type d)

    fi

    # Make malf output directory
    mkdir ${OutDir}/malf

    # Get path to group template
    GT="${OutDir}/${projectName}_template0.nii.gz"

    # Run JLF to map DKT labels onto the group template.
    antsJointLabelFusion.sh \
        -d 3 -c 2 -j 8 -k 1 \
        -t ${GT} \
        -o ${OutDir}/malf/${projectName}Template_malf \
        -x ${OutDir}/malf/${projectName}Template_BrainExtractionMask.nii.gz \
        -p ${OutDir}/malf/malfPosteriors%04d.nii.gz \
        ${atlas_args}

    # Move DKT-labeled GT to main output dir and rename to match other DKT-labeled images.
    GT_labels=${OutDir}/${projectName}Template_DKT.nii.gz
    mv ${OutDir}/malf/${projectName}Template_malfLabels.nii.gz ${GT_labels}

    log_progress "END: Finished running JLF on the group template."
}

###############################################################################
##########################         MAIN: SETUP        #########################
###############################################################################

# Set default cmd line args
projectName=Group
seed=1
runAll=1        # Default to running all if -m option not used.
runGT=""        # -m 1
runCompWarps="" # -m 2
runPriors=""    # -m 3
runBE=""        # -m 4
runJLF=""       # -m 5 or --jlf
useAllLabels=""

# Parse cmd line options
PARAMS=""
while (("$#")); do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    -j | --jlf)
        runJLF=1
        shift
        ;;
    -l | --all-labels)
        useAllLabels=1
        shift
        ;;
    -m | --manual-step)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            step=$2
            if [[ "$step" == "1" ]]; then
                runAll=""
                runGT=1
            elif [[ "$step" == "2" ]]; then
                runAll=""
                runCompWarps=1
            elif [[ "$step" == "3" ]]; then
                runAll=""
                runPriors=1
            elif [[ "$step" == "4" ]]; then
                runAll=""
                runBE=1
            elif [[ "$step" == "5" ]]; then
                runAll=""
                runJLF=1
            else
                echo "Error: $step is not a valid value for the --manual-step flag."
                exit 1
            fi
            shift 2
        else
            echo "$0: Error: Argument for $1 is missing" >&2
            exit 1
        fi
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
    -v | --version)
        echo $VERSION
        exit 0
        ;;
    -* | --*=) # unsupported flags
        echo "$0: Error: Unsupported flag $1" >&2
        exit 1
        ;;
    *) # parse positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
done

# Set positional arguments (subject list) in their proper place
eval set -- "$PARAMS"

# Get list of subjects going into GT:
# 1. Check fmriprep input for subjects dirs first
subjects=$(ls /data/input/fmriprep)

# 2. Check for list of subjects passed in via cmd line.
if [[ ! ${subjects} ]]; then
    subjects="$@"
fi

# 3. Check that at least two subjects were provided.
if [[ $(echo $subjects | wc -w) -lt 2 ]]; then
    echo "Error: Please provide at least two subject labels for group template construction."
    exit 1
fi

# Set env vars for ANTs
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1
export ANTS_RANDOM_SEED=$seed

# Make tmp dir
tmpdir="/data/output/tmp"
mkdir -p ${tmpdir}

# Also make tmp subdirs for each subject
for sub in ${subjects};do
    mkdir -p ${tmpdir}/${sub}
done

# Set up error handling
set -euo pipefail
trap 'clean_exit' EXIT
trap 'control_c' SIGINT

###############################################################################
########################        MAIN: PROCESSING       ########################
###############################################################################
log_progress "ANTsPriors v${VERSION}: STARTING UP"

InDir=/data/input
OutDir=/data/output

# Run group template creation.
if [[ ${runGT} ]] || [[ ${runAll} ]]; then
    construct_gt
fi

# Run native-to-GT composite warp creation.
if [[ ${runCompWarps} ]] || [[ ${runAll} ]]; then
    construct_composite_warps
fi

# Run tissue priors creation.
if [[ ${runPriors} ]] || [[ ${runAll} ]]; then
    make_tissue_priors
fi

# Run brain extraction.
if [[ ${runBE} ]] || [[ ${runAll} ]]; then
    run_brain_extraction
fi

# Optionally, run JLF on the group template.
if [[ ${runJLF} ]]; then
    run_jlf
fi

log_progress "ANTsPriors v${VERSION}: FINISHED SUCCESSFULLY"
