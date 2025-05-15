# ARSPI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**ARSPI** is an R package developed to compute the AutoRegressive Standardized Precipitation Index (ARSPI) using a Bayesian hierarchical model and analyze drought characteristics. The package allows users to evaluate drought events at various time scales, providing a comprehensive framework for understanding the frequency, intensity, and duration of droughts.

## 🔍 Overview

The ARSPI enhances the traditional SPI by introducing an autoregressive component to account for temporal dependence in precipitation data. This approach improves the accuracy and interpretability of drought analysis, especially for regions where climatic persistence plays a significant role.

The package offers a full pipeline for:

- Estimating ARSPI values from monthly rainfall data.
- Classifying drought conditions into **mild**, **moderate**, **severe**, and **extreme**.
- Generating detailed statistics and summaries of drought characteristics.
- Supporting flexible time scales (e.g., 3-month, 6-month, 12-month analysis).

---

## ✨ Features

- 📈 **ARSPI Computation**: Bayesian estimation of ARSPI using MCMC via `R2jags`.
- 🏜️ **Drought Classification**: Automatic categorization of drought events by severity.
- 📊 **Drought Analysis Tools**: Outputs include:
  - Event-wise drought duration, severity, and frequency.
  - Summary statistics across different drought categories.
  - Outputs formatted for easy plotting and interpretation.

---

## 📦 Installation

To install the development version of **ARSPI** from GitHub, use the following commands in R:

```R
# Install devtools if not already installed
install.packages("devtools")

# Install ARSPI from GitHub
devtools::install_github("soham39039820/ARSPI")
```

## Usage

After installation, you can load the package and run an example ARSPI analysis:

### Example Usage

```R
# Load the ARSPI package
library(ARSPI)

# Load sample rainfall data provided with the package
csv_path <- system.file("extdata", "rainfall_sample_data.csv", package = "ARSPI")
rainfall_data <- read.csv(csv_path, header = TRUE)

# Extract rainfall time series (e.g., 360 monthly values)
rainfall_series <- rainfall_data[, 2]

# Specify the path to the JAGS model file
model_file_path <- system.file("SPIAR1_HBpt.txt", package = "ARSPI")

# Estimate ARSPI and analyze drought characteristics
result <- arspi_estimate(
  rainfall = rainfall_series,
  scale = 6,
  model_file = model_file_path
)

# Display ARSPI values
cat("ARSPI values:\n")
print(result$ARSPI)

# Display drought characteristics for each category
cat("Detailed Drought Characteristics:\n")
print(result$Drought_Analysis)

# Display summary of drought events
cat("Summary of Drought Events:\n")
print(result$Summary)
```

### Version

The current version of `beta4dist` is 0.1.0.

### DATA REQUIREMENTS

The input to the ARSPI model is a numeric vector of monthly rainfall values (e.g., from gauge data or satellite estimates).

The data should be continuous (no missing values). Pre-processing may be required to impute or remove gaps.

The model supports flexible aggregation periods (e.g., 3, 6, 12, or 24 months).


### LICENSE

This package is released under the MIT License. 

### References

For more information on the four-parameter Beta distribution and its applications, please refer to the following publication:

- **Paper Title**: *ARSPI: An R Package for Calculating AutoRegressive Standardized Precipitation Index and Analyzing Drought Characteristics*
- **Authors**: Soham Ghosh and Sujay Mukhoti.


