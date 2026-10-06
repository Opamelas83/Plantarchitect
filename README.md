# Plantarchitect

[workflowr]: https://github.com/Opamelas83/Plantarchitect

This repository contains the analysis workflow associated with the
study:

**"Genetic basis of cassava (*Manihot esculenta* Crantz) plant
architecture and its relevance for ideotype breeding."**

The study uses historical multi-environment field-trial data from
cassava breeding programs in Nigeria to characterize variation in plant
architecture, evaluate relationships between plant architecture and
agronomic traits, identify genomic regions associated with architecture
traits, and assess the potential of genomic prediction for these traits.

## Overview of the Analysis

The workflow consists of four main components:

1.  **Phenotypic data preparation and trial quality control**
2.  **Phenotypic and multi-environment mixed-model analysis**
3.  **Genotype processing, population structure, linkage disequilibrium,
    and genome-wide association analysis**
4.  **Genomic prediction and cross-validation**

The principal scripts are located in the `analysis/` directory and are
described below in their general order of use.

------------------------------------------------------------------------

## Repository Structure

Plantarchitect/
├── analysis/     # Main R Markdown analysis scripts
├── code/         # Supporting R code and functions
├── data/         # Phenotypic, genotypic, and intermediate input data
├── Result/       # Tables, figures, and analysis results
├── output/       # Intermediate R objects and matrices
├── docs/         # workflowr-generated website files
└── README.md     # Repository documentation

------------------------------------------------------------------------

# Phenotypic Data Preparation and Analysis

## 1. Build the Initial Phenotypic Dataset

**Script:** `analysis/data_building.Rmd`

This script imports and integrates phenotypic and trial information,
examines trait availability across breeding programs and trials, selects
traits for subsequent analyses, harmonizes trait names and measurement
units, and prepares the initial working phenotypic dataset.

The script includes plant architecture traits such as plant height,
first branching height, branching level number, and plant architecture,
together with agronomic traits used in subsequent analyses.

**Main output:**

data/MyArchidata.csv

------------------------------------------------------------------------

## 2. Curate Experimental-Design Information

**Script:** `analysis/data_curation.Rmd`

This script examines the experimental-design structure of the historical
field-trial data and prepares variables required for subsequent
mixed-model analyses.

The workflow distinguishes replicated and non-replicated trials and
creates nested design variables describing year within location, trial
structure, replicates, and blocks. These variables are used to account
for the heterogeneous experimental designs represented in the historical
breeding data.

**Main output:**

data/MyArchiphenotypes.csv

------------------------------------------------------------------------

## 3. Single-Trial Quality Control

**Script:** `analysis/fieldtrialfilter.Rmd`

This script performs single-trial quality control separately for
replicated and non-replicated trials using mixed-model analyses.

For each trait-by-trial combination, genetic and residual variance
components and measures of trial quality are estimated. Trial-trait
combinations are retained based on genetic signal and experimental
accuracy, and observations with absolute Studentized Residuals greater
than 3 are removed.

The quality-controlled data from replicated and non-replicated trials
are subsequently combined to generate the phenotypic dataset used in
downstream analyses.

**Main output:**

data/MyArchiphenos_final.csv

------------------------------------------------------------------------

## 4. Plant-Shape Trait Processing

**Script:** `analysis/Archi_scale.Rmd`

This script processes the four plant-shape categories:

-   Cylindrical
-   Umbrella
-   Open
-   Compact

Plant-shape categories are represented as binary variables for analysis.
The script examines their distribution across the historical trials and
applies binomial mixed-model analyses to characterize genetic variation
in these traits.

The resulting plant-shape data are used together with the quantitative
architecture traits in subsequent phenotypic and genomic analyses.

**Main output:**

data/Shapephenos_filtered.csv

------------------------------------------------------------------------

## 5. Multi-Environment Mixed-Model Analysis

**Script:** `analysis/Phenodata_analysis.Rmd`

This script performs the main multiple-trial mixed-model analyses for
the quantitative architecture and agronomic traits and for the binary
plant-shape traits.

For quantitative traits, linear mixed-effects models are used to
estimate accession effects and variance components across trials. For
plant-shape categories, generalized linear mixed-effects models with a
binomial distribution are fitted.

The script generates accession BLUPs and associated quantities used in
downstream analyses and combines the quantitative and plant-shape
results into the phenotypic inputs required for genomic analyses.

**Key outputs include:**

``` text
Result/GeneralMML_result.rds
Result/results_Shape.rds
output/blups_Archi.rds
output/ArchitMML_blups.rds
output/blups_shape.rds
output/ShapeMML_blups.rds
output/blups.rds
```
------------------------------------------------------------------------

## 6. Phenotypic Summaries and Population Structure

**Script:** `analysis/generalanalysis.Rmd`

This script generates summary statistics, tables, and figures used to
characterize the phenotypic and genomic datasets.

Phenotypic analyses include summaries of trait distributions across
breeding programs and breeding stages, plant-shape distributions,
correlations among accession BLUPs, and summaries of variance components
and heritability.

The script also evaluates population structure among genotyped
accessions using principal component analysis (PCA). PCA results are
used to characterize genetic structure and to support subsequent
genome-wide association analyses.

The script additionally generates SNP contribution information for the
principal components and figures describing population structure.

**Key outputs include:**

Result/MySummaryData.csv
Result/MySummaryShapeDataS.csv
Result/Vartable.csv
Result/pca_result.rds
Result/pca_ind.rds
Result/pca_ind_dim12.csv
output/Dosage_pca.csv

------------------------------------------------------------------------

# Genotype Processing

## 7. Genotype and VCF Processing

**Script:** `analysis/VCFfilestreatment.Rmd`

This script prepares the genotype data for genomic analyses.

Major steps include:

-   processing and subsetting VCF genotype data;
-   handling genotype and sample identifiers;
-   matching genotyped accessions with phenotypic records;
-   generating dosage and haplotype matrices;
-   filtering markers;
-   constructing additive and dominance genomic relationship matrices;
    and
-   preparing genetic-map and recombination-frequency information used
    in genomic analyses.

**Key outputs include:**

data/dosages.rds
data/haplotypes.rds
output/kinship_add.rds
output/kinship_dom.rds
output/interpolated_genmap.rds
output/recombFreqMat_1minus2c.rds

Some genotype-processing steps use external command-line tools as
documented in the script.

------------------------------------------------------------------------

# Genome-Wide Association and Linkage Disequilibrium Analysis

## 8. Genome-Wide Association Analysis

**Script:** `analysis/ArchiGWAS.Rmd`

This script performs genome-wide association analyses for the plant
architecture and plant-shape traits.

Phenotypic BLUPs from the multiple-trial analyses are matched with
genotyped accessions and used as phenotypic response variables for GWAS.

The analyses are implemented in **GAPIT** using two complementary
models:

-   Mixed Linear Model (**MLM**)
-   Bayesian-information and Linkage-disequilibrium Iteratively Nested
    Keyway (**BLINK**)

The first three principal components are included to account for
population structure, and SNPs are filtered using a minor allele
frequency threshold of 0.01.

The script generates GWAS results and Manhattan and Q--Q plots for the
architecture and plant-shape traits.

------------------------------------------------------------------------

## 9. Linkage Disequilibrium Analysis

**Scripts:**

analysis/ArchiGWAS.Rmd
analysis/L decay code Jean_Luc.R


Pairwise linkage disequilibrium is calculated from the genotype data
using PLINK. The analysis evaluates SNP pairs separated by up to 1 Mb.

The LD-decay workflow calculates physical distances between marker
pairs, summarizes mean pairwise (r\^2) across distance bins, and
generates the genome-wide LD-decay figure.

The GWAS workflow also extracts pairwise LD among significant chromosome
2 markers associated with branching level number for supplementary
analysis.

------------------------------------------------------------------------

# Genomic Prediction

## 10. Genomic Prediction and Cross-Validation

**Script:** `analysis/genselect.Rmd`

This script evaluates genomic prediction accuracy for plant architecture
and plant-shape traits.

Phenotypic BLUPs are matched with the genomic relationship matrices, and
accessions with the required phenotypic and genotypic information are
retained for prediction.

Prediction accuracy is evaluated using repeated **five-fold
cross-validation**, with three repetitions and a fixed random seed for
reproducibility.

The final model comparison includes:

-   **Additive model (A)**
-   **Additive + dominance model (AD)**

Prediction accuracies are summarized across traits, and differences
among models and traits are evaluated statistically. The resulting
distributions of prediction accuracy are presented in the genomic
prediction figure.

**Key inputs include:**

output/blups.rds
data/dosages.rds
output/kinship_add.rds
output/kinship_dom.rds

**Key outputs include:**


output/A_KfoldsCval.rds
output/AD_KfoldsCval.rds
Result/Genomic_standardCV_Sum.csv
Result/Genomic_prediction.pdf


------------------------------------------------------------------------

# Logical Order of Scripts

The principal analysis workflow is:


1. data_building.Rmd
        ↓
2. data_curation.Rmd
        ↓
3. fieldtrialfilter.Rmd
        ↓
4. Archi_scale.Rmd
        ↓
5. Phenodata_analysis.Rmd
        ↓
6. VCFfilestreatment.Rmd
        ↓
7. generalanalysis.Rmd
        ↓
        ├──────────────────┐
        ↓                  ↓
8. ArchiGWAS.Rmd     10. genselect.Rmd
        ↓
9. LD-decay analysis


Once the required phenotypic BLUPs and genotype data have been
generated, GWAS/LD analysis and genomic prediction represent separate
downstream analyses.



# Software

The analyses were conducted primarily in **R**. Major R packages used
across the workflow include:

-   `tidyverse`
-   `data.table`
-   `lme4`
-   `sommer`
-   `genomicMateSelectR`
-   `GAPIT`
-   `FactoMineR`
-   `factoextra`
-   `corrplot`
-   `ggplot2`
-   `vcfR`

Additional genotype-processing and linkage-disequilibrium analyses use
command-line software including:

-   **PLINK**
-   **VCFtools**
-   **BCFtools**

Individual scripts contain the packages and functions required for their
respective analyses.


# Data

Phenotypic data were obtained from historical cassava breeding trials
conducted by the International Institute of Tropical Agriculture (IITA)
and the National Root Crops Research Institute (NRCRI) in Nigeria.

The analyses focus on plant architecture traits including plant height,
first branching height, branching level number, and plant-shape
categories, together with agronomic traits used to evaluate
relationships between architecture and cassava productivity.

Genotypic data were obtained from CassavaBase and processed for use in
population-structure, GWAS, linkage-disequilibrium, and
genomic-prediction analyses.

Large genotype files and other source datasets may not be stored
directly in this repository because of file-size and data-distribution
considerations. The analysis scripts document the intermediate files
required to reproduce the workflow.


# Reproducibility Notes

The scripts document the sequence of data preparation, quality control,
phenotypic analysis, genotype processing, GWAS, linkage-disequilibrium
analysis, and genomic prediction used in the study.

Intermediate R objects are saved throughout the workflow to allow
downstream analyses to be reproduced without repeating computationally
intensive upstream steps.

Where external command-line software or large genotype files are
required, the corresponding commands and expected input/output files are
documented in the relevant scripts.


# Citation

If you use this workflow, please cite the associated manuscript:

**Okoma et al.** *Genetic basis of cassava (Manihot esculenta Crantz)
plant architecture and its relevance for ideotype breeding.*
