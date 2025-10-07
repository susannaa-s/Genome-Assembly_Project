#!/bin/bash
#SBATCH --job-name=build_meryl_db
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=Out&Err/meryl_%j.out
#SBATCH --error=Out&Err/meryl_%j.err

# ==========================================================
# STEP 1: Build a meryl k-mer database from PacBio HiFi reads
# ==========================================================

# --- Define paths ---
PROJECT_DIR="/data/users/${USER}/assembly_annotation_course"
READS="${PROJECT_DIR}/jellyfish_results/Mr-0/tmp_fastq/ERR11437312.fastq"
OUTPUT_DIR="${PROJECT_DIR}/11_merqury"
APPTAINER_IMG="/containers/apptainer/merqury_1.3.sif"

# --- Create output directories ---
mkdir -p "${OUTPUT_DIR}"
mkdir -p "Out&Err"

# --- Run meryl ---
apptainer exec --bind "${PROJECT_DIR}" "${APPTAINER_IMG}" \
    meryl k=21 count "${READS}" output "${OUTPUT_DIR}/hifi_reads.meryl" threads=16 memory=60

# --- Print a short summary to confirm success ---
apptainer exec --bind "${PROJECT_DIR}" "${APPTAINER_IMG}" \
    meryl statistics "${OUTPUT_DIR}/hifi_reads.meryl"

echo "-----------------------------------------------------------"
echo "Meryl database successfully created at:"
echo "  ${OUTPUT_DIR}/hifi_reads.meryl"
echo "-----------------------------------------------------------"
