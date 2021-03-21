#!/bin/bash
set -ueo pipefail

if [[ $1 == *.fasta ]]
then
# count seqs in fasta file
paste <(basename $1) <(cat $1 | grep -c "^>")

elif [[ $1 == *.fasta.gz ]]
then
# count seqs in gzipped fasta file
paste <(basename $1) <(zcat $1 | grep -c "^>")

elif [[ $1 == *.fastq ]]
then
# count seqs in fastq file
paste <(basename $1) <(cat $1 | sed -n '1~4s/^@/>/p;2~4p' | grep -c "^>")

elif [[ $1 == *.fastq.gz ]]
then
# count seqs in gzipped fastq file
paste <(basename $1) <(zcat $1 | sed -n '1~4s/^@/>/p;2~4p' | grep -c "^>")

else
echo "file extension must be one of: fasta, fastq, fasta.gz, fastq.gz"
fi

