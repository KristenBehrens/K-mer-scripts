#!/usr/bin python

import sys
import argparse
import tempfile

# This script takes sorted male and female Jellyfish Dump files (in column format, not fasta) and checks the male file against a dictionary of the female k-mers.
# If the male k-mer is in the female hash (of kmers + revcomps) it is disregarded and deleted from the unique female k-mers dictionary
# If the male k-mer is not in the female k-mer dictionary, it is immediately written to the outfile to reduce memory useage. The result should 
# two outfiles: one containing male only k-mers and their counts, and one containing female only k-mers and their counts.

# Due to the use of a dictionary, this script can only be run on a single thread and is not optimized for multi-threading. 
# Allocate memory with this in mind, and assign to a single node (-N on slurm). 

# Set up the argument parser. This allows you to define file names from the command line 
parser = argparse.ArgumentParser(description='''make Table of coverages (both male and female)
    -m male
    -f female
    -M maleoutput
    -F femaleoutput''')

# Define arguments for your parser.
# Like most command line arguments, -m is the short version, --male is the long version, but either can be used.
# required=True means that you will not be able to run this script without providing the input files with the appropriate flags
parser.add_argument('-m', '--male', type=str, required=True,
                    help="Provide a male Jelly_dump file")
parser.add_argument('-f', '--female', type=str, required=True,
                    help="Provide a female Jelly_dump file")
parser.add_argument('-M', '--maleoutput', action='store',
                    required=True, help="Directs the male kmer output to a name of your choice")
parser.add_argument('-F', '--femaleoutput', action='store',
                    required=True, help="Directs the female kmer output to a name of your choice")

#Define the parser as args 
args = parser.parse_args()

# Example useage:
# python sex_specific_kmers.py -m Male.sorted -f Female.sorted -M male_unique -F female_unique

# Initialize dictionary
female_kmers = {} #This is a dictionary - which is more memory intensive, but has an O(n) search complexity, which saves a ton of time on compute for finding duplicate entries.

# read first (female) set of k-mers (and reverse compliments) into dictionary (like perl hash)
with open(str(args.maleoutput), 'w') as maleoutput_file:

    with open(str(args.femaleoutput), 'w') as femaleoutput_file:

        #Read in the entirety of the female k-mers file, and store it in the dictionary.
        with open(str(args.female), 'r') as f_file:
            for line in f_file:
                if not line.strip():
                    continue
                splitline = line.rstrip('\n').rstrip('\t').split()
                # Add Kmer to dictionary.
                female_kmers[splitline[0]] = splitline[1]
        # Read in the male k-mers file, and check for matches in the female file.
        # We're checking as we read the file in to conserve memory, and since dictionary finds are incredibly quick, there should be no noticable difference in performance. 
        with open(str(args.male), 'r') as f_file:
            for line in f_file:
                if not line.strip():
                    continue
                splitline = line.rstrip('\n').rstrip('\t').split()
                #If k-mer has a female match, delete it from the female-unique dictionary 
                if splitline[0] in female_kmers:
                    del female_kmers[splitline[0]]
                # If k-mer does not have a female match, write the k-mer and its count to the outfile
                # Writing to the outfile immediately instead of using a list reduces memory use
                else:
                    maleoutput_file.write(str(splitline[0]) + "" + str(splitline[1]) + "\n")
         # write female specific k-mers to an output file, formatted as a column with one k-mer on each line and the count in the 2nd column
        for kmer2 in female_kmers:
            femaleoutput_file.write(str(kmer2 + " " + female_kmers.get(kmer2)) + "\n")
        
# close all the files you opened                
maleoutput_file.close()
femaleoutput_file.close()
