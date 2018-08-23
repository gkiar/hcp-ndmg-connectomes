#!/bin/bash

for subid in `cat HCP_1200_participants.txt`;
do
	# Step 0: setup some variables
	orig_remote='s3://misiclab/hcp1200_minimal/sub-'${subid}'/ses-1/func/sub-'${subid}'_ses-1_task-rest_bold.nii.gz'
	orig_remote_new='s3://misiclab/hcp1200_minimal/sub-'${subid}'/ses-1/func/sub-'${subid}'_ses-1_task-rest_bold_orig.nii.gz'
	orig_local='data/orig.nii.gz'
	new_local='data/new.nii.gz'
	n_trs='600'

	echo ${subid}
	# Step 1: download subject fMRI data
	aws s3 cp ${orig_remote} ${orig_local}

	# Step 2: trim to 600 TRs
	python trim_fmri.py ${orig_local} ${new_local} -l ${n_trs}

	# Step 3: move original to new location
	aws s3 cp ${orig_remote} ${orig_remote_new}

	# Step 4: upload trimmed to original location
	aws s3 cp ${new_local} ${orig_remote}

	# Step 5: delete both files
	rm ${orig_local} ${new_local}

done
