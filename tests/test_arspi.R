test_arspi <- function() {
  file_path <- "C:/Users/soham/OneDrive - IIT Indore/Research Work/sujay sir/Newsvendor/Rainfall Data for Africa/Egypt rainfall data.csv"
  if (!file.exists(file_path)) stop("Rainfall data file not found.")

  rainfall_data <- read.csv(file_path, header = TRUE)
  if (nrow(rainfall_data) < 360) stop("Insufficient data length.")

  rainfall_series <- rainfall_data[1:360, 2]

  model_file_path <- "C:/Users/soham/OneDrive - IIT Indore/Research Work/sujay sir/Newsvendor/ARSPI/inst/SPIAR1_HBpt.txt"
  if (!file.exists(model_file_path)) stop("Model file not found.")

  result <- arspi_estimate(
    rainfall = rainfall_series,
    scale = 6,
    model_file = model_file_path
  )

  cat("ARSPI values:\n")
  print(result$ARSPI)

  cat("Summary:\n")
  print(result$Summary)

  return(result)
}
