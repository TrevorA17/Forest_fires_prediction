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

# Check for missing values
missing_values <- sum(is.na(forest_fire_data))

# Display summary of missing values
print(paste("Number of missing values:", missing_values))

# Summary of missing values by column
print(summary(is.na(forest_fire_data)))