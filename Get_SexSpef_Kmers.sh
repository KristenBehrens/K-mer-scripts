#!/bin/bash
#SBATCH -t 5:0:0
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mem=120gb
#SBATCH --share
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

. ~/.profile
module load python

# This script calls and uses sex_specific_kmers.py 
# Assign your Jellyfish Dump output file to a variable
# This simplifies the script - you do not have to replace each file name throughout to reuse

FEMALE=
MALE=

# Sort Dump files to reduce memory use for later steps 
# Dump files must be in column format not fasta

sort -T file_location --parallel=8 -k1,1 -o ${FEMALE}.sorted ${FEMALE}

wait

sort -T file_location --parallel=8 -k1,1 -o ${MALE}.sorted ${MALE}

wait

# Split files into chunks < 4Gb to avoid exceeding memory limit
# This is dependent on your available computational power, you may not need to split
# If you have very large files, divide into more pieces (change the -n, and then add additional mv commands)
# need to do -n l/# instead of -n # because -n # messes the files up and throws a line error 

split -n l/4 ${MALE}.sorted Male

wait

split -n l/4 ${FEMALE}.sorted Female 

wait

#rename the split files 

mv Maleaa ${MALE}.pt1
mv Maleab ${MALE}.pt2
mv Maleac ${MALE}.pt3
mv Malead ${MALE}.pt4

wait

mv Femaleaa ${FEMALE}.pt1
mv Femaleab ${FEMALE}.pt2
mv Femaleac ${FEMALE}.pt3
mv Femalead ${FEMALE}.pt4

wait

# Now that the dump files are in reasonable sized run the script to compare male and female kmers in each subset

python sex_specific_kmers.py -m ${MALE}.pt1 -f ${FEMALE}.pt1 -M ${MALE}_spefpt1 -F ${FEMALE}_spefpt1

wait

python sex_specific_kmers.py -m ${MALE}.pt2 -f ${FEMALE}.pt2 -M ${MALE}_spefpt2 -F ${FEMALE}_spefpt2

wait

python sex_specific_kmers.py -m ${MALE}.pt3 -f ${FEMALE}.pt3 -M ${MALE}_spefpt3 -F ${FEMALE}_spefpt3

wait

python sex_specific_kmers.py -m ${MALE}.pt4 -f ${FEMALE}.pt4 -M ${MALE}_spefpt4 -F ${FEMALE}_spefpt4

wait

# merge together all of the resulting files for males and all the files for females

cat ${MALE}_spefpt1 ${MALE}_spefpt2 ${MALE}_spefpt3 ${MALE}_spefpt4 > ${MALE}_compiled 

wait 

cat ${FEMALE}_spefpt1 ${FEMALE}_spefpt2 ${FEMALE}_spefpt3 ${FEMALE}_spefpt4 > ${FEMALE}_compiled

wait 

# Run the python script a final time on the merged files
# This ensures that any matches that might have been missed because of the splits get captured and removed 

python sex_specific_kmers.py -m ${MALE}_compiled -f ${FEMALE}_compiled -M ${MALE}_FINAL -F ${FEMALE}_FINAL

# Final output file should be a male file and a female file, each with two columns - the sex-unique kmer and its frequency

wait

# clean up all the intermediate files 

rm ${MALE}.pt1
rm ${MALE}.pt2
rm ${MALE}.pt3
rm ${MALE}.pt4
rm ${MALE}.pt5
rm ${MALE}.pt6
rm ${MALE}.pt7
rm ${MALE}.pt8
rm ${MALE}.pt9
rm ${MALE}.pt10

rm ${FEMALE}.pt1
rm ${FEMALE}.pt2
rm ${FEMALE}.pt3
rm ${FEMALE}.pt4
rm ${FEMALE}.pt5
rm ${FEMALE}.pt6
rm ${FEMALE}.pt7
rm ${FEMALE}.pt8
rm ${FEMALE}.pt9
rm ${FEMALE}.pt10


wait

rm ${MALE}_spefpt1
rm ${MALE}_spefpt2
rm ${MALE}_spefpt3
rm ${MALE}_spefpt4
rm ${MALE}_spefpt5
rm ${MALE}_spefpt6
rm ${MALE}_spefpt7
rm ${MALE}_spefpt8
rm ${MALE}_spefpt9
rm ${MALE}_spefpt10
rm ${MALE}_compiled

rm ${FEMALE}_spefpt1
rm ${FEMALE}_spefpt2
rm ${FEMALE}_spefpt3
rm ${FEMALE}_spefpt4
rm ${FEMALE}_spefpt5
rm ${FEMALE}_spefpt6
rm ${FEMALE}_spefpt7
rm ${FEMALE}_spefpt8
rm ${FEMALE}_spefpt9
rm ${FEMALE}_spefpt10
rm ${FEMALE}_compiled

