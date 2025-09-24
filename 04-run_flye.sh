#!/bin/bash
#SBATCH --job-name=flye_assembly
#SBATCH --partition=pibu_el8
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=flye_%j.out
#SBATCH --error=flye_%j.err

# Paths
CONTAINER="/containers/apptainer/flye_2.9.5.sif"
INPUT_DIR="/data/users/sschaerer/assembly_annotation_course/Mr-0"
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/flye_output"

# Number of threads
THREADS=16

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Expand FASTQ files and convert to container path
READS=$(ls "$INPUT_DIR"/*.fastq.gz | sed "s|$INPUT_DIR|/data/input|g")

echo "Using reads:"
echo "$READS"

# Run Flye
apptainer exec \
    --bind "$INPUT_DIR":/data/input \
    --bind "$OUTPUT_DIR":/data/output \
    "$CONTAINER" flye \
    --pacbio-raw $READS \
    --out-dir /data/output \
    --threads $THREADS


