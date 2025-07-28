test_compute_IDCM <- function() {
  # Load required packages
  if (!requireNamespace("SPEI", quietly = TRUE)) install.packages("SPEI")
  library(SPEI)
  
  # Download sample rainfall data
  file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/extdata/rainfall_sample_data.csv"
  rainfall_data <- tryCatch(
    read.csv(file_url, header = TRUE),
    error = function(e) stop("Failed to load rainfall data from GitHub.")
  )
  
  if (nrow(rainfall_data) < 360) stop("Insufficient data length for test.")
  rainfall_series <- rainfall_data[1:360, 2]  # Use first 360 months
  
  # Download ARSPI model file
  model_file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/SPIAR1_HBpt.txt"
  model_file_path <- tempfile(fileext = ".txt")
  download.file(model_file_url, destfile = model_file_path, quiet = TRUE)
  
  # Run ARSPI computation
  arspi_result <- computeARSPI(
    rainfall = rainfall_series,
    scale = 6,
    model_file = model_file_path,
    n.burnin = 1000,
    n.iter = 10000,
    n.thin = 2,
    n.chains = 3,
    use_parallel = TRUE
  )
  
  arspi_values <- arspi_result$arspi
  
  # Compute SPI using SPEI package
  spi_obj <- spi(rainfall_series, scale = 6)
  spi_values <- as.numeric(spi_obj$fitted)
  
  # Trim NA values from the beginning due to scale
  valid_idx <- which(!is.na(spi_values) & !is.na(arspi_values))
  spi_trimmed <- spi_values[valid_idx]
  arspi_trimmed <- arspi_values[valid_idx]
  
  # Compute IDCM classification
  idcm_result <- compute_IDCM(ars = arspi_trimmed, spi = spi_trimmed, threshold = -1.5)
  
  # Display output
  cat("\nIDCM Classification Matrix:\n")
  print(idcm_result$IDCM_matrix)
  
  cat("\nAccuracy:", idcm_result$Accuracy, "\n")
  cat("\nDescription:\n", idcm_result$Description, "\n")
  
  return(invisible(idcm_result))
}
