#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=merqury
#SBATCH --partition=pibu_el8
#SBATCH --error=./Out&Err/merqury_error_%j.e
#SBATCH --output=./Out&Err/merqury_output%j.o

# --- Variables ---
PROJECT_DIR="/data/users/${USER}/assembly_annotation_course"
OUTPUT_DIR="${PROJECT_DIR}/merqury_results"
THREADS="${SLURM_CPUS_PER_TASK}"
APPTAINER_MERQURY="/containers/apptainer/merqury_1.3.sif"
export MERQURY="/usr/local/share/merqury"
MERYL_DB="/data/users/sschaerer/assembly_annotation_course/11_merqury/hifi_reads.meryl"

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Input files
PACBIO_READS="${PROJECT_DIR}/Mr-0/ERR11437312.fastq.gz"
ASSEMBLIES=(
    "${PROJECT_DIR}/flye_output/assembly.fasta"
    "${PROJECT_DIR}/hifiasm_output/hifiasm_p_ctg.fasta"
    "${PROJECT_DIR}/lja_output/assembly.fasta"
)
NAMES=("flye" "hifiasm" "lja")

# --- Run Merqury on all assemblies ---
for i in "${!ASSEMBLIES[@]}"; do
    ASSEMBLY="${ASSEMBLIES[$i]}"
    NAME="${NAMES[$i]}"
    ASSEMBLY_OUTPUT="${OUTPUT_DIR}/${NAME}"

    echo "Processing ${NAME} assembly: ${ASSEMBLY}"
    mkdir -p "${ASSEMBLY_OUTPUT}"
    cd "${ASSEMBLY_OUTPUT}"

    echo "Running Merqury for ${NAME}..."
    apptainer exec --userns --bind /data:/data --pwd "${ASSEMBLY_OUTPUT}" "${APPTAINER_MERQURY}" \
        bash -c "merqury.sh ${MERYL_DB} ${ASSEMBLY} ${NAME}"

    echo "Checking output files for ${NAME}:"
    ls -lh "${ASSEMBLY_OUTPUT}" | head -10
    echo "Completed Merqury for ${NAME}"
done

cd "${OUTPUT_DIR}"
