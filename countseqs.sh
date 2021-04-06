#!/bin/bash

set -euo pipefail

if [[($1 == *.fasta) || ($1 == *.fa) || ($1 == *.fna)]]
then
	cat $1 | grep -c "^>"
elif [[($1 == *.fastq) || ($1 == *.fq)]]
then
	cat $1 | sed -n '1~4s/^@/>/p;2~4p' | grep -c "^>"
elif [[($1 == *.fasta.gz) || ($1 == *.fa.gz) || ($1 == *.fna.gz)]]
then
	zcat $1 | grep -c "^>"
elif [[($1 == *.fastq.gz) || ($1 == *.fq.gz)]]
then
	zcat $1 | sed -n '1~4s/^@/>/p;2~4p' | grep -c "^>"
else
	echo "your file must have one of the following extensions: (fasta, fa, fna), (fastq, fq), (fasta.gz, fa.gz, fna.gz), (fastq.gz, fq.gz)"
fi

