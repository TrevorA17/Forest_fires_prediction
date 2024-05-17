# Load necessary libraries
library(plumber)

# Load the saved xgbLinear model for forest fire area prediction
loaded_forest_fire_xgb_linear_model <- readRDS("./models/forest_fire_xgb_linear_model.rds")

#* @apiTitle Forest Fire Area Prediction Model API
#* @apiDescription Used to predict the area affected by forest fires.

#* @post /predict_forest_fire_area
#* @param X Numeric: X coordinate
#* @param Y Numeric: Y coordinate
#* @param FFMC Numeric: Fine Fuel Moisture Code
#* @param DMC Numeric: Duff Moisture Code
#* @param DC Numeric: Drought Code
#* @param ISI Numeric: Initial Spread Index
#* @param temp Numeric: Temperature
#* @param RH Numeric: Relative Humidity
#* @param wind Numeric: Wind speed
#* @param rain Numeric: Rainfall
predict_forest_fire_area <- function(X, Y, FFMC, DMC, DC, ISI, temp, RH, wind, rain) {
  # Create a data frame using the arguments
  new_forest_fire_data <- data.frame(
    X = as.numeric(X),
    Y = as.numeric(Y),
    FFMC = as.numeric(FFMC),
    DMC = as.numeric(DMC),
    DC = as.numeric(DC),
    ISI = as.numeric(ISI),
    temp = as.numeric(temp),
    RH = as.numeric(RH),
    wind = as.numeric(wind),
    rain = as.numeric(rain)
  )
  
  # Convert data to matrix
  new_forest_fire_data_matrix <- as.matrix(new_forest_fire_data)
  
  # Use the loaded model to make predictions
  prediction <- predict(loaded_forest_fire_xgb_linear_model, newdata = new_forest_fire_data_matrix)
  
  # Apply inverse of ln(x+1) transform
  prediction <- exp(prediction) - 1
  
  # Return the prediction
  return(as.character(prediction))
}
