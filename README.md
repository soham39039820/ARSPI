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

# Load sample rainfall data included with the package
rainfall_url<-"https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/extdata/rainfall_sample_data.csv"
model_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/SPIAR1_HBpt.txt"
# Download rainfall data
rainfall_data <- tryCatch(
    read.csv(rainfall_url, header = TRUE),
    error = function(e) stop("Failed to load rainfall data from GitHub.")
)
if (nrow(rainfall_data) < 360) stop("Insufficient data length.")
rainfall_series <- rainfall_data[1:360, 2]

# Download JAGS model file to a temporary location
model_file_path <- tempfile(fileext = ".txt")
download.file(model_url, destfile = model_file_path, quiet = TRUE)

# Run ARSPI model
result <- computeARSPI(
    rainfall = rainfall_series,
    scale = 6,
    model_file = model_file_path,
    n.burnin = 1000,
    n.iter = 10000,
    n.thin = 2,
    n.chains = 3,
    use_parallel = TRUE
)
# Extract ARSPI index
print(result$arspi)
# Display JAGS output
print(result$BUGSoutput)
# Summary statistics of all parameters
summary(result$BUGSoutput$summary)
#Plot trace plots and posterior densities for parameters
plot(result$BUGSoutput)
#Access PSRF (Gelman-Rubin diagnostics)
psrf_values <- result$BUGSoutput$summary[, "Rhat"]
print(psrf_values)
# Optionally, identify parameters with poor convergence (Rhat > 1.1)
non_converged_params <- names(psrf_values[psrf_values > 1.1])
if (length(non_converged_params) > 0) {
 message("Parameters with potential convergence issues: ", paste(non_converged_params, collapse = ", "))
} else {
 message("All parameters have converged (Rhat <= 1.1)")
}
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
result <- computeARSPI(
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
print(result$arspi)
```
### Version

The current version of `ARSPI` is 0.1.4.

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


