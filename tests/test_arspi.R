test_arspi <- function() {
  # Load the data
    file_path <- "C:/Users/soham/OneDrive - IIT Indore/Research Work/sujay sir/Newsvendor/Rainfall Data for Africa/Egypt rainfall data.csv"
    rainfall_data <- read.csv(file_path, header = TRUE)
    
    # Extract the first 360 observations from the second column
    rainfall_series <- rainfall_data[1:360, 2]
    
    # Specify the full path to your JAGS model file
    model_file_path <- "C:/Users/soham/OneDrive - IIT Indore/Research Work/sujay sir/Newsvendor/ARSPI/inst/SPIAR1_HBpt.txt"
    
    # Run ARSPI estimation
    result <- arspi_estimate(
      rainfall = rainfall_series,
      scale = 6,
      model_file = model_file_path
    )
    
  # Print ARSPI values
  print("ARSPI values:\n")
  print(result$ARSPI)
  
  print("summary")
  print(result$Summary)
}
