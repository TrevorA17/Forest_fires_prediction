# Load dataset
forest_fire_data <- read.csv("data/forest_fires.csv", colClasses = c(
  X = "numeric",
  Y = "numeric",
  month = "factor",
  day = "factor",
  FFMC = "numeric",
  DMC = "numeric",
  DC = "numeric",
  ISI = "numeric",
  temp = "numeric",
  RH = "numeric",
  wind = "numeric",
  rain = "numeric",
  area = "numeric"
))

# Display the structure of the dataset
str(forest_fire_data)

# View the first few rows of the dataset
head(forest_fire_data)

# View the dataset in a separate viewer window
View(forest_fire_data)

library(caret)

# Data Splitting
set.seed(123) # Set seed for reproducibility
train_index <- sample(1:nrow(forest_fire_data), 0.8 * nrow(forest_fire_data)) # 80% for training
train_data <- forest_fire_data[train_index, ]
test_data <- forest_fire_data[-train_index, ]

# Print the dimensions of the training and testing sets
print("Dimensions of Training Data:")
print(dim(train_data))
print("Dimensions of Testing Data:")
print(dim(test_data))

# Bootstrapping
bootstrap_samples <- lapply(1:1000, function(i) {
  bootstrap_index <- sample(1:nrow(forest_fire_data), replace = TRUE)
  bootstrap_data <- forest_fire_data[bootstrap_index, ]
})

# Calculate mean and median for each bootstrap sample
bootstrap_stats <- sapply(bootstrap_samples, function(sample_data) {
  mean_value <- mean(sample_data$area)
  median_value <- median(sample_data$area)
  return(c(mean_value, median_value))
})

# Calculate confidence intervals for mean and median
confidence_intervals <- t(sapply(bootstrap_stats, function(stat) {
  quantile(stat, c(0.025, 0.975))
}))

# Print confidence intervals
print("Confidence intervals for mean and median:")
print(confidence_intervals)

# Remove the "month" column from the dataset
forest_fire_data <- forest_fire_data[, !(names(forest_fire_data) %in% c("month", "day"))]

# Cross-validation with evaluation using MAD and RMSE after removing the "month" column
library(caret)
set.seed(123) # Set seed for reproducibility
folds <- createFolds(forest_fire_data$area, k = 10) # 10-fold cross-validation

# Placeholder for storing evaluation results
evaluation_results <- list()

for (fold in 1:length(folds)) {
  train_index <- unlist(folds[-fold])
  test_index <- unlist(folds[fold])
  train_data <- forest_fire_data[train_index, ]
  test_data <- forest_fire_data[test_index, ]
  
  # Perform model training (replace this with your model training code)
  model <- lm(area ~ ., data = train_data)
  
  # Make predictions
  predictions <- predict(model, newdata = test_data)
  
  # Evaluate model performance
  MAD <- mean(abs(test_data$area - predictions))
  RMSE <- sqrt(mean((test_data$area - predictions)^2))
  
  # Store evaluation results
  evaluation_results[[paste("Fold", fold)]] <- c(MAD = MAD, RMSE = RMSE)
}

# Load required libraries
library(caret)
library(xgboost)

# Define training control
ctrl <- trainControl(method = "cv",  # Use cross-validation
                     number = 10)    # Number of folds

# Define models
models <- c("lm", "glm", "xgbLinear")

# Train and evaluate each model
results <- lapply(models, function(model) {
  set.seed(123)  # Set seed for reproducibility
  
  # Define formula for regression
  formula <- as.formula(paste("area ~ ."))
  
  # Train model
  if (model == "xgbLinear") {
    # For xgbLinear, convert data to DMatrix format
    dtrain <- xgb.DMatrix(data = as.matrix(forest_fire_data[, -which(names(forest_fire_data) == "area")]), label = forest_fire_data$area)
    fit <- xgboost(data = dtrain, objective = "reg:linear", booster = "gblinear", nrounds = 10, verbose = FALSE)
  } else {
    fit <- train(formula, 
                 data = forest_fire_data, 
                 method = model,
                 trControl = ctrl)
  }
  
  # Make predictions
  if (model == "xgbLinear") {
    predictions <- predict(fit, newdata = as.matrix(forest_fire_data[, -which(names(forest_fire_data) == "area")]))
  } else {
    predictions <- predict(fit, newdata = forest_fire_data)
  }
  
  # Compute evaluation metrics (e.g., RMSE, MAD)
  accuracy <- sqrt(mean((forest_fire_data$area - predictions)^2))
  mad <- mean(abs(forest_fire_data$area - predictions))
  
  # Return model and evaluation metrics
  return(list(model = model, RMSE = accuracy, MAD = mad))
})

# Print results
print("Model performance:")
print(do.call(rbind, results))


# Print evaluation results
print("Evaluation results for each fold:")
print(do.call(rbind, evaluation_results))
