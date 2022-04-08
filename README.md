# K-mer-scripts for Cyprichromini Tribe Sex Chromosome Analysis 
This code is designed to find sex chromosomes in East African cichlid fish using sex-specific k-mers. K-mers are substrings of genomic or transcriptomic sequencing reads of length (k), typically called and counted by programs such as Jellyfish. Using k-mers rather than methods like GWAS or SNP density allows for analysis of lower quality sequencing data (single individual samples, low sequencing coverage). By calling k-mers from each sex and then comparing them with the sex_specific_kmers.py script, sex-specific files are generated for each sex that exclude k-mers shared between them. 

This project primarily utilizes Linux and Python. 

## Python dependencies: 
argparse \
sys \
tempfile

## Contents: 
sex_specfic_kmers.py \
Get_SexSpef_kmers.sh \
compare_species_kmers.py 

## Suggested usage: 

1. Generate k-mers of desired length (typically adjusted based on your organism’s genome size, generally 18-31bp) using your preferred k-mer counting program
2. Use sex_specific_kmers.py via the Get_SexSpef_Kmers.sh shell script to get sex specific k-mers 
3. Use BLAST or another aligner to assign positional information to k-mers
4. Alternatively, you can compare sex-specific k-mers between species without a reference using compare_species_kmers.py 

**A reference genome is not required until positional information for k-mers is desired.**
