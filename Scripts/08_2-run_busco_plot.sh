#!/usr/bin/env bash

#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=plot_busco
#SBATCH --partition=pibu_el8
#SBATCH --error=./Out&Err/busco_plot_error_%j.e
#SBATCH --output=./Out&Err/busco_plot_out_%j.o

# --- Variables ---
PROJECT_DIR="/data/users/${USER}/assembly_annotation_course"
OUTPUT_DIR="${PROJECT_DIR}/busco_plots"
THREADS="${SLURM_CPUS_PER_TASK}"

module load BUSCO/5.4.2-foss-2021a

# --- Input check ---
if [ "$#" -ne 4 ]; then
  echo "Usage: sbatch $0 <flye_summary> <hifiasm_summary> <lja_summary> <trinity_summary>"
  exit 1
fi

FLYE_BUSCO_SUMMARY=$(realpath $1)
HIFIASM_BUSCO_SUMMARY=$(realpath $2)
LJA_BUSCO_SUMMARY=$(realpath $3)
TRINITY_BUSCO_SUMMARY=$(realpath $4)

# --- Prepare output directory ---
mkdir -p "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}"

echo "Copying BUSCO summary files..."
cp "${FLYE_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.flye_busco.txt"
cp "${HIFIASM_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.hifiasm_busco.txt"
cp "${LJA_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.lja_busco.txt"
cp "${TRINITY_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.trinity_busco.txt"

# --- Download BUSCO plotting script if not present ---
if [ ! -f "generate_plot.py" ]; then
    wget -q -O generate_plot.py "https://gitlab.com/ezlab/busco/-/raw/5.4.2/scripts/generate_plot.py"
fi

if [ ! -f "generate_plot.py" ]; then
    echo "Error: Failed to download generate_plot.py"
    exit 1
fi

# --- Generate BUSCO plot ---
echo "Generating BUSCO plot..."
python3 generate_plot.py -wd "${OUTPUT_DIR}"

echo "BUSCO plot generation complete!"
echo "Check ${OUTPUT_DIR}/busco_figure.png"
