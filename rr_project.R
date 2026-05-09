install.packages("gert")
library(gert)

git_clone(
  url = "https://github.com/LLoos112/reproducible_research_project_g7.git",
  path = "Downloads/reproducible_research_project_g7_weidong"
)

# =========================
# CREATE PROJECT STRUCTURE
# =========================

# Create folders
dir.create("data", showWarnings = FALSE)
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

dir.create("scripts", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# =========================
# CREATE SCRIPT FILES
# =========================

file.create("scripts/01_data_pipeline.R")
file.create("scripts/02_tree_models.R")
file.create("scripts/03_boosting_nn_models.R")
file.create("scripts/04_model_comparison.R")
file.create("scripts/05_final_report.R")

# =========================
# CREATE README
# =========================

readme_text <- "
# Reproducible Research Project - R Conversion

This project converts the original Python machine learning workflow into R.

## Project Structure

- data/raw/               : raw datasets
- data/processed/         : processed datasets
- figures/                : plots and visualizations
- scripts/                : R scripts
- outputs/                : model outputs/results

## Workflow Order

1. 01_data_pipeline.R
2. 02_tree_models.R
3. 03_boosting_nn_models.R
4. 04_model_comparison.R
5. 05_final_report.R

## Team Responsibilities

- Marta: Data preprocessing, EDA and visualization
- Anna: Tree-based ML models
- Weidong: Boosting and MLP models
- Zuzia: Model comparison

"

writeLines(readme_text, "README.md")

# =========================
# CREATE .gitignore
# =========================

gitignore_text <- "
.Rhistory
.RData
.Rproj.user
*.Rproj
.DS_Store
"

writeLines(gitignore_text, ".gitignore")

# =========================
# DONE
# =========================

cat('Project structure created successfully!')




system("git add .")

system('git commit -m "Created R project structure and workflow scripts"')

system("git push")

