test_compute_IDCM <- function() {
  # Load required packages
  if (!requireNamespace("ARSPI", quietly = TRUE)) {
    stop("Package 'ARSPI' is required. Please install it first.")
  }

  # Download sample rainfall data (from GitHub repo)
  file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/extdata/rainfall_sample_data.csv"
  rainfall_data <- tryCatch(
    read.csv(file_url, header = TRUE),
    error = function(e) stop("Failed to load rainfall data from GitHub.")
  )

  if (nrow(rainfall_data) < 360) stop("Insufficient data length for test.")
  rainfall_series <- rainfall_data[1:360, 2]  # Use first 360 months

  # Download ARSPI JAGS model file
  model_file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/SPIAR1_HBpt.txt"
  model_file_path <- tempfile(fileext = ".txt")
  download.file(model_file_url, destfile = model_file_path, quiet = TRUE)

  # Run IDCM computation
  idcm_result <- compute_IDCM(
    rainfall   = rainfall_series,
    scale      = 6,
    ref_years  = 10,
    model_file = model_file_path
  )

  # Display outputs
  cat("\n==== Innovative Drought Characterization Matrix (IDCM) ====\n")
  print(idcm_result$IDCM)

  cat("\n==== Metrics ====\n")
  print(idcm_result$Metrics)

  cat("\nNumber of overlapping months used:", idcm_result$Metrics$N, "\n")

  return(invisible(idcm_result))
}
