# simulate reads
#scripts/wgsim.sh sample1
#scripts/wgsim.sh sample2

# download alignments
wget https://github.com/dpuiu/MitoHPC2/raw/refs/heads/main/examples/HPRC/Illumina/bams/HG00438.bam
wget https://github.com/dpuiu/MitoHPC2/raw/refs/heads/main/examples/HPRC/Illumina/bams/HG00438.bam.bai
wget https://github.com/dpuiu/MitoHPC2/raw/refs/heads/main/examples/HPRC/Illumina/bams/HG00621.bam
wget https://github.com/dpuiu/MitoHPC2/raw/refs/heads/main/examples/HPRC/Illumina/bams/HG00621.bam.bai

# convert to reads
samtools sort -n HG00438.bam | samtools fastq  -1 HG00438_1.fastq.gz -2 HG00438_2.fastq.gz
samtools sort -n HG00621.bam | samtools fastq  -1 HG00621_1.fastq.gz -2 HG00621_2.fastq.gz

# set path
PATH=$PATH:./scripts

# dry run
snakemake -n >& snamemake.log

# generate graph
snakemake --dag | dot -Tsvg > dag.svg

# run and save log
snakemake --cores 2 >& snakemake.log
