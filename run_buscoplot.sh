#!/bin/bash
#SBATCH --job-name=busco_plot_trinity
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=0-01:00:00
#SBATCH --output=busco_plot_trinity_%j.out
#SBATCH --error=busco_plot_trinity_%j.err

# Load BUSCO module (includes Python environment)
module load BUSCO/5.4.2-foss-2021a

# Path to BUSCO generate_plot.py script
BUSCO_PLOT_SCRIPT="/srv/ss/sib/ibu/rocky8/2023072800/software/BUSCO/5.4.2-foss-2021a/bin/generate_plot.py"

# Directory of the previous BUSCO run
WORKING_DIR="/data/users/sschaerer/assembly_annotation_course/busco_trinity_output/trinity_busco"

# Generate plots
python3 "$BUSCO_PLOT_SCRIPT" -wd "$WORKING_DIR"
