#!/usr/bin/env Rscript

# Enhanced Clinical Context Example - Gold Standard
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)

cat("=== ENHANCED CLINICAL CONTEXT ANALYSIS ===\n\n")

# Even more comprehensive footnotes for clinical research
enhanced_clinical_footnotes <- list(
  variables = list(
    len = "Primary endpoint: Odontoblast length (microns) measured at day 60 using standardized histomorphometric analysis with inter-observer agreement >95%",
    dose = "Vitamin C dosing regimen: 0.5, 1.0, or 2.0 mg/day administered via oral gavage in divided doses (BID schedule) over 60-day treatment period"
  ),
  columns = list(
    VC = "Ascorbic acid (USP grade, >99% purity) dissolved in sterile saline, administered as vitamin C supplement",
    OJ = "Fresh orange juice (Valencia variety, standardized vitamin C content) as natural bioavailable source"
  ),
  general = c(
    "Randomized controlled trial design (Crampton, 1947) with n=10 per treatment group",
    "Primary analysis by intention-to-treat principle using Welch's two-sample t-test",
    "Statistical significance threshold: alpha = 0.05 (two-tailed)",
    "All histological measurements performed by trained technicians blinded to treatment assignment",
    "Study protocol approved by institutional animal care committee",
    "No subjects lost to follow-up; complete case analysis performed"
  )
)

# Create the enhanced clinical table
bp <- table1(
  supp ~ len + dose,
  data = ToothGrowth,
  theme = "nejm", 
  pvalue = TRUE,
  totals = TRUE,
  footnotes = enhanced_clinical_footnotes
)

# Display the table
output <- display_table(bp, ToothGrowth, theme = "nejm")
cat("ENHANCED CLINICAL RESEARCH TABLE:\n")
cat("=================================\n")
cat(output, "\n\n")

# Also show HTML version
html_output <- render_html(bp, get_theme("nejm"))
cat("HTML VERSION (first 800 characters):\n")
cat("====================================\n")
cat(substr(html_output, 1, 800), "\n...\n\n")

# Demonstrate different clinical contexts
cat("ALTERNATIVE CLINICAL CONTEXTS:\n")
cat("==============================\n\n")

# Example 1: Dose-escalation study context
dose_escalation_footnotes <- list(
  variables = list(
    len = "Efficacy endpoint: Change from baseline in tooth length (microns)",
    dose = "Dose-escalation cohorts following 3+3 design with safety run-in"
  ),
  general = c(
    "Phase I dose-escalation study with sequential cohort enrollment",
    "Maximum tolerated dose determination using CTCAE v5.0 criteria", 
    "Efficacy analysis in evaluable population (n=60)",
    "Statistical analysis using linear mixed-effects models"
  )
)

cat("1. DOSE-ESCALATION STUDY CONTEXT:\n")
bp_dose <- table1(
  dose ~ len + supp,
  data = ToothGrowth,
  theme = "nejm",
  pvalue = TRUE,
  footnotes = dose_escalation_footnotes
)
output_dose <- display_table(bp_dose, ToothGrowth, theme = "nejm")
cat(output_dose, "\n\n")

# Example 2: Bioequivalence study context  
bioequiv_footnotes <- list(
  variables = list(
    len = "Primary pharmacodynamic endpoint: Area under the growth curve (AUC) for tooth length"
  ),
  columns = list(
    VC = "Test formulation: Synthetic ascorbic acid tablet (Test)",
    OJ = "Reference formulation: Natural orange juice concentrate (Reference)"
  ),
  general = c(
    "Randomized crossover bioequivalence study with 14-day washout",
    "Bioequivalence criteria: 90% CI for geometric mean ratio within 80-125%",
    "Sample size calculation based on intra-subject CV of 20%",
    "Non-parametric analysis using Wilcoxon signed-rank test"
  )
)

cat("2. BIOEQUIVALENCE STUDY CONTEXT:\n")
bp_bioeq <- table1(
  supp ~ len,
  data = ToothGrowth,
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE,
  footnotes = bioequiv_footnotes
)
output_bioeq <- display_table(bp_bioeq, ToothGrowth, theme = "jama")
cat(output_bioeq, "\n\n")

cat("KEY CLINICAL RESEARCH ELEMENTS DEMONSTRATED:\n")
cat("============================================\n")
cat("✓ Primary/secondary endpoint definitions\n")
cat("✓ Statistical analysis plan specification\n") 
cat("✓ Study design and randomization details\n")
cat("✓ Sample size and power considerations\n")
cat("✓ Quality control and blinding procedures\n")
cat("✓ Regulatory compliance references\n")
cat("✓ Data analysis population definitions\n")
cat("✓ Multiple clinical trial contexts (RCT, dose-escalation, bioequivalence)\n")