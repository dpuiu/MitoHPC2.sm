#
# Simplified version of the generated Snakefile.
# Pipeline logic is unchanged.

from glob import glob
from pathlib import Path

configfile: "config.yaml"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

RDIR = config["RDIR"]
REF = f"{RDIR}/{config['MT']}.fa"
RMT = config['RMT']

FDIR = config['FDIR']
ADIR = config['ADIR']
ODIR = config.get("ODIR", "out")

SAMPLES = [
    Path(f).name.removesuffix("_1.fastq.gz")
    for f in sorted(glob(f"{FDIR}/*_1.fastq.gz"))
]

def resource(rule, name):
    return config["resources"][rule][name]

# ---------------------------------------------------------------------------
# Final targets
# ---------------------------------------------------------------------------

rule all:
    input:
        expand(f"{ODIR}/{{sample}}.count", sample=SAMPLES),

# ---------------------------------------------------------------------------
# Alignment
# ---------------------------------------------------------------------------

rule ALIGN_REFERENCE:
    input:
        r1=f"{FDIR}/{{sample}}_1.fastq.gz",
        r2=f"{FDIR}/{{sample}}_2.fastq.gz",
        ref=REF
    output:
        bam=f"{ADIR}/{{sample}}.bam"
    threads: resource("ALIGN_REFERENCE", "cpus")
    resources:
        mem_mb=resource("ALIGN_REFERENCE", "mem_mb")
    shell:
        """
        bwa mem -v 1 -t {threads} -Y \
          -R '@RG\\tID:{wildcards.sample}\\tSM:{wildcards.sample}\\tPL:ILLUMINA' \
          {input.ref} {input.r1} {input.r2} |
        samtools view -bu |
        samtools sort -m {config[MM]} -@ {threads} -o {output.bam}
        """

rule INDEX_ALIGNMENT:
    input:
        bam=f"{ADIR}/{{sample}}.bam"
    output:
        bai=f"{ADIR}/{{sample}}.bam.bai"
    threads: resource("INDEX_ALIGNMENT", "cpus")
    resources:
        mem_mb=resource("INDEX_ALIGNMENT", "mem_mb")
    shell:
        "samtools index -@ {threads} {input.bam}"

rule COMPUTE_ALIGNMENT_STATS:
    input:
        bam=f"{ADIR}/{{sample}}.bam" ,
        bai=f"{ADIR}/{{sample}}.bam.bai"
    output:
        idx=f"{ODIR}/{{sample}}.idxstats"
    threads: resource("COMPUTE_ALIGNMENT_STATS", "cpus")
    resources:
        mem_mb=resource("COMPUTE_ALIGNMENT_STATS", "mem_mb")
    shell:
        "samtools idxstats {input.bam} > {output.idx}"

rule COMPUTE_MTDNA_COPY_NUMBER:
    input:
        idx=f"{ODIR}/{{sample}}.idxstats"
    output:
        cnt=f"{ODIR}/{{sample}}.count"
    threads: resource("COMPUTE_MTDNA_COPY_NUMBER", "cpus")
    resources:
        mem_mb=resource("COMPUTE_MTDNA_COPY_NUMBER", "mem_mb")
    shell:
        """
        scripts/idxstats2count.pl \
          --sample {wildcards.sample} \
          --chrM {RMT} \
          < {input.idx} | scripts/getCN.pl > {output.cnt}
        """
