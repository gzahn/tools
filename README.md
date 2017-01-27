# tools
UNIX tools for simple, repetitive bioinformatics tasks

### tally_short_sequences.sh
Finds sequences shorter than specified length within a fasta file and prints the counts for each sample

Usage: bash tally_short_sequences.sh Fasta_Filename Max_Read_Length

### assign_taxonomy_from_blast_results.sh
Takes .txt formatted BLAST results from a fasta file and wraps entrez_qiime.py to assign NCBI taxonomic lineages in QIIME format for the top BLAST hit for each OTU.  
This script assumes you have a local copy of NCBI taxonomy and entrez_qiime.py

Usage: bash assign_taxonomy_from_blast_results.sh blast_results_text_file	ABS/PATH/TO/NCBI/TAXONOMY/FILES/DIRECTORY/ ABS/PATH/TO/DRIECTORY/FOR/entrez_qiime.py
