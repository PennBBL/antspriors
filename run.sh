echo "ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=1" >> /root/.bashrc
source /root/.bashrc

InDir=/data/input
OutDir=/data/output # Bind /project/ExtraLong/data/groupTemplates
# The input directory will contain all of the files, straight up

# Input needed from antssst (double check ANTs documentation):
# 1) Warp from T1w space (output of fMRIPrep) to SST space (to get GM/WM/CSF labels into SST space, and ultimately group template space):
# /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87563/ses-PNC1/sub-87563_ses-PNC1_desc-preproc_T1w1Warp.nii.gz
# 2) SST: /project/ExtraLong/data/singleSubjectTemplates/antssst/sub-87563/sub-87563_template0.nii.gz

# Input needed from fmriprep:
# 1) Segmentation from freesurfer, in the same space as sub-100088_ses-CONTE1_desc-preproc_T1w.nii.gz
# /project/ExtraLong/data/freesurferCrossSectional/fmriprep/sub-100088/ses-CONTE1/anat/sub-100088_ses-CONTE1_desc-aseg_dseg.nii.gz
# ^ The type of tissue will need to be determined for each label in this image (i.e., GM, WM, CSF)
# 2) ?

###### 0.) Check if a reference template is given, if not, make it MNI
#if [[ -z "${REFTMP}" ]]; then
#  REFTMP="MNI-1x1x1Head.nii.gz"
#fi

###### 1.) Create tissue classification images for each segmentation
#https://github.com/ANTsX/ANTs/blob/master/Scripts/antsCookTemplatePriors.sh - old way
python /scripts/masks.py

# Pad the tissue classification images such that they are in the same space as
# the padded T1w images
masks=`find ${OutDir}/* -name "*mask*"`
for mask in ${masks}; do
  ImageMath 3 ${mask} PadImage ${mask} 25;
done

###### 2.) Create a group template from the SSTs
ssts=`find ${InDir} -name "sub*template0.nii.gz"`
for image in ${ssts}; do echo "${image}" >> ${OutDir}/tmp_subjlist.csv ; done

REFTMP="MNI-1x1x1Head" #Can make this an argument to the container later

ImageMath 3 ${OutDir}/${REFTMP}_pad.nii.gz PadImage ${InDir}/templates/${REFTMP}.nii.gz 25

# Get the dimensions of the padded MNI template
voxdim=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep "Voxel Spacing" | cut -d "[" -f 2 | cut -d "]" -f 1 | sed -r 's/,//g'`
min=`python /scripts/minMax.py ${voxdim} --min`
imgdim1=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[1\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim2=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[2\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
imgdim3=`PrintHeader ${OutDir}/${REFTMP}_pad.nii.gz | grep " dim\[3\]" | cut -d "=" -f 2 | sed -e 's/\s\+//g'`
max=`python /scripts/minMax.py ${imgdim1} ${imgdim2} ${imgdim3}`

# Generate the flags to specify the smoothing and shrinkage parameters
iterinfo=`/scripts/minc-toolkit-extras/ants_generate_iterations.py --min ${min} --max ${max}`
iterinfo=`echo ${iterinfo} | sed -e 's/--convergence\+/-q/g' | sed -e 's/--shrink-factors\+/-f/g' | sed -e 's/--smoothing-sigmas\+/-s/g'`
iterinfo=`echo ${iterinfo} | sed -e 's/\\\\\+//g' | sed -e 's/\]\+//g' | sed -e 's/\[\+//g'`

antsMultivariateTemplateConstruction2.sh -d 3 -o "${OutDir}/${projectName}Template_" \
  -n 0 -i 5 -c 2 -j 16 -g .15 -m CC[3] -q 120x120x100x40 ${iterinfo} \
  -z ${OutDir}/MNI-1x1x1Head_pad.nii.gz ${OutDir}/tmp_subjlist.csv
# What is the equivalent of -m in antsMultivariateTemplateConstruction2.sh?
# -q: max-iterations (edit later if still bad)

rm ${OutDir}/tmp_subjlist.csv

###### 3.) Concatenate the transforms from T1w-space to group template space
t1wToSSTwarps=`find ${InDir} -name "*Warp.nii.gz"`
for warp in ${t1wToSSTwarps}; do
  bblid=`echo ${warp} | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${warp} | cut -d "_" -f 2 | cut -d "-" -f 2`;
  warpSubToGroupTemplate=`find ${OutDir}/ -name "${projectName}Template_sub-${bblid}_template*Warp.nii.gz" -not -name "*Inverse*"`;
  affSubToGroupTemplate=`find ${OutDir}/ -name "${projectName}Template_sub-${bblid}_template*Affine.mat" -not -name "*Inverse*"`;
  affSubToSST=`find ${InDir}/ -name "sub-${bblid}_ses-${sesid}_desc-preproc_T1w*Affine.txt"`;
  antsApplyTransforms \
   -d 3 \
   -e 0 \
   -o [${OutDir}/sub-${bblid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz, 1] \
   -r ${OutDir}/${projectName}Template_template0.nii.gz \
   -t ${warpSubToGroupTemplate} \
   -t ${affSubToGroupTemplate} \
   -t ${warp} \
   -t ${affSubToSST};
done
# First Transform >>> Output from line 23: warp from SST to group template
# Second Transform >>> Output from line 23: affine for SST to group
# Third Transform >>> Output from antssst: warp from native to SST
# Fourth Transform >>> Output from antssst: affine from native to SST


###### 4.) Warp the tissue classification images in T1w-space to the group template space
masks=`find ${OutDir} -name "*mask.nii.gz"`

for mask in ${masks}; do
  bblid=`echo ${mask} | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${mask} | cut -d "_" -f 2 | cut -d "-" -f 2`;
  masktype=`echo ${mask} | cut -d "_" -f 3`;
  antsApplyTransforms -d 3 -e 0 -o ${OutDir}/sub-${bblid}_ses-${sesid}_${masktype}_mask_Normalizedto${projectName}Template.nii.gz \
    -i ${mask} -t ${OutDir}/sub-${bblid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz \
    -r ${OutDir}/${projectName}Template_template0.nii.gz;
done

###### 5.) Binarize the warped masks in the group template space
python /scripts/binarizeWarpedMasks.py

###### 6.) Average all of the tissue classication images in the group template space
###### to create tissue class priors (divide by sum of the voxels if they are all
###### non-zero, and do nothing otherwise)
python /scripts/averageMasks.py

###### 7.) Joint label fusion on the group template

# Extract the group template brain
#antsRegistrationSyN.sh -d 3 -f ${OutDir}/${projectName}Template_template0.nii.gz \
#  -m ${InDir}/MICCAI2012-Multi-Atlas-Challenge-Data/T_template0.nii.gz \
#  -o ${OutDir}/MICCAITemplate_to_${projectName}Template

antsBrainExtraction.sh -d 3 -a ${OutDir}/${projectName}Template_template0.nii.gz \
  -e ${InDir}/OASIS_PAC/T_template0.nii.gz \
  -m ${InDir}/OASIS_PAC/T_template0_BrainCerebellumProbabilityMask.nii.gz \
  -o ${OutDir}/${projectName}Template_

# Find 101 mindboggle t1w images...
#January 7, 2020: TEMPORARILY LIMIT TO OASIS BRAINS OVER QUALITY CONCERNS WITH OTHER IMAGES
#^ I manually checked all OASIS brains to make sure extraction had gone alright
mindt1w=`find ${InDir}/dataverse_files/OASIS-TRT-20_volumes/* -name "t1weighted_brain.nii.gz"`

# Find 101 mindboggle label images
#mindlabel=`find ${InDir}/mindboggle/dataverse_files/*volumes/* -name "labels.DKT31.manual+aseg.nii.gz"`

# Construct call to antsJointLabelFusion.sh
atlaslabelcall=""
for mind in ${mindt1w}; do
  # Find corresponding label image
  mindlabel=`dirname ${mind}`;
  mindlabel=${mindlabel}/labels.DKT31.manual+aseg.nii.gz;
  atlaslabelcall=${atlaslabelcall}"-g ${mind} -l ${mindlabel} ";
done

antsJointLabelFusion.sh -d 3 -t ${OutDir}/${projectName}Template_template0.nii.gz \
  -o ${OutDir}/${projectName}Tempalte_malf -c 2 -j 16 \
  -x ${OutDir}/ExtraLongTemplate_BrainExtractionMask.nii.gz \
  -p ${OutDir}/malfPosteriors%04d.nii.gz ${atlaslabelcall}

mkdir ${OutDir}/malf
mv ${OutDir}/malft1w* ${OutDir}/malf
mv ${OutDir}/malfPost* ${OutDir}/malf

mkdir ${OutDir}/masks
mv ${OutDir}/*mask.nii.gz ${OutDir}/masks

mkdir ${OutDir}/priors
mv ${OutDir}/*averageMask.nii.gz ${OutDir}/priors

mkdir ${OutDir}/Normalizedto${projectName}Template
mv ${OutDir}/*Normalizedto${projectName}Template.nii.gz ${OutDir}/Normalizedto${projectName}Template

mkdir ${OutDir}/SST
mv ${OutDir}/*sub-* ${OutDir}/SST





#
