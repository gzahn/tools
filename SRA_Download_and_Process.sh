#!/bin/sh

############################
#SRA online search terms:
#ITS1
#
#SRA online filters:
#Platform = Illumina
############################
# This script takes the standard downloads from the SRA read selector (the table and accession list) and uses them to download all the associated fastq files from the Sequence Read Archive. 
# It then filters for read quality (default 95% of bases with at least a 25 phred score) removes empty reads and reverse reads, converts to fasta files and makes a valid QIIME mapping file based on the sample names.
# Next, it constructs one BIG fasta file, ready for OTU picking or other pre-processing steps.


#This script assumes the following: 1.  you have SRATools installed on your machine. Make sure to check the verison and location and adjust line 29
#									2.	You have downloaded a table and list of accession numbers from the SRA read selector website.  Table contains metadata for each accession.
#									3.	You have QIIME and the fastx_toolkit installed and in your $PATH
# usage: bash SRA_Download_and_Process.sh /PATH/TO/SRA_RUN_TABLE.TXT /PATH/TO/SRA_ACCESSION_LIST.TXT /OUTPUT/DIRECTORY/PATH/FOR/READS_AND_MAPPING_FILES


# Determine total disk size of downloads based on metadata table (field 16) (this may not be robust...fix to use column name "Mbytes")
cut -f 16 $1 > file_sizes
paste <(awk '{sum += $1} END {print sum}' file_sizes) <(echo "Mbytes Total... Downloads will start in 10 seconds.")

#pause to sink in, give time to cancel
sleep 10

echo "Downloading fastq files associated with SRA accession numbers..."

# use SRA toolkit fastq-dump to download fastq files for each associated SRA accession (Fwd and Rev runs in separate reads, gzip compression, no technical reads)
cat $2 | xargs ~/sratoolkit.2.8.1-2-ubuntu64/bin/fastq-dump --split-files --bzip2 --skip-technical --readids --dumpbase --outdir $3

echo "Removing reverse reads...screw 'em!"

#deal with reverse reads....probably just dump them, at least until I can incorporate PEAR matching.  Probably not worth it though.
rm *_2.fastq.bz2

echo "Unzipping fastq files..."

#unzip fastqs
bzip2 -d *.bz2

echo "Filtering fastqs to remove low-quality reads..."

#quality filter fastq (min 95% bases with 25 phred score)
for fn in *.fastq; do fastq_quality_filter -i $fn -q 25 -p 95 -o $fn.QC_25-95 -v >> QC-25-95.out; done

echo "Converting fastq to fasta..."

#convert to fasta
for fn in *.QC_25-95; do convert_fastaqual_fastq.py -f $fn -c fastq_to_fastaqual -F; done

echo "Removing empty files..."

#remove empty fasta files
find . -type f -empty -exec rm {} \;

echo "Making list of file names..."

#make list of filenames
ls -1 *.fna > filenames


###make lists of sampleIDs/barcodes/linkerprimers/descriptions


echo "Making mapping file for QIIME..."

#make list of valid (non-empty) samples to build mapping file for QIIME
cut -d "_" -f1 filenames > valid_sampleIDs

#count number of valid samples and assign to variable
count="$(wc -l valid_sampleIDs | cut -d " " -f 1)"

#make unique descriptions using number of valid samples
paste -d "_" valid_sampleIDs <(echo $(yes SRAExp | head -n$count) | tr " " "\n") > valid_descriptions

#make bogus barcodes and primers using number of valid samples
echo $(yes ACGTACGTACGT | head -n$count) | tr " " "\n" > valid_barcodes
echo $(yes TAGATAG | head -n$count) | tr " " "\n" > valid_linkers


#add header labels to mapping file
paste <(echo -e "#SampleID\tBarcodeSequence\tLinkerPrimerSequence\tInputFileName") <(head -1 $1) <(echo "Description") >> mapping_file.tsv



#construct mapping file
paste valid_sampleIDs valid_barcodes valid_linkers <(while read line; do paste <(grep $line filenames) <(grep $line $1) <(grep $line valid_descriptions); done < valid_sampleIDs) >> mapping_file.tsv


echo "Cleaning up intermediate files..."
 
#remove qual scores
rm *.qual

#package up fastqs and fastas
mkdir ./Fastqs
mkdir ./Fastqs/Raw
zip QC_fastqs *.QC_25-95
rm *.QC_25-95
zip Raw_fastqs *.fastq
mv Raw_fastqs.zip ./Fastqs
mv QC_fastqs.zip ./Fastqs
mv *.fastq ./Fastqs/Raw
gzip ./Fastqs/Raw/*.fastq
mv QC-25-95.out ./Fastqs


echo "Creating main fasta file, indexed for QIIME..."

add_qiime_labels.py -i ./ -m ./mapping_file.tsv -c InputFileName

echo "Validating mapping file..."

validate_mapping_file.py -m mapping_file.tsv
sleep 3

rm mapping_file.tsv.html mapping_file.tsv.log overlib.js


mkdir Intermed_files
mv valid* file* Intermed_files
mkdir ./Fastas
mv *.fastq.fna ./Fastas
zip QC_Fastas ./Fastas/*.fna

echo -e "Process complete.\nReady for OTU-Picking.\n\nIf errors were raised in mapping file validation, use the corrected mapping file in QIIME."



