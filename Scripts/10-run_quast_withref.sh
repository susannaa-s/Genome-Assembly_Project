#!/bin/bash
#SBATCH --job-name=quast_with_ref
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=quast_with_ref_%j.out
#SBATCH --error=quast_with_ref_%j.err

# path to container and assemblies
QUAST_CONTAINER=/containers/apptainer/quast_5.2.0.sif
ASSEMBLIES=(
  /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
  /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
  /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta
)

#  the labels for the assemblies in the same order as above
LABELS="flye,hifiasm,lja"

# Reference genome for QUAST
REFERENCE=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

#  Make sure output directory exists, create It if it doesn't
OUTPUT_DIR=/data/users/sschaerer/assembly_annotation_course/quast_with_ref_output
mkdir -p "$OUTPUT_DIR"

# Run QUAST with reference i.e. with -R option Aradidopsis thaliana TAIR 10 
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
