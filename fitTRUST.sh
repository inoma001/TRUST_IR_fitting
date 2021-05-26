#! /bin/bash
# parameter 1 is the DICOM folder for the TRUST data
# parameter 2 is the DICOM folder for the T1_IR data
mkdir "$1NIFTI"
mkdir "$1NIFTI/TRUST"
mkdir "$1NIFTI/IR"
dcm2niix -o $1NIFTI/TRUST/ $1
dcm2niix -o $1NIFTI/IR/ $2
matlab -nodesktop -r "Hb_fitting_script('$1NIFTI/IR');"
matlab -nodesktop -r "TRUST_fitting_script('$1NIFTI');"
