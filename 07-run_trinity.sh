#!/bin/bash
#SBATCH --job-name=trinity_rnaseq
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --output=trinity_%j.out
#SBATCH --error=trinity_%j.err

# Load Trinity module (if using module system)
module load Trinity/2.15.1-foss-2021a

# Input directory with paired-end reads
INPUT_DIR="/data/users/sschaerer/assembly_annotation_course/RNAseq_Sha"

# Output directory
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/trinity_output"
mkdir -p "$OUTPUT_DIR"

# Run Trinity
Trinity \
  --seqType fq \
  --max_memory 60G \
  --CPU 16 \
  --left "$INPUT_DIR/ERR754081_1.fastq.gz" \
  --right "$INPUT_DIR/ERR754081_2.fastq.gz" \
  --output "$OUTPUT_DIR"
