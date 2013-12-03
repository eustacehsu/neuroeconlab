
#!/bin/bash
#requires 1st and 2nd level for one participant, and then runs for other participants.
#Program
BasDir="/Users/eustacehsu/Documents/MonterossoLab/matching"
Dir2="$BasDir""/993/993_fMRI"
SamFilA="$BasDir""/993/fslanalysis/basicbycondmodel1.feat/design.fsf"
SamFilB="$BasDir""/993/fslanalysis/basicbycondmodel2.feat/design.fsf"
SamFilAB="$BasDir""/993/fslanalysis/basicbycondmodel12.gfeat/design.fsf" #2nd level
 
for WorDir in 215 101 206 207 209 210 211 212 213 214 725 734 753 812 814 836 875 885 891 892 959 972 983   #bad728 #bad884

do
	CurDir="$BasDir""/""$WorDir""/"
	nvol1=$(/Applications/fsl/bin/fslnvols $CurDir"/"$WorDir_fMRI"/"run_1.nii.gz)
	nvol2=$(/Applications/fsl/bin/fslnvols $CurDir"/"$WorDir_fMRI"/"run_2.nii.gz)
	
	
	CurDir="$BasDir""/""$WorDir""/""fslanalysis"
#mkdir $CurDir #mkdir but won't need this later
	cp $SamFilA $CurDir
	nvol=$(/Applications/fsl/bin/fslnvols $Dir2"/"run_1.nii.gz)
	sed -i '' '1,$s/993/'$WorDir'/g' $CurDir"/"design.fsf
	sed -i '' '1,$s/'$nvol'/'$nvol1'/g' $CurDir"/"design.fsf
	feat $CurDir"/"design.fsf

    CurDir="$BasDir""/""$WorDir""/""fslanalysis"
	cp $SamFilB $CurDir
	nvol=$(/Applications/fsl/bin/fslnvols $Dir2"/"run_2.nii.gz)
	sed -i '' '1,$s/993/'$WorDir'/g' $CurDir"/"design.fsf
	sed -i '' '1,$s/'$nvol'/'$nvol2'/g' $CurDir"/"design.fsf
	feat $CurDir"/"design.fsf

    CurDir="$BasDir""/""$WorDir""/""fslanalysis" #2nd level
    cp $SamFilAB $CurDir
    sed -i '' '1,$s/993/'$WorDir'/g' $CurDir"/"design.fsf
	feat $CurDir"/"design.fsf
done 
