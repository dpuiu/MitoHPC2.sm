#!/bin/bash -eux

wgsim chrM.fa -1 150 -2 150 -N 8000  ${1}_1.fastq ${1}_2.fastq > ${1}.log
wgsim chrM.fa -1 150 -2 150 -N 2000  ${1}h_1.fastq ${1}h_2.fastq >> ${1}.log
cat ${1}h_1.fastq >> ${1}_1.fastq
cat ${1}h_2.fastq >> ${1}_2.fastq
rm ${1}h_?.fastq 
gzip ${1}_?.fastq
