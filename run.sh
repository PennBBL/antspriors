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
ssts=`find ${InDir} -name "*template*"`
for image in ${ssts}; do echo "${image}" >> ${OutDir}/tmp_subjlist.csv ; done
antsMultivariateTemplateConstruction.sh -d 3 -o "${OutDir}/${projectName}Template_" -r 1 -n 0 -m 40x60x30 -i 5 -y 0 -c 2 -j 2 ${OutDir}/tmp_subjlist.csv

rm ${OutDir}/tmp_subjlist.csv

###### 3.) Concatenate the transforms from T1w-space to group template space
t1wToSSTwarps=`find ${InDir} -name "*Warp.nii.gz"`
for warp in ${t1wToSSTwarps}; do
  bblid=`echo ${warp} | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${warp} | cut -d "_" -f 2 | cut -d "-" -f 2`;
  warpSubToGroupTemplate=`find ${OutDir}/ -name "${projectName}Template_sub-${bblid}_template*Warp.nii.gz" -not -name "*Inverse*"`;
  affSubToGroupTemplate=`find ${OutDir}/ -name "${projectName}Template_sub-${bblid}_template*Affine.txt" -not -name "*Inverse*"`;
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
masks=`find ${OutDir} -name "*mask*"`

for mask in ${masks}; do
  bblid=`echo ${mask} | cut -d "_" -f 1 | cut -d "-" -f 2`;
  sesid=`echo ${mask} | cut -d "_" -f 2 | cut -d "-" -f 2`;
  masktype=`echo ${mask} | cut -d "_" -f 3`;
  antsApplyTransforms -d 3 -e 0 -o ${OutDir}/sub-${bblid}_ses-${sesid}_${masktype}_mask_Normalizedto${projectName}Template.nii.gz \
    -i ${mask} -t ${OutDir}/sub-${bblid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz \
    -r ${OutDir}/sub-${bblid}_ses-${sesid}_Normalizedto${projectName}TemplateCompositeWarp.nii.gz;
done

###### 5.) Average all of the tissue classication images in the group template space
###### to create tissue class priors
python /scripts/averageMasks.py

###### 6.) Joint label fusion on the group template

# Find 101 mindboggle t1w images...
#January 7, 2020: TEMPORARILY LIMIT TO OASIS BRAINS OVER QUALITY CONCERNS WITH OTHER IMAGES
mindt1w=`find ${InDir}/dataverse_files/OASIS-TRT-20_volumes/* -name "t1weighted_brain.nii.gz"`

# Find 101 mindboggle label images
#mindlabel=`find ${InDir}/mindboggle/dataverse_files/*volumes/* -name "labels.DKT31.manual+aseg.nii.gz"`

# Construct call to antsJointLabelFusion.sh
atlaslabelcall=""
for mind in ${mindt1w}; do
  # Find corresponding label image
  mindlabel=`dirname ${mind}`
  mindlabel=${mindlabel}/labels.DKT31.manual+aseg.nii.gz
  atlaslabelcall=${atlaslabelcall}"-g ${mindt1w} -l ${mindlabel} "
done

antsJointLabelFusion.sh -d 3 -t ${OutDir}/${projectName}Template_template0.nii.gz \\
      -o ${OutDir}/malf -p ${OutDir}/malfPosteriors%04d.nii.gz ${atlaslabelcall}












#
