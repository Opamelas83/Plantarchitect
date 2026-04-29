## ============================================================
## LD DECAY PLOT (HEXBIN + BINNED MEAN LINE) — FULL SCRIPT
## Input: PLINK pairwise LD output (.ld or .ld.gz)
## Output: Publication-ready LD decay plot (PDF + PNG)
## Notes:
##  - Keeps ALL data for computation
##  - Uses coord_cartesian() to "cap" displayed distance (no data deletion)
##  - Uses log10 distance axis (common for LD decay)
## ============================================================

## ---- 0) Packages ----
pkgs <- c("data.table", "dplyr", "ggplot2", "hexbin")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages(to_install)

library(data.table)
library(dplyr)
library(ggplot2)
library(hexbin)

## ---- 1) File paths ----
# Change this to your LD file name
ld_file <- "/Volumes/OKM/PINK_DELL/BreedBaseGenotypesD_LD.ld"  # or "BreedBaseGenotypesD_LD.ld.gz"

## ---- 2) Read LD file ----
# PLINK --r2 output typically includes columns:
# CHR_A BP_A SNP_A CHR_B BP_B SNP_B R2
ld_df <- fread(ld_file)


# ---- 2) Compute distance ----
ld_df <- ld_df %>%
  mutate(
    dist_bp = abs(BP_B - BP_A),
    r2 = R2
  ) %>%
  filter(dist_bp > 0, !is.na(r2), r2 >= 0, r2 <= 1)

# Optional: restrict to within 10 Mb or whatever window you used
# ld_df <- ld_df %>% filter(dist_bp <= 1e7)

# ---- 3) Bin distances (log-spaced bins are ideal for LD decay) ----
# Choose log-spaced breaks covering your observed distances
min_d <- max(min(ld_df$dist_bp, na.rm = TRUE), 1)    # avoid 0
max_d <- max(ld_df$dist_bp, na.rm = TRUE)

breaks <- unique(floor(10^seq(log10(min_d), log10(max_d), by = 0.05)))

ld_binned <- ld_df %>%
  mutate(dist_bin = cut(dist_bp, breaks = breaks, include.lowest = TRUE)) %>%
  group_by(dist_bin) %>%
  summarise(
    dist_mid = mean(dist_bp, na.rm = TRUE),
    r2_mean  = mean(r2, na.rm = TRUE),
    n_pairs  = dplyr::n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(dist_mid), !is.na(r2_mean))
## ---- 6) Choose display limits WITHOUT deleting data ----
# This is the key difference: coord_cartesian() zooms the plot only.
x_min <- 1e2   # 100 bp
x_max <- 1e7   # 10 Mb
## ---- 7) Plot: hexbin density + binned mean line ----
p <- ggplot(ld_df, aes(x = dist_bp, y = r2)) +
  geom_hex(bins = 60) +
  geom_line(data = ld_binned, aes(x = dist_mid, y = r2_mean), color = "red",
            linewidth = 1) +
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(limits = c(0, 1)) +
  coord_cartesian(xlim = c(x_min, x_max)) +
  labs(
    x = "Inter-marker distance (bp, log10 scale)",
    y = expression(r^2)
  ) +
  theme_classic()

print(p)

## ---- 8) Save outputs ----
ggsave("LD_decay_hexbin_binnedMean.pdf", p, width = 7, height = 5)
ggsave("LD_decay_hexbin_binnedMean.png", p, width = 7, height = 5, dpi = 300)