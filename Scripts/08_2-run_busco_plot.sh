#!/usr/bin/env bash

#SBATCH --time=01:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=plot_busco
#SBATCH --partition=pibu_el8
#SBATCH --error=./Out&Err/busco_plot_error_%j.e
#SBATCH --output=./Out&Err/busco_plot_out_%j.o

# Paths to container and directories
PROJECT_DIR="/data/users/${USER}/assembly_annotation_course"
OUTPUT_DIR="${PROJECT_DIR}/busco_plots"
THREADS="${SLURM_CPUS_PER_TASK}"

# Load available BUSCO module, the container could not be used in this case, otherwise it would be the preferred method
module load BUSCO/5.4.2-foss-2021a

# summary files from different BUSCO runs (full paths)
# The order should be: flye, hifiasm, lja, trinity
if [ "$#" -ne 4 ]; then
  echo "Usage: sbatch $0 <flye_summary> <hifiasm_summary> <lja_summary> <trinity_summary>"
  exit 1
fi

# Resolving the  full paths
FLYE_BUSCO_SUMMARY=$(realpath $1)
HIFIASM_BUSCO_SUMMARY=$(realpath $2)
LJA_BUSCO_SUMMARY=$(realpath $3)
TRINITY_BUSCO_SUMMARY=$(realpath $4)

# Make sure output directory exists, create It if it doesn't
mkdir -p "${OUTPUT_DIR}"
# Move to output directory
cd "${OUTPUT_DIR}"

# Copy the summary files to the current directory with specific names to provide structure for the plotting script
echo "Copying BUSCO summary files..."
cp "${FLYE_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.flye_busco.txt"
cp "${HIFIASM_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.hifiasm_busco.txt"
cp "${LJA_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.lja_busco.txt"
cp "${TRINITY_BUSCO_SUMMARY}" "short_summary.specific.brassicales_odb10.trinity_busco.txt"

# downloading the plotting script if not already present
if [ ! -f "generate_plot.py" ]; then
    wget -q -O generate_plot.py "https://gitlab.com/ezlab/busco/-/raw/5.4.2/scripts/generate_plot.py"
fi

# Affirm the script was downloaded successfully
if [ ! -f "generate_plot.py" ]; then
    echo "Error: Failed to download generate_plot.py"
    exit 1
fi

# Run the plotting script to generate the BUSCO plot
echo "Generating BUSCO plot..."
python3 generate_plot.py -wd "${OUTPUT_DIR}"

# to keep track of progress
echo "BUSCO plot generation complete!"
echo "Check ${OUTPUT_DIR}/busco_figure.png"
