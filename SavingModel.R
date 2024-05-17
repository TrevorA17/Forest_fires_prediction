# Load required libraries
library(caret)
library(xgboost)

# Define training control
ctrl <- trainControl(method = "cv",  # Use cross-validation
                     number = 10)    # Number of folds

# Train the xgbLinear model
set.seed(123)  # Set seed for reproducibility
dtrain <- xgb.DMatrix(data = as.matrix(forest_fire_data[, -which(names(forest_fire_data) == "area")]), label = forest_fire_data$area)
xgb_linear_model <- xgboost(data = dtrain, objective = "reg:linear", booster = "gblinear", nrounds = 10, verbose = FALSE)

# Create a directory named "models" if it doesn't exist
if (!file.exists("./models")) {
  dir.create("./models")
}

# Saving the xgbLinear model for the forest fire dataset
saveRDS(xgb_linear_model, file = "./models/forest_fire_xgb_linear_model.rds")

# Load the saved xgbLinear model
loaded_forest_fire_xgb_linear_model <- readRDS("./models/forest_fire_xgb_linear_model.rds")

# Prepare new data for prediction (replace with your actual new data)
new_forest_fire_data <- data.frame(
  X = c(7, 7, 7),  # Example X values
  Y = c(5, 4, 4),  # Example Y values
  month = c("mar", "oct", "oct"),  # Example month values
  day = c("fri", "tue", "sat"),  # Example day values
  FFMC = c(86.2, 90.6, 90.6),  # Example FFMC values
  DMC = c(26.2, 35.4, 43.7),  # Example DMC values
  DC = c(94.3, 669.1, 686.9),  # Example DC values
  ISI = c(5.1, 6.7, 6.7),  # Example ISI values
  temp = c(8.2, 18, 14.6),  # Example temp values
  RH = c(51, 33, 33),  # Example RH values
  wind = c(6.7, 0.9, 1.3),  # Example wind values
  rain = c(0, 0, 0)  # Example rain values
)

# Convert new data to matrix
new_data_matrix <- as.matrix(new_forest_fire_data[, -which(names(new_forest_fire_data) %in% c("month", "day"))])

# Use the loaded model to make predictions for new forest fire data
predictions_xgb_loaded_model <- predict(loaded_forest_fire_xgb_linear_model, newdata = xgb.DMatrix(new_data_matrix))

# Print predictions
print(predictions_xgb_loaded_model)
