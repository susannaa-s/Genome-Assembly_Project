#!/bin/bash
#SBATCH --job-name="12-run_merqury"
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=qmerqury_%j.out
#SBATCH --error=merqury_%j.err

module load merqury

# Paths to input files
HIFI_READS="/data/users/sschaerer/assembly_annotation_course/Mr-0/ERR11437312.fastq.gz"  # your HiFi reads
ASSEMBLIES=(
    "/data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta"
    "/data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta"
    "/data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta"
)
NAMES=("flye" "hifiasm" "lja")

# Create meryl database for HiFi reads
echo "Counting kmers for HiFi reads..."
meryl count k=18 input=$HIFI_READS output=hifi.meryl

# Count kmers for each assembly
for i in ${!ASSEMBLIES[@]}; do
    echo "Counting kmers for ${NAMES[$i]} assembly..."
    meryl count k=18 input=${ASSEMBLIES[$i]} output=${NAMES[$i]}.meryl
done

# Run Merqury QV and k-mer completeness calculation
for i in ${!ASSEMBLIES[@]}; do
    echo "Running Merqury for ${NAMES[$i]}..."
    merqury.sh hifi.meryl ${NAMES[$i]}.meryl ${NAMES[$i]} ${NAMES[$i]}_out
done

echo "Merqury runs finished. Summary available in *_out/merqury_summary.txt"
