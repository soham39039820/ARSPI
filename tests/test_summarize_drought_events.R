test_summarize_drought_events <- function() {
  # GitHub raw file URLs
  rainfall_url <- "https://raw.githubusercontent.com/soham39039820/ARSPI/master/inst/extdata/rainfall_sample_data.csv"
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
  output <- computeARSPI(
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
  arspi_values <- output$arspi

  # Run drought summary
  drought_summary <- summarize_drought_events(arspi_values)

  # Print summary
  cat("Summary of Drought Events (based on ARSPI):\n")
  print(drought_summary$summary)

  # Print details for one category (optional)
  cat("\nExtreme Drought Event Details:\n")
  print(drought_summary$details$Extreme)

  return(invisible(drought_summary))
}

# To run this test:
# test_summarize_drought_events()
