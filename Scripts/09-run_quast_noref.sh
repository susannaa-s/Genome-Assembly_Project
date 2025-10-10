#!/bin/bash
#SBATCH --job-name=quast_no_ref
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=quast_no_ref_%j.out
#SBATCH --error=quast_no_ref_%j.err

# path to container and assemblies
QUAST_CONTAINER=/containers/apptainer/quast_5.2.0.sif
ASSEMBLIES=(
  /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
  /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
  /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta
)

# the labels for the assemblies in the same order as above
LABELS="flye,hifiasm,lja"

# Make sure output directory exists, create It if it doesn't
OUTPUT_DIR=/data/users/sschaerer/assembly_annotation_course/quast_no_ref_output
mkdir -p "$OUTPUT_DIR"

# running quast without reference
apptainer exec $QUAST_CONTAINER quast.py \
  --eukaryote \
  --threads 16 \
  --labels $LABELS \
  "${ASSEMBLIES[@]}" \
  -o $OUTPUT_DIR
