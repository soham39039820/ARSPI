# ARSPI: A Tool for Estimating ARSPI and Drought Characteristics

**ARSPI** is an R package designed to estimate the AutoRegressive Standardized Precipitation Index (ARSPI) and analyze drought characteristics. It categorizes drought events into four levels: mild, moderate, severe, and extreme, based on the ARSPI values calculated from rainfall data.

## Features

- **Estimate ARSPI**: Calculate the ARSPI values using monthly rainfall data.
- **Drought Classification**: Classify drought events based on the ARSPI values, such as mild, moderate, severe, and extreme.
- **Drought Analysis**: Provide detailed statistics and visualizations of drought characteristics, including event duration and severity.

## Installation

You can install the development version of the **ARSPI** package from GitHub using the `devtools` package.

```R
# Install devtools if not already installed
install.packages("devtools")

# Install ARSPI package from GitHub
devtools::install_github("soham39039820/ARSPI")
