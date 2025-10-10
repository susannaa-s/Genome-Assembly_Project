## Part 1 – Reads & Quality Control

### After FastQC

1. What are the read lengths of the different datasets?

| Dataset    | Sequencing technology | Read type        | Mean read length (bp)      | Total bases (Gbp) |
| ---------- | --------------------- | ---------------- | -------------------------- | ----------------- |
| MR-0       | PacBio HiFi           | long, single-end | 10 000 – 20 000 (variable) | ≈ 7.2             |
| RNAseq_Sha | Illumina              | paired-end       | 151 (fixed)                | ≈ 2.2             |

As we can see, the read lengths range between 10'000 and 20'000 bp. 

2. Are the datasets of good quality?

- PacBio HiFi reads show consistently high base quality (Q > 30) across their full length — excellent for assembly.
- Illumina RNA-seq reads (Sha_1 and Sha_2) maintain Q > 30 for most bases with a slight 3′-end drop, typical for RNA-seq.
- %GC is within expected range (MR-0: 37 %, Sha: 46 %), no reads flagged as poor quality.
- Other FastQC modules (sequence length, duplication, N-content, overrepresented sequences) all within expected limits for their respective technologies.


### After FastP

3. How many reads were trimmed/filtered and did the quality improve?

Approximately 8–9 % of Illumina reads were filtered to minimise adapter contamination or low quality reads.
After trimming, the mean base quality improved by about 3–6 % at Q20–Q30 levels, this indicate more reliable reads for downstream RNA-seq analysis.

4. What kind of coverage do you expect from the PacBio WGS reads? (hint: lookup the expected genome size of Arabidopsis thaliana)

Arabidopsis thaliana has a genome size of roughly 135 Mb.
Given ~20–30 Gb of PacBio HiFi data per accession, this corresponds to an expected coverage of about **150–200×**, ideal for producing high-quality, chromosome-level assemblies.
Estimated coverage:
\[
\text{Coverage} =  \frac{7.2 \text{Gbp }}{0.135 \text{Gbp}}  \approx \times 53.333
\]

### After K-mer Counting

<p align="center">
  <img src="Images/GenomeScope_1.png" width="450">
  <img src="Images/GenomeScope_2.png" width="450">
</p>

5. Is the estimated genome size expected?

GenomeScope estimated 123.8 Mb — very close to the expected 135 Mb for Arabidopsis thaliana.

6. Is the percentage of heterozygosity expected?

Estimated heterozygosity was 0.037 %, which is low and fully consistent with Arabidopsis being a predominantly self-fertilising, homozygous species.

7. Is the coverage expected?

The main k-mer coverage peak was around 40×, indicating uniform sequencing depth and well-saturated coverage. This is consistent with the expected data quality.

8. Bonus: Why are we using canonical k-mers? (use Google)

- Every DNA sequence has a reverse complement -> counting k-mers, both can appear in the data depending on sequencing orientation
- Use canonical k-mers to avoid this "double counting".
- Also, this reduces storage requirements and ensures coverage estimation independednt of the sspecific strand.

## Part 2 – Assembly evaluation and comparing genomes

### After BUSCO comparison

<p align="center">
  <img src="Images/busco_figure.png" width="450"><br>
  <em>BUSCO assessment of Flye, Hifiasm, LJA genome assemblies and the Trinity transcriptome.</em>
</p>

1. How do your genome assemblies look according to your BUSCO results?

- All three genome assemblies (Flye, Hifiasm, LJA) show exceptionally high completeness (≈ 99.3 %, 4563–4564 / 4596 BUSCO genes).
- Most are single-copy (S ≈ 4493–4495), indicating nearly all expected orthologues were recovered.
- Fragmented (F ≤ 3) and missing (M ≈ 29–31) BUSCOs are minimal, confirming highly complete and accurate assemblies.

2. Is one genome assembly better than the other?

- They are nearly identical in completeness; LJA shows slightly fewer duplicates and an assembly size closest to the expected A. thaliana genome (≈ 135 Mb), so it may best represent a non-redundant haploid reconstruction.

3. How does your transcriptome assembly look?

The Trinity assembly has C = 3650 / 4596 (≈ 79.5 %) BUSCOs. This is good for a transcriptome, but lower than the genomic assemblies. Also this is to be expected as alternwtive splicing and general shorter reads lead to more duplicated and fragmented genes repsctively being registered. 

4. Are there many duplicated genes? Can you explain the differences with the whole genome assemblies?**

Yes (D = 1871 ≈ 51 %). As mentioned, d uplications stem from alternative splicing and multiple isoforms of expressed genes.
Transcriptome assemblies only include expressed transcripts, not the whole gene set, and RNA-seq coverage is less uniform, leading to fragmented or duplicated BUSCOs.


### After QUAST comparison

5. How do your genome assemblies look according to your QUAST results?**

 - Flye: 120.5 Mb total (76 contigs), N50 = 7.6 Mb, duplication ratio 1.025, GC = 36.05 %.
-  Hifiasm: 167.0 Mb (611 contigs), N50 = 10.7 Mb, duplication ratio 1.299 → likely retained alternative haplotypes.
- LJA: 144.0 Mb (483 contigs), N50 = 14.2 Mb, duplication ratio 1.086.

All cover ≈ 89 % of the reference genome and have matching GC content (~36 %).

6. Is one genome assembly better than the other?

LJA achieves the highest N50 and assembly size closest to the true genome, suggesting the best balance between contiguity and accuracy.

7. What additional information you get if you have a reference available?

With reference :  QUAST adds alignment metrics (misassemblies, unaligned lengths, mismatches, indels) 
- reveals structural errors or gaps, providing insight into how contigs align to known chromosome

### After Merqury comparison

8. What are the consensus quality QV and error rate values of your assemblies?

| Assembly | QV   | Error rate | Accuracy (%) |
| -------- | ---- | ---------- | ------------ |
| Flye     | 56.1 | 2.4 × 10⁻⁶ | 99.9998      |
| Hifiasm  | 54.7 | 3.4 × 10⁻⁶ | 99.9997      |
| LJA      | 55.0 | 3.2 × 10⁻⁶ | 99.9997      |

9. What is the estimated completeness of your assemblies?
   
≈ 99 % for all three, indicating nearly all k-mers from the reads were represented in the assemblies.

10. How does your copy-number spectra look like? Do they confirm the expected coverage?

- red 1x peak : single-copy dominates around 45× coverage, consistent with Arabidopsis expectations.
- Higher copy-number colours (blue, green, purple, orange) mark true repeats; grey k-mers (read-only) are minimal.
Confirms : no major sequence loss or collapse.

11. Does one assembly perform better than the other?

All perform very well; Flye has slightly higher QV and completeness, indicating marginally better consensus accuracy. Differences are minor and within normal HiFi variability.


### After Nucmer and Mummer

12. What does the dotplot show and what do the different colours mean?

Each dot represents a region of similarity between two assemblies. On the graph, we place them along the length of the assembly/reference for comparison. 

- x-axis = reference position (bp)
- y-axis = query assembly position (bp)
  Purple / blue lines = forward alignments; reverse (diagonal top-left to bottom-right) = inversions.
  Breaks or scattered dots = rearrangements or gaps.

13. Do your genome assemblies look very different from the reference genome?

No major structural deviations; continuous diagonals indicate high synteny with the Col-0 reference. Small breaks reflect real accession-specific rearrangements rather than assembly errors.

14. How different are the genome assemblies compared to each other?
    
When aligned pairwise (Flye vs Hifiasm, Flye vs LJA, Hifiasm vs LJA), their dotplots show translocations, tranversions and inversions. Over all completeness lengthwise (if we were to align all the peices) indicate that there have been no major errors during the assembly processes. To confirm this, more detailed analysis would have to be performed. 

5. Compare the different accessions from your group. Do you see any differences between the accessions?
   
Across accessions, differences appear mainly as rearranged segments and local gaps in alignment, especially int he centromeric regions. Otherwise they show a relatively consistent image. Interestingly, not every assembly agreed on the best assembler to be used. 

### Figures

<p align="center">
  <img src="Images/flye_vs_ref.png" width="420">
  <img src="Images/hifiasm_vs_ref.png" width="420"><br>
  <em>Genome-to-reference alignments (Flye and Hifiasm vs Col-0 reference).</em>
</p>

<p align="center">
  <img src="Images/lja_vs_ref.png" width="420">
  <img src="Images/flye_vs_hifiasm.png" width="420"><br>
  <em>Assembly-to-assembly alignments (LJA vs reference and Flye vs Hifiasm).</em>
</p>

<p align="center">
  <img src="Images/flye_vs_lja.png" width="420">
  <img src="Images/hifiasm_vs_lja.png" width="420"><br>
  <em>Pairwise comparisons between assemblies of the same MR-0 accession to assess assembler consistency.</em>
</p>

