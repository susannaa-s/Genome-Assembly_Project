#!/bin/bash
#SBATCH --job-name=trinity_rnaseq
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --output=./Out&Err/trinity_%j.out
#SBATCH --error=./Out&Err/trinity_%j.err

# Load Trinity module (if using module system)
# The container could not be used in this case, otherwise the preferred method 
module load Trinity/2.15.1-foss-2021a

# Input directory with paired-end reads that have been treated by fastp 
INPUT_DIR="/data/users/sschaerer/assembly_annotation_course/fastp_results/RNAseq_Sha"

# Output directory
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/trinity_output_FastP/"

mkdir -p "$OUTPUT_DIR"

# Run Trinity on the paired-end reads
Trinity \
  --seqType fq \
  --max_memory 60G \
  --CPU 16 \
  --left "$INPUT_DIR/ERR754081_1_clean.fastq.gz" \
  --right "$INPUT_DIR/ERR754081_2_clean.fastq.gz" \
  --output "$OUTPUT_DIR"
