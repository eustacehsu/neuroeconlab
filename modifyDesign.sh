#Written by AJM 10-11-13
#!/bin/bash
#This script is used to change only certain peices of a design.fsf file

cd /Analyses/Nifti/GroupAnalyses/TemporalRegressions

for i in Sub* ;
do

echo "now running subject $i"

cd /Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i

cp ../design3.fsf .

length=`cat dr_stage1* | grep -c ^`
condition=`echo "$i" | cut -c8-14`

echo "condition is ${condition}, and the length of file is $length"
echo "/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/s_${condition}_e69s"

#if the file you needed doesn't exist then continue to the next item in the loop
if [ ! -f /Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/s_${condition}_e69s ]; then
	echo "File not found!"
	continue
fi

sed -e "s/set fmri(npts) 198/set fmri(npts) $length/" -e "s#set fmri(custom1) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/s_200_1_A_e134sA\"#set fmri(custom1) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/s_${condition}_e134sA\"#" -e "s#set fmri(custom2) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/oldAnalysis/s_200_1_A_e25s\"#set fmri(custom2) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/oldAnalysis/s_${condition}_e25s\"#" -e "s#set fmri(custom3) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/s_200_1_A_e69s\"#set fmri(custom3) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/s_${condition}_e69s\"#" -e "s#set fmri(custom4) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/oldAnalysis/s_200_1_A_e7\"#set fmri(custom4) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/oldAnalysis/s_${condition}_e7\"#" -e "s#set fmri(custom5) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/oldAnalysis/s_200_1_A_e8\"#set fmri(custom5) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/oldAnalysis/s_${condition}_e8\"#" -e "s#set fmri(custom6) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/oldAnalysis/s_200_1_A_e10\"#set fmri(custom6) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/oldAnalysis/s_${condition}_e10\"#" -e "s#set fmri(custom7) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/Sub000_200_1_A/s_200_1_A_e134sB\"#set fmri(custom7) \"/Analyses/Nifti/GroupAnalyses/TemporalRegressions/$i/s_${condition}_e134sB\"#" design3.fsf > tmp.txt

mv tmp.txt design3.fsf

done
