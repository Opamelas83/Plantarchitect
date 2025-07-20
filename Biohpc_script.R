# FROM Haplotype
vcfName<-"BreedBaseGenotypes_subset"
haps<-fread(paste0("data/VCF/",vcfName,".hap.gz"),
            stringsAsFactors = F,header = F) %>%
  as.data.frame
sampleids<-fread(paste0("data/VCF/",vcfName,".samples"),
                 stringsAsFactors = F,header = F,skip = 2) %>%
  as.data.frame


dosages <- readRDS("~/Desktop/Plantarchitect/data/dosages.rds")
Mydosages <- as_tibble(dosages, rownames = NA)
Mydosages <- rownames_to_column(Mydosages) %>% rename(germplasmName = rowname)
Access <- read_csv("data/Access_IITA_NRCRI.csv")#genotypes from NRCRI and IITA
Access1 <- Access %>% group_by(germplasmName, programName) %>%
  summarise(germplasmName = unique(germplasmName))
Access1 <- Access1 %>% mutate(NprogamName = length(unique(programName)))
Access1 <- Access1 %>% mutate(programName = ifelse(NprogamName == 1, programName, "both"))
Access2 <- Access1 %>% distinct() %>% dplyr::select(-NprogamName)
Mydosages_Pro <- inner_join(Mydosages, Access2)
#I will save my new dosage matrix by keeping only the genotypes from NRCRI and IITA
Mydosages_Pro <-

#For pca
Mydosages_Pc <- column_to_rownames(as.data.frame(Mydosages_Pro), var = "germplasmName")

PCA_dosage <- prcomp(dosages)
genoty <- rownames(dosages)
genoty <- colnames(genoty)
