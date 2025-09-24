#!/bin/bash
#SBATCH --job-name=jellyfish_kmer
#SBATCH --partition=pibu_el8
#SBATCH --output=jellyfish_%j.out
#SBATCH --error=jellyfish_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=04:00:00

# Paths
CONTAINER="/containers/apptainer/jellyfish:2.2.6--0"
INPUT_DIR=$(readlink -f "$1")
OUTPUT_DIR=$(readlink -f "$2")
KMER=21
THREADS=4

mkdir -p "$OUTPUT_DIR/tmp_fastq"

echo "Preparing input files..."
for f in "$INPUT_DIR"/*.fastq.gz; do
    base=$(basename "$f" .fastq.gz)
    gunzip -c "$f" > "$OUTPUT_DIR/tmp_fastq/${base}.fastq"
done

# Collect decompressed files into a list
FASTQ_FILES=$(ls "$OUTPUT_DIR"/tmp_fastq/*.fastq)

echo "Counting k-mers"
apptainer exec \
    --bind "$INPUT_DIR":"$INPUT_DIR" \
    --bind "$OUTPUT_DIR":"$OUTPUT_DIR" \
    "$CONTAINER" \
    jellyfish count \
        -m $KMER \
        -s 5G \
        -t $THREADS \
        -C \
        $FASTQ_FILES \
        -o "$OUTPUT_DIR/reads_k${KMER}.jf"

echo "Creating histogram"
apptainer exec \
    --bind "$OUTPUT_DIR":"$OUTPUT_DIR" \
    "$CONTAINER" \
    jellyfish histo \
        "$OUTPUT_DIR/reads_k${KMER}.jf" > "$OUTPUT_DIR/reads_k${KMER}.histo"
