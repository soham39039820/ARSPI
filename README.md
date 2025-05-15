# ARSPI: A Tool for Estimating ARSPI and Drought Characteristics

**ARSPI** is an R package designed to estimate the AutoRegressive Standardized Precipitation Index (ARSPI) and analyze drought characteristics. It categorizes drought events into four levels: mild, moderate, severe, and extreme, based on the ARSPI values calculated from rainfall data.

## Features

- **Calculate ARSPI**: Calculate the ARSPI values using monthly rainfall data.
- **Drought Classification**: Classify drought events based on the ARSPI values, such as mild, moderate, severe, and extreme.
- **Drought Analysis**: Provide detailed statistics and visualizations of drought characteristics, including event duration and severity.

## Installation

You can install the development version of the **ARSPI** package from GitHub using the `devtools` package.

```R
# Install devtools if not already installed
install.packages("devtools")

# Install ARSPI package from GitHub
devtools::install_github("soham39039820/ARSPI")
```
## Usage

After installing the **ARSPI** package, you can use it to estimate the ARSPI and analyze drought characteristics as follows:

### Example Usage

```R
# Load the ARSPI package
library(ARSPI)

# Example rainfall data (monthly rainfall in mm)
rainfall_data <- c(100, 120, 110, 95, 130, 140, 160, 180, 150, 130, 110, 100)

# Estimate ARSPI values
arspi_values <- arspi_estimate(rainfall_data)

# View ARSPI values
print(arspi_values)
```

# Classify drought events
drought_classification <- classify_drought(arspi_values)

# View drought classification
print(drought_classification)

