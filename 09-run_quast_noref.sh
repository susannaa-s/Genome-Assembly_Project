#!/bin/bash
#SBATCH --job-name=quast_no_ref
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=quast_no_ref_%j.out
#SBATCH --error=quast_no_ref_%j.err

# Load Apptainer container
QUAST_CONTAINER=/containers/apptainer/quast_5.2.0.sif

# Paths to assemblies
ASSEMBLIES=(
  /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
  /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
  /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta
)

# Labels for assemblies
LABELS="flye,hifiasm,lja"

# Output directory
OUTPUT_DIR=/data/users/sschaerer/assembly_annotation_course/quast_no_ref_output
mkdir -p "$OUTPUT_DIR"

# Run QUAST
apptainer exec $QUAST_CONTAINER quast.py \
  --eukaryote \
  --threads 16 \
  --labels $LABELS \
  "${ASSEMBLIES[@]}" \
  -o $OUTPUT_DIR
