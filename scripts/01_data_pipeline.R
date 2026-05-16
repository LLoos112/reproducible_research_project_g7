# Libraries
library(tidyverse)
library(caret)
library(corrplot)
library(DescTools)
library(recipes)
library(rsample)

# Read dataset
df <- read.csv("../dataset.csv")

head(df)

# Drop Customer_ID since it doesn't contain important information
df <- df %>% select(-Customer_ID)

dim(df)

head(df)

# Dataset basic description
summary(df)

# Check unique values of nominal variables
for(col in c("Location", "App_Usage_Frequency",
             "Preferred_Payment_Method", "Income_Level")) {
  
  cat("\n", col, ":\n")
  print(unique(df[[col]]))
}

# Check missing values
colSums(is.na(df))

# Check skewness of target variable
hist(df$LTV,
     breaks = 50,
     main = "Distribution of Customer Lifetime Value (LTV)",
     xlab = "Customer Lifetime Value (LTV)",
     ylab = "Frequency")

grid()

# The distribution of customer lifetime value is highly right-skewed, with most customers exhibiting low LTV and a small number of extreme high-value customers. This heavy-tailed structure introduces substantial noise and limits the achievable predictive performance. 
# Since the to be used methods can handle skewed data well, we will use not transform LTV, however, for MLP, it doesn't handle skewed data well, we will perform log transformation to compare the performance.

# Select numeric columns
num_df <- df %>%
  select(where(is.numeric))

# Pearson correlation matrix
pearson_corr <- cor(num_df,
                    method = "pearson",
                    use = "complete.obs")

# Correlation heatmap
corrplot(pearson_corr,
         method = "color",
         type = "upper",
         addCoef.col = "black",
         number.cex = 0.7)

title("Pearson Correlation Matrix (Numeric Variables)")

# Based on the correlation heatmap, we can clearly see that LTV and Total_Spent are having perfect correlation. And it is commonly used to measure the customer's LTV by using their Total_Spent in the finance industries, hence we will drop Total_Spent. 
# 
# For variables having over 0.7 correlation values, we will drop them as well. 
# 
# Even though Avg_Transaction_Value and LTV correlation value is only 0.66. It was observed that Avg_Transaction_Value is the result of Total_Spent divided by Total_Transaction. This would cause data leakage/redundant, hence we would remove Avg_Transaction_Value and keep the Total_Transactions.

# Drop selected variables
df <- df %>%
  select(-Max_Transaction_Value,
         -Min_Transaction_Value,
         -Avg_Transaction_Value,
         -Total_Spent)

# Recalculate correlations
num_df <- df %>%
  select(where(is.numeric))

pearson_corr <- cor(num_df,
                    method = "pearson",
                    use = "complete.obs")

# Correlation heatmap again
corrplot(pearson_corr,
         method = "color",
         type = "upper",
         addCoef.col = "black",
         number.cex = 0.7)

title("Pearson Correlation Matrix (Numeric Variables)")

# Correlation for nominal variables using Cramér's V

cat_cols <- c("Location",
              "App_Usage_Frequency",
              "Preferred_Payment_Method",
              "Income_Level")

# Empty matrix
cramers_v_matrix <- matrix(0,
                           nrow = length(cat_cols),
                           ncol = length(cat_cols))

rownames(cramers_v_matrix) <- cat_cols
colnames(cramers_v_matrix) <- cat_cols

# Calculate Cramér's V
for(i in 1:length(cat_cols)) {
  
  for(j in 1:length(cat_cols)) {
    
    cramers_v_matrix[i, j] <-
      CramerV(table(df[[cat_cols[i]]],
                    df[[cat_cols[j]]]))
  }
}

# Convert to dataframe
cramers_v_matrix <- as.data.frame(cramers_v_matrix)

print(cramers_v_matrix)

# Heatmap for Cramér's V
corrplot(as.matrix(cramers_v_matrix),
         method = "color",
         addCoef.col = "black",
         number.cex = 0.7)

title("Cramér's V Association Matrix (Nominal Variables)")

# Define target and time column
TARGET <- "LTV"
TIME_COL <- "Active_Days"

# Sort by pseudo-time
df <- df %>%
  arrange(.data[[TIME_COL]])

# Train/Validation/Test split
set.seed(42)

n <- nrow(df)

i1 <- floor(0.60 * n)
i2 <- floor(0.80 * n)

train_df <- df[1:i1, ]
val_df   <- df[(i1 + 1):i2, ]
test_df  <- df[(i2 + 1):n, ]

# Feature columns
feature_cols <- names(df)[names(df) != TARGET]

# Create X and y
X_train <- train_df[, feature_cols]
y_train <- train_df[, TARGET]

X_val <- val_df[, feature_cols]
y_val <- val_df[, TARGET]

X_test <- test_df[, feature_cols]
y_test <- test_df[, TARGET]

# Shapes
cat("Train shape:", dim(X_train), "\n")
cat("Validation shape:", dim(X_val), "\n")
cat("Test shape:", dim(X_test), "\n")

# Median Active_Days
cat("Active_Days medians:\n")

median(train_df[[TIME_COL]])
median(val_df[[TIME_COL]])
median(test_df[[TIME_COL]])

# Categorical columns
cat_cols <- c("Location",
              "App_Usage_Frequency",
              "Preferred_Payment_Method",
              "Income_Level")

# Numeric columns
num_cols <- setdiff(feature_cols, cat_cols)

# Recipe for preprocessing
rec <- recipe(LTV ~ ., data = train_df) %>%
  
  # Median imputation for numeric variables
  step_impute_median(all_numeric_predictors()) %>%
  
  # Most frequent imputation for categorical variables
  step_impute_mode(all_nominal_predictors()) %>%
  
  # One-hot encoding
  step_dummy(all_nominal_predictors(),
             one_hot = FALSE) %>%
  
  # Standardization
  step_normalize(all_numeric_predictors())

# Prepare recipe
prep_rec <- prep(rec, training = train_df)

# Apply preprocessing
X_train_processed <- bake(prep_rec, new_data = train_df)
X_val_processed   <- bake(prep_rec, new_data = val_df)
X_test_processed  <- bake(prep_rec, new_data = test_df)

# Check structures
dim(X_train_processed)
dim(X_val_processed)
dim(X_test_processed)

# Example encoded columns
colnames(X_train_processed)[1:15]

# Evaluation function
eval_reg <- function(y_true, y_pred) {
  
  mae <- MAE(y_pred, y_true)
  rmse <- RMSE(y_pred, y_true)
  r2 <- R2(y_pred, y_true)
  
  results <- data.frame(
    MAE = mae,
    RMSE = rmse,
    R2 = r2
  )
  
  return(results)
}

# Time-series cross validation
time_cv <- createTimeSlices(
  1:nrow(train_df),
  initialWindow = floor(0.7 * nrow(train_df)),
  horizon = floor(0.1 * nrow(train_df)),
  fixedWindow = TRUE
)
