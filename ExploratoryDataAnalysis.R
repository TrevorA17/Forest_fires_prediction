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

# Measures of Frequency
# Frequency of occurrences for month
month_freq <- table(forest_fire_data$month)
print("Frequency of occurrences for month:")
print(month_freq)

# Frequency of occurrences for day
day_freq <- table(forest_fire_data$day)
print("Frequency of occurrences for day:")
print(day_freq)
