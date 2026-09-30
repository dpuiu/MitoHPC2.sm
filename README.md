# MitoHPC2 Snakemake conversion

This version is reconciled against the current `MitoHPC2.sr.nf`, `nextflow.config`, and legacy `scripts/filter.sh`.

## Key reconciliation decisions

- The current Nextflow workflow has `exit 0` immediately after `ALIGN_REFERENCE`; the Snakemake DAG does not reproduce that debugging stop.
- `filter.sh` is used as the behavioral reference for filtering: `-F 0x10C`, NUMT competition, `O.bam`, `OR.bam`, coverage, and split alignments.
- `MINAF=0.01` and `MAXDP=2000` follow `filter.sh`, rather than the null defaults in `nextflow.config`.
- The Snakemake rules use files as the dependency graph instead of Nextflow channels.
- The current checked-in Nextflow workflow is a one-iteration graph. `filter.sh` also contains a second-iteration consensus pipeline. That second iteration should be added as a separate Snakemake layer if `I >= 2` is required; it should not be silently mixed into the one-iteration conversion.

## Run

Dry run:

    snakemake -n

DAG:

    snakemake --dag | dot -Tsvg > dag.svg

Local:

    snakemake --cores 8

SLURM:

    snakemake --slurm --jobs 20 --cores 100

## DAG

FASTQ
  │
  ▼
ALIGN_REFERENCE
  │
  ▼
INDEX_ALIGNMENT
  │
  ├── COMPUTE_ALIGNMENT_STATS
  │          │
  │          ▼
  │   COMPUTE_MTDNA_COPY_NUMBER
  │          │
  │          ▼
  │   CALCULATE_SUBSAMPLING_RATE
  │
  ▼
SUBSAMPLE_AND_TRIM
  │
  ├───────────────┐
  ▼               ▼
REALIGN_MT      REALIGN_NUMTS
  │               │
  └───────┬───────┘
          ▼
    COMPARE_SCORES
          │
          ▼
    SELECT_MT_READS
          │
          ▼
   FILTER_MT_ALIGNMENTS
       │          │
       ▼          ▼
    O.bam       OR.bam
       │
       ├── coverage
       ├── split alignments
       │
       ▼
    SNV caller
       │
       ▼
    normalize
       │
       ▼
    max VCF
       │
       ▼
    filter/annotate
       │
       ├── haplogroup
       ├── haplocheck
       └── consensus FASTA
                    │
                    ▼
                 index
