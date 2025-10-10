#!/bin/bash
#SBATCH --job-name=run_fastqc
#SBATCH --partition=pibu_el8
#SBATCH --output=./Out&Err/fastqc_%j.out
#SBATCH --error=./Out&Err/fastqc_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --mem=8G

# Paths to container and directories
FASTQC_CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
# Resolve symlink to get absolute path
INPUT_DIR=$(readlink -f "$1")    
OUTPUT_DIR="$2"

# Make sure output directory exists, create It if it doesn't
mkdir -p "$OUTPUT_DIR"

# Run FastQC on each file by looping through all .fastq.gz files in the input directory
for file in "$INPUT_DIR"/*.fastq.gz; do
    echo "Running FastQC on $file"
    apptainer exec \
        --bind "$INPUT_DIR":/data/input \
        --bind "$OUTPUT_DIR":/data/output \
        "$FASTQC_CONTAINER" \
        fastqc -o /data/output /data/input/"$(basename "$file")"
done

