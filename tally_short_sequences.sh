#!/bin/sh


#find sequences in fasta file $1 that have fewer than $2 base-pairs and print the count of such sequences for each sample in which they are found
#useful for locating samples that have unusually high counts of short read sequences
#usage: bash tally_short_sequences.sh FILENAME(combined_seqs.fna) MAX_READ_LENGTH(integer) 
#author: gzahn

grep -v "^>" $1 | awk -v max=$2 'length($0) < max' | sort|uniq > $1_$2_or_fewer_read_length.seqs
grep -B1 -Fwf $1_$2_or_fewer_read_length.seqs $1 | grep "^>" | cut -d "_" -f1 | sed 's/>//' | sort|uniq > $1_$2_or_fewer_read_length_samples.txt
echo "Sample_ID Count_of_short_seqs" >> $1_$2_or_fewer_read_length_sample_counts.txt
grep -B1 -Fwf $1_$2_or_fewer_read_length.seqs $1 | grep "^>" | cut -d "_" -f1 | awk '{count[$1]++} END {for (word in count) print word, count[word]}' | sed 's/^>//' >> $1_$2_or_fewer_read_length_sample_counts.txt

rm $1_$2_or_fewer_read_length_samples.txt
#output file *sample_counts.txt is in format:  SAMPLE_ID	COUNT


echo "Command finished.  Output in file: $1_$2_or_fewer_read_length_sample_counts.txt"
echo "Unique sequences shorter than $2 base-pairs are in file: $1_$2_or_fewer_read_length.seqs"


