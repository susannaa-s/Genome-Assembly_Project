#!/usr/bin/env bash

#SBATCH --time=00:10:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=busco_Rplot
#SBATCH --partition=pibu_el8
#SBATCH --error=./Out&Err/busco_Rplot_error_%j.e
#SBATCH --output=./Out&Err/busco_Rplot_out_%j.o

module load R/4.2.1-foss-2021a

# Run the BUSCO R plotting script
Rscript /data/users/${USER}/assembly_annotation_course/busco_plots/busco_figure.R

