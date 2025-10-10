#!/bin/bash
#SBATCH --job-name=jellyfish_kmer
#SBATCH --partition=pibu_el8
#SBATCH --output=./Out&Err/jellyfish_%j.out
#SBATCH --error=./Out&Err/jellyfish_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=04:00:00

# Paths to container and directories
CONTAINER="/containers/apptainer/jellyfish:2.2.6--0"
# letting user provide input and output directories as arguments
INPUT_DIR=$(readlink -f "$1")
OUTPUT_DIR=$(readlink -f "$2")

# kmer length adjusted for genome length (135 Mbp) (recommended: 17-31)
KMER=21
# Number of threads to use ( matching --cpus-per-task)
THREADS=16

#  ensure output directory exists, create It if it doesn't
mkdir -p "$OUTPUT_DIR/tmp_fastq"

# jellyfish needs uncompressed fastq files, so we decompress them first
echo "Preparing input files..."
for f in "$INPUT_DIR"/*.fastq.gz; do
    base=$(basename "$f" .fastq.gz)
    gunzip -c "$f" > "$OUTPUT_DIR/tmp_fastq/${base}.fastq"
done

# Collect decompressed files into a list
FASTQ_FILES=$(ls "$OUTPUT_DIR"/tmp_fastq/*.fastq)

# to keep track of progress
echo "Counting k-mers"
# mounting input and output directories to the same paths inside the container
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

# Create histogram file to visualize k-mer distribution
# to be uploaded to GenomeScope
echo "Creating histogram"
apptainer exec \
    --bind "$OUTPUT_DIR":"$OUTPUT_DIR" \
    "$CONTAINER" \
    jellyfish histo \
        "$OUTPUT_DIR/reads_k${KMER}.jf" > "$OUTPUT_DIR/reads_k${KMER}.histo"
