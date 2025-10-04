#!/bin/bash
#SBATCH --job-name="12-run_merqury"
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=qmerqury_%j.out
#SBATCH --error=merqury_%j.err

# ---------- Variables ----------
USER='sschaerer'
WORKDIR="/data/users/${USER}/assembly_annotation_course"
CONTAINERMERQURY="/containers/apptainer/merqury_1.3.sif"
export MERQURY="/usr/local/share/merqury"

OUTDIR="${WORKDIR}/12_merqury"
mkdir -p "${OUTDIR}"
cd "${OUTDIR}"

# Input assemblies
ASSEMBLIES=(
  ${WORKDIR}/flye_output/assembly.fasta
  ${WORKDIR}/hifiasm_output/hifiasm_p_ctg.fasta
  ${WORKDIR}/lja_output/assembly.fasta
)
NAMES=("flye" "hifiasm" "lja")

# HiFi reads
READS="${WORKDIR}/Mr-0/ERR11437312.fastq.gz"

# Genome size
GENOMESIZE=135000000

# ---------- Step 1: Determine best k ----------
if [ ! -f best_k.txt ]; then
    echo "Finding best k for genome size ${GENOMESIZE}..."
    K=$(apptainer exec --bind ${WORKDIR} ${CONTAINERMERQURY} \
        sh $MERQURY/best_k.sh ${GENOMESIZE} 0.001 | tail -n1)
    echo $K > best_k.txt
else
    K=$(cat best_k.txt)
fi
echo "Using k=${K}"

# ---------- Step 2: Build meryl db for HiFi reads (once) ----------
if [ ! -d hifi.meryl ]; then
    echo "Building meryl database for HiFi reads..."
    apptainer exec --bind ${WORKDIR} ${CONTAINERMERQURY} \
        meryl count k=${K} ${READS} output hifi.meryl
fi

# ---------- Step 3 & 4: Loop over assemblies ----------
for i in "${!ASSEMBLIES[@]}"; do
    INPUTFILE="${ASSEMBLIES[i]}"
    TOOL="${NAMES[i]}"

    # Build meryl db for this assembly
    if [ ! -d ${TOOL}.meryl ]; then
        echo "Building meryl database for ${TOOL} assembly..."
        apptainer exec --bind ${WORKDIR} ${CONTAINERMERQURY} \
            meryl count k=${K} ${INPUTFILE} output ${TOOL}.meryl
    fi

    # Run Merqury
    echo "Running Merqury for ${TOOL}..."
    apptainer exec --bind ${WORKDIR} ${CONTAINERMERQURY} \
        $MERQURY/merqury.sh hifi.meryl ${TOOL}.meryl ${TOOL}_out

    if [[ $? -eq 0 ]]; then
        echo "Merqury quality assessment completed successfully for ${TOOL}"
    else
        echo "Merqury quality assessment failed for ${TOOL}"
        exit 1
    fi
done

echo "All Merqury assessments completed."

# ---------- Step 5: Summarize results ----------
echo "Summarizing Merqury results..."
SUMMARY_FILE="merqury_summary.txt"
echo -e "Assembly\tQV\tk-mer Completeness" > ${SUMMARY_FILE}
for TOOL in "${NAMES[@]}"; do
    QV=$(grep "QV" ${TOOL}_out/${TOOL}.meryl.qv.txt | awk '{print $2}')
    KCOMP=$(grep "k-mer completeness" ${TOOL}_out/${TOOL}.meryl.qv.txt | awk '{print $3}')
    echo -e "${TOOL}\t${QV}\t${KCOMP}" >> ${SUMMARY_FILE}
done
echo "Summary written to ${SUMMARY_FILE}"

