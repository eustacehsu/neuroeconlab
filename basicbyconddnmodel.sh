
#!/bin/bash
#requires 1st and 2nd level files for one participant, and runs for other participants. 
#Uses denoised data file. If no denoised file then skips, so must be run separately with 4d file when denoised file is not there.
#At 2nd level, uses whichever analyses are there.
#Program
BasDir="/Users/eustacehsu/Documents/MonterossoLab/matching"
Dir2="$BasDir""/101/101_fMRI"
SamFilA="$BasDir""/101/fslanalysis/basicbyconddnmodel1.feat/design.fsf"
SamFilB="$BasDir""/101/fslanalysis/basicbyconddnmodel2.feat/design.fsf"
SamFilAB="$BasDir""/101/fslanalysis/basicbyconddnmodel12.gfeat/design.fsf"
 
for WorDir in 206 207 209 210 211 212 213 214 215 216 725 734 753 812 814 836 875 884 885 891 892 959 972 983 993 #bad728 
#invalid
do
	CurDir="$BasDir""/""$WorDir""/""fslanalysis"
	nvol1=$(/Applications/fsl/bin/fslnvols $CurDir"/"melodic1.ica"/"denoised_data.nii.gz)
	nvol2=$(/Applications/fsl/bin/fslnvols $CurDir"/"melodic2.ica"/"denoised_data.nii.gz)
	
	
	CurDir="$BasDir""/""$WorDir""/""fslanalysis"
    #mkdir $CurDir #mkdir but won't need this later
	cp $SamFilA $CurDir
	if [ -e ${CurDir}/melodic1.ica/denoised_data.nii.gz ]; then
		nvol=$(/Applications/fsl/bin/fslnvols $CurDir"/"melodic1.ica"/"denoised_data.nii.gz)
		sed -i '' '1,$s/101/'$WorDir'/g' $CurDir"/"design.fsf
		sed -i '' '1,$s/'$nvol'/'$nvol1'/g' $CurDir"/"design.fsf
		echo "Pt: ${WorDir} run 1"
    	feat $CurDir"/"design.fsf
    fi	

    CurDir="$BasDir""/""$WorDir""/""fslanalysis"
	cp $SamFilB $CurDir
	if [ -e ${CurDir}/melodic2.ica/denoised_data.nii.gz ]; then
		nvol=$(/Applications/fsl/bin/fslnvols $CurDir"/"melodic2.ica"/"denoised_data.nii.gz)
		sed -i '' '1,$s/101/'$WorDir'/g' $CurDir"/"design.fsf
		sed -i '' '1,$s/'$nvol'/'$nvol2'/g' $CurDir"/"design.fsf
		echo "Pt: ${WorDir} run 2"
    	feat $CurDir"/"design.fsf
    fi

    CurDir="$BasDir""/""$WorDir""/""fslanalysis"
    cp $SamFilAB $CurDir
    NewFilAB="$BasDir""/""$WorDir""/""fslanalysis""/""design.fsf"
    sed -i '' '1,$s/101/'$WorDir'/g' $CurDir"/"design.fsf
    if [ ! -e ${CurDir}/basicbyconddnmodel1.feat/design.fsf ]; then
    	echo 'set feat_files(1) '${CurDir}"/"basicbycondmodel1.feat'' >> $NewFilAB
    	echo "No Denoised session 1 for ${WorDir}"
    fi
   	if [ ! -e ${CurDir}/basicbyconddnmodel2.feat/design.fsf ]; then
    	echo 'set feat_files(2) '${CurDir}"/"basicbycondmodel2.feat'' >> $NewFilAB
    	echo "No Denoised session 2 for ${WorDir}"
	fi
    feat $NewFilAB
done 
