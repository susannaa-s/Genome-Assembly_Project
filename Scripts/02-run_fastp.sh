#!/bin/bash
#SBATCH --job-name=run_fastp
#SBATCH --partition=pibu_el8
#SBATCH --output=./Out&Err/fastp_%j.out
#SBATCH --error=./Out&Err/fastp_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --mem=32G

# Paths to container and directories
CONTAINER="/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif"
# Resolve symlink to get absolute path
INPUT_DIR=$(readlink -f "$1")    
OUTPUT_DIR="$2"

# Make sure output directory exists, create It if it doesn't
mkdir -p "$OUTPUT_DIR"

# Run Fastp on each fastq.gz file
for file in "$INPUT_DIR"/*.fastq.gz; do
    base=$(basename "$file" .fastq.gz)
    # to keep track of progress
    echo "Running Fastp on $file"
    # mounting input and output directories to /data/input and /data/output in the container
    apptainer exec \
        --bind "$INPUT_DIR":/data/input \
        --bind "$OUTPUT_DIR":/data/output \
        "$CONTAINER" \
        fastp \
        -i /data/input/"$base".fastq.gz \
        -o /data/output/"$base"_clean.fastq.gz \
        -h /data/output/"$base"_fastp.html \
        -j /data/output/"$base"_fastp.json
done
