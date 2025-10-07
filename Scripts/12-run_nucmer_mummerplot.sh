#!/bin/bash
#SBATCH --job-name=nucmer_mummerplot
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --output=Out&Err/nucmer_mummerplot_%j.out
#SBATCH --error=Out&Err/nucmer_mummerplot_%j.err

# --- Variables ---
PROJECT_DIR="/data/users/${USER}/assembly_annotation_course"
REF="${PROJECT_DIR}/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
ASSEMBLIES=(
    "${PROJECT_DIR}/flye_output/assembly.fasta"
    "${PROJECT_DIR}/hifiasm_output/hifiasm_p_ctg.fasta"
    "${PROJECT_DIR}/lja_output/assembly.fasta"
)
NAMES=("flye" "hifiasm" "lja")
OUTDIR="${PROJECT_DIR}/mummer_output"
CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"

mkdir -p "${OUTDIR}"

# --- Loop through assemblies ---
for i in "${!ASSEMBLIES[@]}"; do
    ASM="${ASSEMBLIES[$i]}"
    NAME="${NAMES[$i]}"
    PREFIX="${OUTDIR}/${NAME}_vs_ref"

    echo "Running nucmer for ${NAME}..."

    singularity exec ${CONTAINER} nucmer \
        --prefix="${PREFIX}" \
        --breaklen 1000 \
        --mincluster 1000 \
        "${REF}" "${ASM}"

    echo "Filtering delta file..."
    singularity exec ${CONTAINER} delta-filter -r -q "${PREFIX}.delta" > "${PREFIX}_filtered.delta"

    echo "Generating dotplot..."
    singularity exec ${CONTAINER} mummerplot \
        -R "${REF}" \
        -Q "${ASM}" \
        --filter \
        -t png \
        --large \
        --layout \
        --fat \
        -p "${PREFIX}" \
        "${PREFIX}_filtered.delta"
done

# --- Compare assemblies against each other ---
for ((i=0; i<${#ASSEMBLIES[@]}; i++)); do
    for ((j=i+1; j<${#ASSEMBLIES[@]}; j++)); do
        ASM1="${ASSEMBLIES[$i]}"
        ASM2="${ASSEMBLIES[$j]}"
        NAME1="${NAMES[$i]}"
        NAME2="${NAMES[$j]}"
        PREFIX="${OUTDIR}/${NAME1}_vs_${NAME2}"

        echo "Comparing ${NAME1} vs ${NAME2}..."
        singularity exec ${CONTAINER} nucmer \
            --prefix="${PREFIX}" \
            --breaklen 1000 \
            --mincluster 1000 \
            "${ASM1}" "${ASM2}"

        singularity exec ${CONTAINER} delta-filter -r -q "${PREFIX}.delta" > "${PREFIX}_filtered.delta"

        singularity exec ${CONTAINER} mummerplot \
            -R "${ASM1}" \
            -Q "${ASM2}" \
            --filter \
            -t png \
            --large \
            --layout \
            --fat \
            -p "${PREFIX}" \
            "${PREFIX}_filtered.delta"
    done
done

echo "All comparisons and plots completed."
