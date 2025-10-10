# Genome-Assembly_Project

Note : All commands require to be launched from the projects directory "/data/users/sschaerer/assembly_annotation_course" to work correctly. 

## Part 1 - Read Quality control - FastQC 

To perform quality control on raw sequencing reads to assess overall quality, GC content, adapter contamination, and per-base quality before downstream analyses on both datasets : 
- Whole-genome PacBio HiFi reads of Arabidopsis thaliana accession MR-0
- Whole-transcriptome Illumina RNA-seq reads of accession Sha

```
sbatch Scripts/run_fastqc.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                     /data/users/sschaerer/assembly_annotation_course/fastqc_results
```

## Part 2 - Trimming - FastP 

Goal : Use fastp v0.23.2 to remove low-quality reads and adapter contamination from the Illumina RNA-seq data and to collect read statistics for the PacBio HiFi dataset (without filtering).

Command : 

```
sbatch Scripts/run_fastp.sh /data/users/sschaerer/assembly_annotation_course/RNAseq_Sha \
                    /data/users/sschaerer/assembly_annotation_course/fastp_results

```


## Part 3 - Perform k-mer counting

Goal : Perform k-mer counting on the PacBio HiFi genomic reads of to estimate genome size, heterozygosity, repeat content, and sequencing coverage using GenomeScope 2.0.

Purpose:
- Count all 21-base-long subsequences (k-mers) in the raw genomic reads.
- Generate a k-mer frequency histogram for GenomeScope model fitting.

Tool:
Jellyfish v2.2.6, executed via Apptainer container /containers/apptainer/jellyfish:2.2.6--0.

Script: run_jellyfish.sh

Input:
Whole-genome PacBio HiFi reads of A. thaliana accession MR-0

Output:
Binary k-mer count file: reads_k21.jf
Histogram file: reads_k21.histo

Command : 
```
sbatch Scripts/run_jellyfish.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                        /data/users/sschaerer/assembly_annotation_course/jellyfish_results

```


## Part 4 - Whole genome assembly using Flye

Goal : To assemble the Genome from PacBio HiFi reads using Flye v2.9.5, a long-read assembler based on the Overlap–Layout–Consensus (OLC) approach.

Purpose:
- Generate a high-quality de novo genome assembly for MR-0.

Tool:
Flye v2.9.5 executed via Apptainer container /containers/apptainer/flye_2.9.5.sif.
Script: run_flye.sh

Input:
Whole-genome PacBio HiFi reads of A. thaliana accession MR-0
- /data/users/sschaerer/assembly_annotation_course/MR-0/*.fastq.gz

Output:
- assembly.fasta — assembled contigs
- assembly_info.txt — contig statistics (length, coverage, repeat status)
- flye.log — detailed assembly log
- intermediate folders (00-assembly/, 10-consensus/, etc.)

Command:

```
sbatch Scripts/run_flye.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                   /data/users/sschaerer/assembly_annotation_course/flye_output
```

## Part 5 - Whole genome assembly using Hifiasm

Goal : To Assemble the MR-0 genome from PacBio HiFi reads using Hifiasm v0.25.0. 

Purpose:
- Generate a high-quality, haplotype-aware assembly of MR-0.

Tool:
Hifiasm v0.25.0 executed via Apptainer container /containers/apptainer/hifiasm_0.25.0.sif.

Script: run_hifiasm.sh

Input:
Whole-genome PacBio HiFi reads of A. thaliana accession MR-0
- /data/users/sschaerer/assembly_annotation_course/MR-0/*.fastq.gz

Output:
- hifiasm_assembly.p_ctg.gfa – primary contigs (main assembly)
- hifiasm_assembly.p_ctg.fa – primary contigs in FASTA format
- hifiasm_assembly.a_ctg.fa – alternate haplotype contigs (if present)
- hifiasm_assembly.utg.gfa – unphased unitig graph
- hifiasm_assembly.log – assembly log

Command:

```
sbatch Scripts/run_hifiasm.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                      /data/users/sschaerer/assembly_annotation_course/hifiasm_output
```

## Part 6 - Whole genome assembly using LJA 

Goal : to assemble the Genome from PacBio HiFi reads using LJA v0.2. 

Purpose: Perform a third independent genome assembly of MR-0 using a de Bruijn graph approach.

Tool:
LJA v0.2 executed via Apptainer container /containers/apptainer/lja-0.2.sif.

Script: run_lja.sh

Input:
Whole-genome PacBio HiFi reads of A. thaliana accession MR-0
- /data/users/sschaerer/assembly_annotation_course/MR-0/*.fastq.gz

Output:
- assembly.fasta – final assembled contigs
- assembly_graph.gfa – de Bruijn graph of contigs
- assembly.log – detailed run log
intermediate folders for jumboDBG, mowerDBG, and multiDBG steps

Command:

```
sbatch Scripts/run_lja.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                  /data/users/sschaerer/assembly_annotation_course/lja_output
```

## Part 7 - Transcriptome assembly using Trinity

Goal : to assemble the accession Sha transcriptome from paired-end Illumina RNA-seq reads using Trinity v2.15.1.

Purpose:
- Generate a de novo transcriptome assembly for A. thaliana Sha.
- Provide transcript evidence for genome annotation of MR-0.
- Identify expressed genes and alternative isoforms.

Tool:
- Trinity v2.15.1 loaded via cluster module (module load Trinity/2.15.1-foss-2021a).

Script: run_trinity.sh

Input:
FastP-treated Illumina RNA-seq paired-end reads of A. thaliana accession Sha
- /data/users/sschaerer/assembly_annotation_course/fastp_results/RNAseq_Sha/ERR754081_1_clean.fastq.gz
- /data/users/sschaerer/assembly_annotation_course/fastp_results/RNAseq_Sha/ERR754081_2_clean.fastq.gz

Output:
- Trinity.fasta – assembled transcript sequences
- Trinity.timing – runtime information
- Trinity.log – assembly log
intermediate directories (inchworm.K25, chrysalis, butterfly)

Command:
```
sbatch Scripts/07-run_trinity.sh
```

## Part 8 - Assembly completeness assessment with BUSCO

Goal : To assess the completeness of genome and transcriptome assemblies by quantifying the presence of Benchmarking Universal Single-Copy Orthologs (BUSCOs).

Purpose:
- Evaluate gene space completeness across all assemblies (Flye, Hifiasm, LJA, and Trinity).
- Determine whether essential genes are present, fragmented, duplicated, or missing.
- Provide a genome quality metric independent of contiguity (complements QUAST and Merqury).

Tool:
- BUSCO v5.4.2 loaded via cluster module
- module load BUSCO/5.4.2-foss-2021a

Scripts:
1. 08_1-run_busco.sh — runs BUSCO on each assembly
2. 08_2-run_busco_plot.sh — generates a combined summary plot in R

Input:
1. Genome assemblies:
- /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
- /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
- /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta

2. Transcriptome assembly:
- /data/users/sschaerer/assembly_annotation_course/trinity_output/Trinity.fasta

3. Lineage dataset:
- brassicales_odb10 (selected automatically by BUSCO)

Output:
Each BUSCO run produces a summary and a detailed result directory in the working folder:
short_summary.specific.brassicales_odb10.<assembly>.txt — BUSCO completeness summary
run_<assembly>/ — full directory with logs, scores, and found orthologs
busco_figure.png — combined summary bar plot (generated by the R script)

Command:
```
sbatch Scripts/08_1-run_busco.sh

```
After all runs are complete, generate the visual summary using:
```
sbatch Scripts/08_2-run_busco_plot.sh
```

After both BUSCO runs were completed on the cluster, the combined summary figure was generated locally using the R script provided by BUSCO. 


## Part 9&10 - Assembly quality assessment with QUAST

Assess the structural quality of each genome assembly (Flye, Hifiasm, and LJA) using QUAST v5.2.0, both with and without a reference genome.

Purpose:
Evaluate assembly contiguity and structural integrity using multiple quality metrics.
Identify misassemblies, mismatches, and gaps.
Compare assemblies to determine which achieves the best balance between contiguity and accuracy.
Assess additional alignment-based statistics when a reference genome is available.

Tool:
- QUAST v5.2.0 executed via Apptainer container /containers/apptainer/quast_5.2.0.sif

Scripts:
- 09-run_quast_noref.sh — runs QUAST without a reference.
- 10-run_quast_withref.sh — runs QUAST with the Arabidopsis thaliana Col-0 reference (TAIR10).

Input:
Genome assemblies:
- /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
- /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
- /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta

Reference genome and annotation:
- /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
- /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.52.gff3

Output:
Located in /data/users/sschaerer/assembly_annotation_course/analysis/09_quast/
and /data/users/sschaerer/assembly_annotation_course/analysis/10_quast_withref/
- report_no_ref.html — QUAST summary without reference
- report_with_ref.html — QUAST summary with reference alignment
- Tables of statistics (contig count, total length, N50, GC content, etc.)
- Alignment plots and misassembly summaries (only when reference is used)

Command:
**Without reference**
```
sbatch Scripts/09-run_quast_noref.sh

```

**With reference**
```
sbatch Scripts/10-run_quast_withref.sh

```

## Part 11 - Assembly evaluation using Merqury

Goal : To assesss the consensus quality and completeness of genome assemblies by comparing k-mers from assembled genomes with those from raw high-accuracy reads using Merqury v1.3.

Purpose:
- Estimate the consensus quality value (QV) and base-level error rate of each assembly.
- Measure assembly completeness based on shared k-mers between reads and assemblies.
- Verify copy-number spectra and assess representation of heterozygous and repetitive regions.
- Compare overall quality between Flye, Hifiasm, and LJA assemblies.

Tool:
Merqury v1.3 executed via Apptainer container /containers/apptainer/merqury_1.3.sif

Scripts:
- 11_1_build_meryl_db.sh — builds a meryl k-mer database from PacBio HiFi reads.
- 11_2_run_merqury.sh — runs Merqury for each assembly using the generated meryl database.

Input:
Whole-genome PacBio HiFi reads of Arabidopsis thaliana MR-0:
- data/users/sschaerer/assembly_annotation_course/MR-0/*.fastq.gz

Genome assemblies:
- /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
- /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
- /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta

Output:
Located in /data/users/sschaerer/assembly_annotation_course/merqury_results/
- <assembly>.qv — per-assembly quality summary.
- <assembly>.spectra-cn.hist — copy number spectra plot data.
- <assembly>.stats — detailed completeness metrics.
- merqury_summary.tsv — combined summary table of QV and completeness.

Command:
**Step 1: Build meryl database**
```
sbatch Scripts/11_1_build_meryl_db.sh

```

**Step 2: Run Merqury evaluation**

```
sbatch Scripts/11_2_run_merqury.sh
```

**Step 3: Create final summary table** 

```
echo -e "Assembly\tQV\tCompleteness(%)" > merqury_summary.tsv

for name in flye hifiasm lja; do
    qv=$(awk '/assembly|hifiasm_p_ctg/ {print $4}' ${name}/*.qv | tail -n1)
    comp=$(awk '/assembly|hifiasm_p_ctg/ {print $5}' ${name}/*.completeness.stats | tail -n1)
    echo -e "${name}\t${qv}\t${comp}" >> merqury_summary.tsv
done

column -t merqury_summary.tsv
```

## Part 12 - Whole-genome alignment and visualisation with MUMmer

Perform pairwise whole-genome alignments using MUMmer v4 to visualise structural rearrangements, inversions, and overall synteny among assemblies and between each assembly and the Arabidopsis thaliana reference genome (Col-0, TAIR10).

Purpose:
- Compare de novo assemblies (Flye, Hifiasm, LJA) against the Arabidopsis thaliana Col-0 reference to assess large-scale genome structure.
- Identify major rearrangements, translocations, and inversions.
- Compare assemblies against each other to visualise consistency between assemblers.

Tool:
- MUMmer v4 executed via Apptainer container /containers/apptainer/mummer4_gnuplot.sif

Script:
run_nucmer_mummerplot.sh

Input:
Genome assemblies from Flye, Hifiasm, and LJA
- /data/users/sschaerer/assembly_annotation_course/flye_output/assembly.fasta
- /data/users/sschaerer/assembly_annotation_course/hifiasm_output/hifiasm_p_ctg.fasta
- /data/users/sschaerer/assembly_annotation_course/lja_output/assembly.fasta
Reference genome (TAIR10, Col-0):
- /data/users/sschaerer/assembly_annotation_course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

Output:
Located in /data/users/sschaerer/assembly_annotation_course/analysis/13_mummer/
1. Alignment files:
.delta — raw alignment output from nucmer
_filtered.delta — filtered alignments retaining best matches
2. Dotplots:
.png images showing alignments, one per pairwise comparison

Command:
```
sbatch Scripts/run_nucmer_mummerplot.sh

```
