#!/bin/bash
# ITSx is great, but can take way too long to run on very large fasta files (even with 20 cores). It is useful to split large fastas into many subsets and run ITSx on each before joining the results back together.
# This create a series of slurm scripts to run ITSx on large fasta files that have been split into many parts.  Intended for use on HOC servers that run SLURM job managers.  Nobody wants to write 100 slurm scripts!
# usage: for nums in {001..100}; do bash make_ITsx_Parts_slurm.sh $nums; done 
# that will create 100 slurm scripts, each pointing to one of 100 parts of the original fasta, that was split with fasta-splitter.pl
#not intended as a portable script, file paths will need to be manually edited prior to use.

echo -e '#!/bin/bash' >> $1_ITSx.slurm
echo -e "#SBATCH -J ITSx_$1" >> $1_ITSx.slurm
echo -e '#SBATCH -c 20' >> $1_ITSx.slurm
echo -e '#SBATCH -N 1' >> $1_ITSx.slurm
echo -e '#SBATCH --mem-per-cpu 6400' >> $1_ITSx.slurm
echo -e '#SBATCH -t 1-00:00:00' >> $1_ITSx.slurm
echo -e '#SBATCH -p community.q' >> $1_ITSx.slurm
echo -e '#SBATCH --mail-user USER@EMAIL.DOMAIN' >> $1_ITSx.slurm
echo -e '#SBATCH --mail-type=FAIL' >> $1_ITSx.slurm
echo -e 'source ~/.bash_profile' >> $1_ITSx.slurm
echo -e 'module load bioinfo/HMMER/3.1b2' >> $1_ITSx.slurm
echo -e "perl /home/gzahn/apps/ITSx_1.0.11/ITSx -i /home/gzahn/lus/Projects/UNITE/Seqs/Split_Fastas/combined_seqs_nonchimeras.part-$1.fasta -o /home/gzahn/lus/Projects/UNITE/Seqs/Split_Fastas/ITSx_out_$1 --preserve T -t F --cpu 20 --graphical F --save_regions ITS1" >> $1_ITSx.slurm

