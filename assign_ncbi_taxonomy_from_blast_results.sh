#!/bin/sh

#this script takes the output of a blast search (e.g. the text file downloaded after blasting rep_set.fna to the NCBI server) and attaches the top blast hit along with the NCBI taxonomy lineage
#taxonomy lineage assignment is called using the entrez_qiime.py python script, for which you must specify an ABSOLUTE PATH as third input variable - this script can be found at: https://raw.githubusercontent.com/bakerccm/entrez_qiime/master/entrez_qiime.py


#script usage> bash assign_ncbi_taxonomy_from_blast_results.sh blast_results_text_file	ABS/PATH/TO/NCBI/TAXONOMY/FILES/DIRECTORY/ ABS/PATH/TO/DRIECTORY/FOR/entrez_qiime.py


#	If you do not already have a local copy of the NCBI's taxonomy data, you will need to download it. Download links are available from http://www.ncbi.nlm.nih.gov/guide/taxonomy/. The files can also be downloaded directly from the command line, e.g. using Terminal on a Mac:


    # approx 37MB
#    	ftp ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
#    	tar -zxvf taxdump.tar.gz
    
    # approx 900MB
#    	ftp ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
#		gunzip nucl_gb.accession2taxid.gz

#by default, this is used for fungal assignments only, so uncultured and "Fungal sp." are removed prior to taxonomy assignment
#absolute paths are required for entrez_qiime.py so they must be supplied

#########################



grep -v "Uncultured \|Fungal sp.\| Fungal endophyte" $1 > blast_no_uncultured_or_unknown.txt
grep "Query= " blast_no_uncultured_or_unknown.txt | cut -d " " -f2 > query_names

#in case removing "uncultured", and "endophytes" leaves you with no valid blast hits....
grep -A8 -Fwf query_names blast_no_uncultured_or_unknown.txt | grep -v "Sequences producing \|Length=\|Score"| sed '/^$/d' | sed '/^--/d' > sequential_hits
echo -e "These OTUs were not assigned to a top blast hit.  Consider loosening blast parameters (return 100 instead of 10 hits, for example, or do not filter uncultured hits from the result file).\nThese have been removed from the output file: otu_to_ncbi_lineage.tsv" >> ERRORS.txt

awk '/Query=/{getline; print}' sequential_hits | grep "Query= " | cut -d " " -f2 > otus_with_no_hits
awk '/Query=/{getline; print}' sequential_hits | grep "Query= " | cut -d " " -f2 >> ERRORS.txt

grep -A8 -Fwf query_names blast_no_uncultured_or_unknown.txt | grep -v "Sequences producing \|Query= \|Length=\|Score"| sed '/^$/d' | sed '/^--/d' | sed 's/Cf. //' | sed 's/\[//' | sed 's/\]//' > top_blast_hits
cut -d " "  -f1 top_blast_hits > accession_list

#run entrez-qiime.py to get lineage from accession list
python $3/entrez_qiime.py -L $PWD/accession_list -n $2 -r kingdom,phylum,class,order,family,genus,species -a $2nucl_gb.accession2taxid -o $PWD/$1_accession_to_tax_lineage.txt

#add QIIME format labels to each taxonomy level
cat $PWD/$1_accession_to_tax_lineage.txt | sed 's/\t/\tk__/' | sed 's/;/+/'| sed 's/;/+/'| sed 's/;/+/'| sed 's/;/+/'| sed 's/;/+/'| sed 's/;/;s__/'| sed 's/+/;p__/'|sed 's/+/;c__/'| sed 's/+/;o__/'| sed 's/+/;f__/'| sed 's/+/;g__/' > $PWD/$1_accession_to_ncbi_lineage.txt

paste <(grep -v -Fwf otus_with_no_hits query_names) top_blast_hits > otu_to_top_blast

echo -e "OTU_ID\tNCBI_ACCESSION\tNCBI_LINEAGE" > otu_to_ncbi_lineage.tsv
paste <(grep -v -Fwf otus_with_no_hits query_names) <(while read ID; do grep $ID $1_accession_to_ncbi_lineage.txt; done < accession_list) >> otu_to_ncbi_lineage.tsv



#cleanup intermediate files
mv accession_list.log entrez_qiime.log
rm blast_no_uncultured_or_unknown.txt accession_list $1_accession_to_tax_lineage.txt query_names top_blast_hits $1_accession_to_ncbi_lineage.txt otus_with_no_hits sequential_hits


cat ERRORS.txt
echo "Process complete.  Check ERRORS.txt for OTUs that were not assigned a blast hit."
echo "Main output file is otu_to_ncbi_lineage.tsv - A tab-separated file listing OTU_ID, NCBI_ACCESSION for top blast hit, and NCBI_LINEAGE in QIIME-compatible format"

##########################

#output files are:
#					otu_to_ncbi_lineage.tsv		tab-separated file listing OTU_ID, NCBI_ACCESSION for top blast hit, NCBI_LINEAGE in QIIME-compatible format
#					accession_list.log			notes and errors from entrez_qiime.py - This will list accession numbers that did not have associated TaxIDs available.  You will most likely need to fill these in by hand!
#					otu_to_top_blast			tab-separated file listing OTU_ID, NCBI_ACCESSION for top blast hit, NCBI Name/Strain Info, BLAST Alignment Score, BLAST E-Value

##########################
