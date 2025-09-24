#!/bin/bash
#SBATCH --job-name=run_fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=fastqc_%j.out
#SBATCH --error=fastqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --mem=8G

# Paths
FASTQC_CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
INPUT_DIR=$(readlink -f "$1")    # Resolve symlink
OUTPUT_DIR="$2"

# Make sure output directory exists
mkdir -p "$OUTPUT_DIR"

# Run FastQC on each file
for file in "$INPUT_DIR"/*.fastq.gz; do
    echo "Running FastQC on $file"
    apptainer exec \
        --bind "$INPUT_DIR":/data/input \
        --bind "$OUTPUT_DIR":/data/output \
        "$FASTQC_CONTAINER" \
        fastqc -o /data/output /data/input/"$(basename "$file")"
done

