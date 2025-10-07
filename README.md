# Genome-Assembly_Project


All commands require to be launched from the projects directory "/data/users/sschaerer/assembly_annotation_course" to work correctly. 


## Part 1 - Read Quality control - FastQC 

To perform quality control on raw sequencing reads to assess overall quality, GC content, adapter contamination, and per-base quality before downstream analyses on both datasets : 
- Whole-genome PacBio HiFi reads of Arabidopsis thaliana accession MR-0
- Whole-transcriptome Illumina RNA-seq reads of accession Sha

```
sbatch run_fastqc.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                     /data/users/sschaerer/assembly_annotation_course/fastqc_results
```

## Part 2 - Trimming - FastP 

Use fastp v0.23.2 to remove low-quality reads and adapter contamination from the Illumina RNA-seq data and to collect read statistics for the PacBio HiFi dataset (without filtering).

Command : 

```
sbatch run_fastp.sh /data/users/sschaerer/assembly_annotation_course/RNAseq_Sha \
                    /data/users/sschaerer/assembly_annotation_course/fastp_results

```


## Part 3 - Perform k-mer counting

Perform k-mer counting on the PacBio HiFi genomic reads of to estimate genome size, heterozygosity, repeat content, and sequencing coverage using GenomeScope 2.0.

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
sbatch run_jellyfish.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                        /data/users/sschaerer/assembly_annotation_course/jellyfish_results

```


## Part 4 - Whole genome assembly using Flye

Assembling the Genome from PacBio HiFi reads using Flye v2.9.5, a long-read assembler based on the Overlap–Layout–Consensus (OLC) approach.

Purpose:
- Generate a high-quality de novo genome assembly for MR-0.
- Evaluate contiguity and completeness compared to Hifiasm and LJA assemblies.

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
sbatch run_flye.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                   /data/users/sschaerer/assembly_annotation_course/flye_output
````

## Part 5 - Whole genome assembly using Hifiasm

Assembling the Arabidopsis thaliana MR-0 genome from PacBio HiFi reads using Hifiasm v0.25.0. 

Purpose:
- Generate a high-quality, haplotype-aware assembly of MR-0.
- Compare assembly contiguity and accuracy with Flye and LJA results.

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
sbatch run_hifiasm.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                      /data/users/sschaerer/assembly_annotation_course/hifiasm_output
````

## Part 6 - Whole genome assembly using LJA 

Assembling the Genome from PacBio HiFi reads using LJA v0.2. 

Purpose:
- Perform a third independent genome assembly of MR-0 using a de Bruijn graph approach.
C- ompare assembly contiguity and accuracy with Flye (OLC) and Hifiasm (string graph) assemblies.

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
sbatch run_lja.sh /data/users/sschaerer/assembly_annotation_course/MR-0 \
                  /data/users/sschaerer/assembly_annotation_course/lja_output
```

## Part 7 - Transcriptome assembly using Trinity

Assembling the accession Sha transcriptome from paired-end Illumina RNA-seq reads using Trinity v2.15.1.

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
sbatch Scripts/07-run_trinity.sh


## Part 8 - Assembly completeness assessment with BUSCO

To assess the completeness of genome and transcriptome assemblies by quantifying the presence of Benchmarking Universal Single-Copy Orthologs (BUSCOs).


Purpose:
- Evaluate gene space completeness of assembled genomes and transcriptomes.
- Compare completeness among Flye, Hifiasm, LJA, and Trinity assemblies.
- Detect potential redundancy (duplicated BUSCOs) or missing gene content.

Tool:
- BUSCO v5.4.2 loaded via cluster module:
- module load BUSCO/5.4.2-foss-2021a

Script: run_busco.sh

Input:
- Genome assemblies (assembly.fasta) from Flye, Hifiasm, LJA
- Transcriptome assembly (Trinity.fasta) from Trinity

Output:

- short_summary.specific.brassicales_odb10.<assembly>.txt — summary of BUSCO completeness
- run_<assembly>/ — full BUSCO result directory with detailed logs and gene matches

Command:
To run BUSCO on one assembly, specify which one to assess inside the script (ASSEMBLY_TYPE) More detailed instructions can be found in the script itself. 

```
sbatch run_busco.sh

```



