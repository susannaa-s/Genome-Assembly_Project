#!/bin/bash
#SBATCH --job-name=busco_run_trinity
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=busco_trinity_%j.out
#SBATCH --error=busco_trinity_%j.err

# Load available BUSCO module
module load BUSCO/5.4.2-foss-2021a

# -------- Choose which assembly to assess ----------
ASSEMBLY_TYPE="trinity"   # options: flye | hifiasm | lja | trinity
# ---------------------------------------------------

# Assign proper path to the selected assembly
declare -A ASSEMBLIES
ASSEMBLIES["flye"]="/data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta"
ASSEMBLIES["hifiasm"]="/data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta"
ASSEMBLIES["lja"]="/data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta"
ASSEMBLIES["trinity"]="/data/users/sschaerer/assembly_annotation_course/trinity_output/trinity_output.Trinity.fasta"


INPUT_ASSEMBLY=${ASSEMBLIES[$ASSEMBLY_TYPE]}

# Select mode automatically
if [ "$ASSEMBLY_TYPE" = "trinity" ]; then
  MODE="transcriptome"
else
  MODE="genome"
fi

# Output directory
OUTPUT_DIR="/data/users/sschaerer/assembly_annotation_course/busco_${ASSEMBLY_TYPE}_output"
mkdir -p "$OUTPUT_DIR"

# Run BUSCO
busco \
  --in "$INPUT_ASSEMBLY" \
  --out "${ASSEMBLY_TYPE}_busco" \
  --out_path "$OUTPUT_DIR" \
  --mode "$MODE" \
  --lineage_dataset brassicales_odb10 \
  --cpu 16 \
  -f \



 




