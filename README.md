# Cassava Plant Architecture Analysis

This repository contains the analysis workflow associated with the study:

**“Genetic basis of Cassava (*Manihot esculenta* Crantz) plant architecture and its relevance for selection of farmer-preferred varieties.”**

The study uses historical multi-environment field-trial data from cassava breeding programs in Nigeria to characterize variation in plant architecture, evaluate relationships between plant architecture and agronomic traits, identify genomic regions associated with architecture traits, and assess the potential of genomic prediction for these traits.

## Overview of the Analysis

The workflow consists of four main components:

1. **Phenotypic data preparation and trial quality control**
2. **Multi-environment phenotypic analysis**
3. **Genotype processing, population structure, and genome-wide association analysis**
4. **Genomic prediction**

The principal scripts are located in the `analysis/` directory. They should be followed in the order described below.

---

## Repository Structure

```text
Plantarchitect/
├── analysis/     # Main R Markdown analysis scripts
├── code/         # Supporting R code and functions
├── data/         # Phenotypic, genotypic, and intermediate input data
├── Result/       # Tables and analysis results
├── output/       # Intermediate R objects, matrices, and figures
├── docs/         # workflowr-generated website files
└── README.md     # Repository documentation
```

---

# Analysis Workflow

## 1. Build the Initial Phenotypic Dataset

**Script:** `analysis/data_building.Rmd`

This script imports and integrates phenotypic and trial metadata, evaluates trait availability across trials, selects the traits used in the study, harmonizes trait names and measurement units, derives the plant-shape variables used in subsequent analyses, and generates the initial working phenotypic dataset.

**Main output:**

```text
data/MyArchidata.csv
```

---

## 2. Curate Experimental-Design Information

**Script:** `analysis/data_curation.Rmd`

This script checks and harmonizes experimental-design information, distinguishes replicated and non-replicated trials, creates nested trial-design variables, filters unsuitable observations and trial designs, and generates the curated phenotypic dataset used in subsequent analyses.

**Main output:**

```text
data/MyArchiphenotypes.csv
```

---

## 3. Single-Trial Quality Control

**Script:** `analysis/fieldtrialfilter.Rmd`

This script performs single-trial quality control for replicated and non-replicated trials using mixed models.

For each trait-by-trial combination, the analysis estimates genetic variance, residual variance, broad-sense heritability, coefficient of variation, and experimental accuracy. Trial-trait combinations are filtered based on genetic signal and experimental accuracy, and observations with absolute studentized residuals greater than 3 are removed.

The resulting dataset provides the quality-controlled quantitative phenotypes used in subsequent analyses.

**Main output:**

```text
data/MyArchiphenos_final.csv
```

---

## 4. Plant-Shape Trait Processing

**Script:** `analysis/Archi_scale.Rmd`

This script processes the four plant-shape categories:

* Cylindrical
* Umbrella
* Open
* Compact

The script summarizes the distribution of plant shapes across breeding stages, fits trial-level binomial mixed models, estimates genetic parameters and experimental accuracy, filters plant-shape trait-by-trial combinations, and generates the quality-controlled plant-shape dataset.

**Main output:**

```text
data/Shapephenos_filtered.csv
```

---

## 5. Multi-Environment Phenotypic Analysis

**Script:** `analysis/Phenodata_analysis.Rmd`

This script performs the main phenotypic analyses using the quality-controlled trial datasets.

The analyses include:

* summaries of trait distributions across breeding programs and breeding stages;
* comparisons among breeding stages;
* multi-environment mixed-model analyses;
* estimation of variance components and accession effects;
* calculation of BLUPs and deregressed BLUPs;
* correlations among plant architecture, plant-shape, and agronomic traits; and
* preparation of phenotypic inputs for subsequent genomic analyses.

The combined BLUP information is saved for downstream GWAS and genomic prediction.

**Key outputs include:**

```text
Result/GeneralMML_result.rds
Result/results_Shape.rds
output/blups_Archi.rds
output/blups_shape.rds
output/blups.rds
```

---

# Genomic Analysis

## 6. Genotype and VCF Processing

**Script:** `analysis/VCFfilestreatment.Rmd`

This script processes the genotype data used in the genomic analyses.

The major steps include:

* handling duplicate sample identifiers;
* combining and subsetting VCF genotype data;
* matching genotyped accessions with accessions having phenotypic information;
* converting genotype information into haplotype and dosage matrices;
* filtering markers based on minor allele frequency;
* constructing genomic relationship matrices; and
* preparing genetic-map and recombination-frequency information for downstream analyses.

**Key outputs include:**

```text
data/dosages.rds
data/haplotypes.rds
output/kinship_add.rds
output/kinship_dom.rds
output/interpolated_genmap.rds
output/recombFreqMat_1minus2c.rds
```

Some VCF-processing steps are performed using command-line tools including `bcftools`, `vcftools`, and PLINK, as documented in the script.

---

## 7. Dataset Summary and Population Structure

**Script:** `analysis/generalanalysis.Rmd`

This script generates summary statistics and tables used in the manuscript and evaluates population structure using principal component analysis (PCA) of the genotype dosage matrix.

The script summarizes the phenotypic dataset by trait, breeding program, experimental design, year, and location. PCA is used to characterize genetic structure among genotyped accessions and to generate principal-component information used in the genome-wide association analyses.

**Key outputs include:**

```text
Result/MySummaryData.csv
Result/MySummaryShapeDataS.csv
output/wholepca_result.rds
Result/pca_result.rds
Result/pca_ind.rds
Result/pca_ind_dim12.csv
```

---

# Genome-Wide Association Analysis

## 8. GWAS

**Script:** `analysis/ArchiGWAS.Rmd`

This script performs genome-wide association analyses for plant architecture and plant-shape traits.

Deregressed BLUPs from the multi-environment analyses are matched with the corresponding genotyped accessions. Genotype, kinship, and population-structure information are then incorporated into the GWAS workflow.

The primary GWAS analyses reported in the study are implemented in **GAPIT** using:

* Mixed Linear Model (**MLM**)
* Bayesian-information and Linkage-disequilibrium Iteratively Nested Keyway (**BLINK**)

Principal components are included to account for population structure, and marker filtering is applied based on minor allele frequency.

The script also contains the commands used to calculate pairwise linkage disequilibrium with PLINK.

---

## 9. Linkage Disequilibrium Decay

**Script:** `analysis/L decay code Jean_Luc.R`

This script generates the linkage-disequilibrium decay figure from PLINK pairwise LD output.

It calculates physical distances between marker pairs, summarizes mean \(r^2\) across log-spaced distance bins, and displays the distribution of pairwise LD together with the binned mean LD-decay curve.

The resulting figure is used to visualize the relationship between linkage disequilibrium and physical distance between markers.

---

# Genomic Prediction

## 10. Genomic Prediction and Cross-Validation

**Script:** `analysis/genselect.Rmd`

This script evaluates genomic prediction for plant architecture and plant-shape traits.

Phenotypic BLUPs are matched with the genotype data, and only accessions having both phenotypic and genotypic information are retained.

Prediction accuracy is evaluated using repeated five-fold cross-validation. The analyses compare genomic prediction models incorporating:

* additive genomic effects; and
* additive plus dominance genomic effects.

Prediction accuracies are summarized and compared across plant architecture and plant-shape traits.

**Key inputs include:**

```text
output/blups.rds
data/dosages.rds
output/kinship_add.rds
output/kinship_dom.rds
```

---

# Logical Order of Scripts

For reproducibility, the main analysis scripts should be followed in the following order:

```text
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
        ├───────────────┐
        ↓               ↓
8. ArchiGWAS.Rmd    10. genselect.Rmd
        ↓
9. L decay code Jean_Luc.R
```

GWAS/LD analysis and genomic prediction represent downstream genomic analyses and can be conducted independently once the required phenotypic and genotypic inputs have been generated.

---

# Software

The analyses were conducted primarily in **R**. Major R packages used across the workflow include:

* `tidyverse`
* `data.table`
* `lme4`
* `sommer`
* `genomicMateSelectR`
* `GAPIT`
* `FactoMineR`
* `factoextra`
* `corrplot`
* `ggplot2`
* `vcfR`

Additional genotype-processing and linkage-disequilibrium analyses use:

* **PLINK**
* **VCFtools**
* **BCFtools**

Individual scripts provide additional information on the packages and functions used for each analysis.

---

# Data

Phenotypic data were obtained from historical cassava breeding trials conducted by the International Institute of Tropical Agriculture (IITA) and the National Root Crops Research Institute (NRCRI) in Nigeria.

The analyses focus on plant architecture traits including plant height, first branching height, number of branching levels, and plant-shape categories, together with agronomic traits used to evaluate their relationships with cassava productivity.

Genotype data were processed from VCF files and matched to accessions with phenotypic information before GWAS and genomic prediction.

Large genotype files and other source datasets may not be stored directly in this GitHub repository because of file-size and data-distribution considerations. The scripts identify the intermediate files required for the analyses.

---

# Reproducibility Notes

The repository contains both the principal analyses reported in the manuscript and some exploratory code developed during the analysis process. The workflow described above identifies the scripts and analyses required to reproduce the principal results reported in the study.

Where external command-line software or large genotype files are required, the corresponding commands and expected input/output files are documented within the relevant analysis scripts.

---

# Citation

If you use this workflow, please cite the associated manuscript:

**Okoma et al.** *Genetic basis of Cassava (Manihot esculenta Crantz) plant architecture and its relevance for selection of farmer-preferred varieties.*

