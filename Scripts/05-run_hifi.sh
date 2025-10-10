#!/bin/bash
#SBATCH --job-name=hifi_assembly
#SBATCH --partition=pibu_el8
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=hifi_%j.out
#SBATCH --error=hifi_%j.err

# Paths to container and directories
CONTAINER="/containers/apptainer/hifiasm_0.25.0.sif"
INPUT_DIR="/data/users/sschaerer/assembly_annotation_course/Mr-0"
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/hifiasm_output"

# Threads equals to cpus per task
THREADS=16

# Make sure output directory exists, create It if it doesn't
mkdir -p "$OUTPUT_DIR"

# Expand FASTQ files and convert to container path
READS=$(ls "$INPUT_DIR"/*.fastq.gz | sed "s|$INPUT_DIR|/data/input|g")

# to keep track of progress
echo "Using reads:"
echo "$READS"

# Run hifiasm on the reads provided
apptainer exec \
    --bind "$INPUT_DIR":/data/input \
    --bind "$OUTPUT_DIR":/data/output \
    "$CONTAINER" hifiasm \
    -o /data/output/hifiasm_assembly \
    -t $THREADS \
    $READS



