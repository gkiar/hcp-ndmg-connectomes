#
# This script will download HCP data from S3 in the current directory in BIDS format.
# Greg Kiar (May 3, 2018)
#
# First, which DWI session, resting fMRI session, and T1w session to download. Defaults have been set below.
DWI_SES := DWI_dir96_LR
FMRI_SES := rfMRI_REST1_LR
T1_SES := T1w_MPR1

# Next, the collection can be specified. This has most robustly been tested on the HCP 1200 release,
# but it is expected to be able to generalize to older releases as well.
RELEASE := HCP_1200

# Finally, is the relative location of the CSV file that contains your AWS credentials for HCP,
# and your output directory
CSV := HCP_gkiar.csv
OUTDIR := data_hcp1200

# Once the variables above have been set, running this makefile will:
# 	a) add the HCP-AWS credentials to your ~/.aws/credentials file under the profile "hcp"
# 	b) download a list of files in the dataset who have a 3T folder (i.e. neuroimaging data)
# 	c) crawl through these participant directories, and,
# 		c1) if dwi and fmri and t1 images are present
# 		c2) create corresponding local BIDS directories for subject
# 		c3) download relevant image data in BIDS format
#
# The depenencies of this script are:
# 	1) that `awscli` has been installed in Python (i.e. pip install awscli)
# 	2) that you have write access to the directory you're running it in
#
# This script can be run by typing "make".
#

PARTICIPANT_FILE := ${OUTDIR}/${RELEASE}_participants.txt

default: SHELL:=/bin/bash
default:

	# Ensure credentials are configured
	mkdir -p ~/.aws
	touch ~/.aws/credentials
	if ! grep -qF "[hcp]" ~/.aws/credentials; then \
		AKID=$$(tail -1 ${CSV} | cut -d , -f 1); \
		SKID=$$(tail -1 ${CSV} | cut -d , -f 2); \
		echo -e "\n[hcp]\naws_access_key_id = $${AKID}\naws_secret_access_key = $${SKID}" >> ~/.aws/credentials; \
	fi

	# Get participant list and create output directory, if not done already
	mkdir -p ${OUTDIR}
	if [[ ! -e ${PARTICIPANT_FILE} ]]; then \
		touch ${PARTICIPANT_FILE}; \
		PARTICIPANTS=$$(aws --profile hcp s3 ls s3://hcp-openaccess/${RELEASE}/ | awk '/PRE/ {print $$NF}' | cut -d '/' -f 1); \
		for partic in $${PARTICIPANTS}; do \
			echo $${partic} >> ${PARTICIPANT_FILE}; \
		done; \
	fi; \
	echo "Number of Participants:" $$(wc -l ${PARTICIPANT_FILE} | awk '{print $$1}');

	# Get data
	# $$(aws --profile hcp s3 ls s3://hcp-openaccess/${RELEASE}/$${partic}/unprocessed/3T)
	for partic in `cat ${PARTICIPANT_FILE}`; do \
		echo $${item} " "; \
		curdir=${OUTDIR}/sub-$${partic}/ses-1; \
		mkdir -p $${curdir}/anat $${curdir}/func $${curdir}/dwi; \
		\
		aws --profile hcp s3 cp --recursive \
			--exclude="*" \
			--include="*${DWI_SES}*" \
			--exclude="LINKED_DATA/*" \
			--exclude="*SBRef*" \
			s3://hcp-openaccess/HCP_1200/$${partic}/unprocessed/3T/Diffusion/ \
			$${curdir}/dwi/ ; \
		for fil in `ls $${curdir}/dwi/`; do \
			mv $${curdir}/dwi/$${fil} $${curdir}/dwi/sub-$${partic}_ses-1_dwi.`echo $${fil} | cut -d . -f 2-`; \
		done;\
		\
		aws --profile hcp s3 cp --recursive \
			--exclude="*" \
			--include="*${FMRI_SES}.nii.gz" \
			s3://hcp-openaccess/HCP_1200/$${partic}/unprocessed/3T/${FMRI_SES}/ \
			$${curdir}/func/ ; \
		mv $${curdir}/func/$${partic}_3T_${FMRI_SES}.nii.gz $${curdir}/func/sub-$${partic}_ses-1_task-rest_bold.nii.gz; \
		\
		aws --profile hcp s3 cp --recursive \
			--exclude="*" \
			--include="*${T1_SES}.nii.gz" \
			s3://hcp-openaccess/HCP_1200/$${partic}/unprocessed/3T/${T1_SES}/ \
			$${curdir}/anat/ ; \
		mv $${curdir}/anat/$${partic}_3T_${T1_SES}.nii.gz $${curdir}/anat/sub-$${partic}_ses-1_T1w.nii.gz; \
	done; \
	find ${OUTDIR} -name *.bval | xargs sed -i 's/5 /0 /g';
