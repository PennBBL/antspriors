#!/bin/bash

scripts="/Users/kzoner/BBL/projects/ANTS/jobscripts"
jsDir=${scripts}/ANTsPriors-0.1.0
mkdir -p ${jsDir}

data="/Users/kzoner/BBL/projects/ANTS/data"
fmriprep_dir=${data}/fmriprep
antslong_dir=${data}/ANTsLongitudinal

gt_subs_csv=${data}/group_template_subjects.csv
subList=$(cat ${gt_subs_csv} | tail -n +2)

echo "ANTsPriors will build a group template using the following $(echo $subList | wc -w) subjects:"
for sub in $subList;do 
	echo "sub-${sub}"
done

jobscript=${jsDir}/antspriors.sh

nl=$'\n'
fmriprep_bindings=""
for sub in ${subList}; do
	fmriprep_bindings+="-v ${fmriprep_dir}/sub-${sub}:/data/input/fmriprep/sub-${sub} \\${nl}"
done
fmriprep_bindings=${fmriprep_bindings%?}

cat <<- JOBSCRIPT > ${jobscript}
	#!/bin/bash 
	
	docker run -it --rm \\
		${fmriprep_bindings}
		-v ${antslong_dir}:/data/output \\
		katjz/antspriors:0.1.0 -i

JOBSCRIPT

chmod +x ${jobscript}