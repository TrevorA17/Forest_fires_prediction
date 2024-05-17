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

# Print evaluation results
print("Evaluation results for each fold:")
print(do.call(rbind, evaluation_results))
