##written by AJM 10/7/13
#!/bin/bash
#

#iterate through all files
for FILE in *69s ;
do

#prints original file at command line just so you can ensure its progress later
echo "original data"
cat $FILE | awk '{print}'

#count number of lines in each file and divide by two and have it iterate below equal to the number this outputs
length=`cat $FILE | grep -c ^ | awk '{print $1/2}'`

echo "length of needed iterations is $length"

#go through the following commands for every value between 1 and the length of the file divided by two 
for ROW in $(seq $length) ;
do

echo "row being processed is $ROW"

#print out specified file, choose every odd numbered line, based on how many iterations go through and grab that specific line and output original version to a txt file
cat $FILE | awk 'NR%2 == 1 {print}' | awk -v n=$ROW 'FNR==n {print}' > tmp_1.txt 
#print out specified file, list every odd numbered line, grab same row as above, subtract 6 from second column and print to txt file
cat $FILE | awk 'NR%2 == 1 {print}' | awk -v n=$ROW 'FNR==n {print}' | awk '{print $1 - 6, $2 + 6, $3}' > tmp_2.txt
orig1=`cat tmp_1.txt`
new1=`cat tmp_2.txt`

#print out file, find and replace the original string with the new string
cat $FILE | sed -e "s/$orig1/$new1/" > tmp_3.txt
#replace original file with new file, can modify to create a new file if you don't want original overwritten
mv tmp_3.txt $FILE

echo "new data"
cat $FILE | awk '{print}'
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

rm tmp_*

done

done
