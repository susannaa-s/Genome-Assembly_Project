#!/bin/bash
#SBATCH --job-name=quast_with_ref
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=quast_with_ref_%j.out
#SBATCH --error=quast_with_ref_%j.err

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

# Reference genome
REFERENCE=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

# Output directory
OUTPUT_DIR=/data/users/sschaerer/assembly_annotation_course/quast_with_ref_output
mkdir -p "$OUTPUT_DIR"

# Run QUAST
apptainer exec \
  --bind /data/courses/assembly-annotation-course/references:/mnt/ref \
  $QUAST_CONTAINER quast.py \
  --eukaryote \
  --threads 16 \
  --labels $LABELS \
  -R /mnt/ref/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
  --features /mnt/ref/Arabidopsis_thaliana.TAIR10.57.gff3 \
  "${ASSEMBLIES[@]}" \
  -o $OUTPUT_DIR
