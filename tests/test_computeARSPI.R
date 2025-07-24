test_compute_arspi <- function() {
  # Download sample data from GitHub
  file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/extdata/rainfall_sample_data.csv"
  rainfall_data <- tryCatch(
    read.csv(file_url, header = TRUE),
    error = function(e) stop("Failed to load rainfall data from GitHub.")
  )

  if (nrow(rainfall_data) < 360) stop("Insufficient data length.")
  rainfall_series <- rainfall_data[1:360, 2]

  # Download model file from GitHub to a temp file
  model_file_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/SPIAR1_HBpt.txt"
  model_file_path <- tempfile(fileext = ".txt")
  download.file(model_file_url, destfile = model_file_path, quiet = TRUE)

  # Run ARSPI computation
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

  cat("ARSPI values (first 10):\n")
  print(head(result$arspi, 10))

  cat("\nSummary (rounded):\n")
  if (is.matrix(result$BUGSoutput$summary)) {
    print(round(result$BUGSoutput$summary, 2))
  } else {
    warning("BUGSoutput$summary is not a matrix.")
  }

  return(invisible(result))
}
