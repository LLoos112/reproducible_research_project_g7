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

file.create("scripts/01_data_loading.R")
file.create("scripts/02_preprocessing.R")
file.create("scripts/03_eda_visualization.R")
file.create("scripts/04_random_forest.R")
file.create("scripts/05_xgboost.R")
file.create("scripts/06_adaboost.R")
file.create("scripts/07_mlp.R")
file.create("scripts/08_model_comparison.R")
file.create("scripts/09_final_report.R")

# =========================
# CREATE README
# =========================

readme_text <- "
# Reproducible Research Project - R Conversion

This project converts the original Python machine learning workflow into R.

## Project Structure

- data/raw/               : raw datasets
- data/processed/         : processed datasets
- scripts/                : R scripts
- outputs/                : model outputs/results
- figures/                : plots and visualizations

## Workflow Order

1. 01_data_loading.R
2. 02_preprocessing.R
3. 03_eda_visualization.R
4. 04_random_forest.R
5. 05_xgboost.R
6. 06_adaboost.R
7. 07_mlp.R
8. 08_model_comparison.R
9. 09_final_report.R

## Team Responsibilities

- Person 1: Data loading & preprocessing
- Person 2: EDA & visualization
- Person 3: Tree-based ML models
- Person 4: MLP, evaluation & reporting

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

