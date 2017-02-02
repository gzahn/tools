# tools
UNIX tools for simple, repetitive bioinformatics tasks

### tally_short_sequences.sh
Finds sequences shorter than specified length within a fasta file and prints the counts for each sample

Usage: bash tally_short_sequences.sh Fasta_Filename Max_Read_Length

### assign_taxonomy_from_blast_results.sh
Takes .txt formatted BLAST results from a fasta file and wraps entrez_qiime.py to assign NCBI taxonomic lineages in QIIME format for the top BLAST hit for each OTU.  
This script assumes you have a local copy of NCBI taxonomy and entrez_qiime.py

Usage: bash assign_taxonomy_from_blast_results.sh blast_results_text_file	ABS/PATH/TO/NCBI/TAXONOMY/FILES/DIRECTORY/ ABS/PATH/TO/DRIECTORY/FOR/entrez_qiime.py

### make_qiime_database_from_fasta.sh
Takes fasta file from NCBI search and creates a QIIME-compatible taxonomy database along with a sequence database that can be used to assign OTUs and taxonomy within QIIME.  This allows simple construction of custom databases based on edirect NCBI search results.
This script assumes you have a local copy of NCBI taxonomy and entrez_qiime.py

Usage: bash make_qiime_database_from_fasta.sh /ABS/PATH/TO/INPUT_FASTA_FILE /ABS/PATH/TO/DIRECTORY/FOR/entrez_qiime.py /ABS/PATH/TO/NCBI/TAXONOMY/DIRECTORY/ 	/ABS/PATH/TO/OUTPUT/DIRECTORY/

### SRA_Download_and_Process.sh
Takes downloaded accession list and table from the Sequence Read Archive Read Selector Tool and automatically downloads the associated fastq files from those accessions.  It then removes low-quality reads, and generates a QIIME compatible concatenated fasta and valid mapping file, ready for OTU-Picking. This allows you to go straight from selecting projects of interest on SRA to picking OTUs in QIIME with any uploaded metadata.
This script assumes local copies of QIIME, the fastx_toolkit, and sratools.
