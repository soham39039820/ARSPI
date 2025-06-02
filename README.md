# ARSPI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/soham39039820/ARSPI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soham39039820/ARSPI/actions/workflows/R-CMD-check.yaml)
[![R-CMD-check](https://github.com/soham39039820/ARSPI/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/soham39039820/ARSPI/actions)


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
- 🧩 **User-Specified Priors**: Allows users to define and use their own prior distributions in the JAGS model file.
---
## 🔧 Installing R2jags and JAGS
The ARSPI package relies on R2jags, which requires JAGS (Just Another Gibbs Sampler) to be installed on your system.
-  **Step 1: Install JAGS**
  - 📥 Download JAGS from the official website: https://mcmc-jags.sourceforge.io
  -  Select the version compatible with your operating system (Windows, macOS, or Linux) and follow the installation instructions.
  -  ✅ Make sure JAGS is added to your system PATH during installation so R can detect it.
-  **Step 2: Install R2jags in R**
```R
# Install R2jags
install.packages("R2jags")

# After installation, you can test if it’s working by loading the package:
library(R2jags)
```
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
### Example with Custom User-Specified Priors

You can specify your own priors without changing the model file. This allows for complete flexibility and transparency in the Bayesian inference process.
```R
# Define user-specified priors
user_priors <- list(
    df1_shape = 3, df1_rate = 0.3,               # Prior for variance of beta_1
    df2_shape = 3, df2_rate = 0.3,               # Prior for variance of rainfall (sigma^2)
    tau2beta_shape = 2.5, tau2beta_rate = 0.25,  # Prior for precision of beta_1
    nu1_rate = 0.15, nu2_rate = 0.15,            # Hyperpriors for inverse-gamma parameters
    phi_min = -0.95, phi_max = 0.95              # Bounds for AR(1) coefficient phi
)

# Run ARSPI estimation with custom priors
result <- arspi_estimate(
  rainfall = rainfall_series,
  scale = 6,
  model_file = model_file_path,
  df1_shape = user_priors$df1_shape,
  df1_rate = user_priors$df1_rate,
  df2_shape = user_priors$df2_shape,
  df2_rate = user_priors$df2_rate,
  tau2beta_shape = user_priors$tau2beta_shape,
  tau2beta_rate = user_priors$tau2beta_rate,
  nu1_rate = user_priors$nu1_rate,
  nu2_rate = user_priors$nu2_rate,
  phi_min = user_priors$phi_min,
  phi_max = user_priors$phi_max
)

# View results
cat("ARSPI values:\n")
print(result$ARSPI)

cat("Detailed Drought Characteristics:\n")
print(result$Drought_Analysis)

cat("Summary of Drought Events:\n")
print(result$Summary)

```
### Version

The current version of `beta4dist` is 0.1.1.

### DATA REQUIREMENTS

The input to the ARSPI model is a numeric vector of monthly rainfall values (e.g., from gauge data or satellite estimates).

The data should be continuous (no missing values). Pre-processing may be required to impute or remove gaps.

The model supports flexible aggregation periods (e.g., 3, 6, 12, or 24 months).


### LICENSE

This package is released under the MIT License. 

### References

For more information on the AutoRegressive Standardized Precipitation Index (ARSPI), please refer to the following publication:

- **Paper Title**: *ARSPI: An R Package for Calculating AutoRegressive Standardized Precipitation Index and Analyzing Drought Characteristics*
- **Authors**: Soham Ghosh and Sujay Mukhoti.


