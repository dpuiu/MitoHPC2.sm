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

# run using conda
snakemake -c1 --use-conda
snakemake -c1 --use-conda --conda-frontend conda
#snakemake -c1 --use-conda --conda-frontend mamba 

# install apptainer
#sudo apt update
#sudo apt install -y software-properties-common
#sudo add-apt-repository ppa:apptainer/ppa
#sudo apt update
#sudo apt install -y apptainer

# local sofware
#bwa: 0.7.17		# 0.7.19(newest)
#samtools: 1.19.2 	# 1.24(newest)  # 1.22(singularity)

#testing singularity
singularity pull docker://quay.io/biocontainers/samtools:1.22--h96c455f_0
singularity exec samtools_1.22--h96c455f_0.sif samtools --version

snakemake -c1 --use-singularity
