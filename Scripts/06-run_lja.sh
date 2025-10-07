#!/bin/bash
#SBATCH --job-name=lja_assembly
#SBATCH --partition=pibu_el8
#SBATCH --time=2-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=lja_%j.out
#SBATCH --error=lja_%j.err

# Paths
CONTAINER="/containers/apptainer/lja-0.2.sif"
INPUT_DIR="/data/users/sschaerer/assembly_annotation_course/Mr-0"
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/lja_output"
THREADS=16

# Creating the output directory
mkdir -p "$OUTPUT_DIR"

# Building the list of --reads arguments using container paths
READS=""
for f in "$INPUT_DIR"/*.fastq.gz; do
    base=$(basename "$f")
    READS+="--reads /data/input/$base "
done

echo "Running LJA on the following input files (container paths):"
for f in "$INPUT_DIR"/*.fastq.gz; do
    echo "/data/input/$(basename "$f")"
done

# Run LJA inside the container 
apptainer exec \
    --bind "$INPUT_DIR":/data/input \
    --bind "$OUTPUT_DIR":/data/output \
    "$CONTAINER" \
    bash -c "lja -o /data/output $READS -t $THREADS"

echo "LJA assembly finished. Output is in $OUTPUT_DIR"
