# Function to compute IDCM classification matrix
compute_IDCM <- function(ars, spi, threshold = -1.5) {
  # Classify drought presence (1 = drought, 0 = no drought)
  ars_flag <- ifelse(ars < threshold, 1, 0)
  spi_flag <- ifelse(spi < threshold, 1, 0)
  
  # Compute counts
  CD  <- sum(ars_flag == 1 & spi_flag == 1)  # Common Detection
  FA  <- sum(ars_flag == 1 & spi_flag == 0)  # False Alarm by ARSPI
  MD  <- sum(ars_flag == 0 & spi_flag == 1)  # Missed Detection by ARSPI
  ND  <- sum(ars_flag == 0 & spi_flag == 0)  # No Detection
  
  # Put results into a matrix
  matrix <- matrix(c(CD, FA, MD, ND), nrow = 2, byrow = TRUE)
  colnames(matrix) <- c("SPI: Drought", "SPI: No Drought")
  rownames(matrix) <- c("ARSPI: Drought", "ARSPI: No Drought")
  
  # Compute overall accuracy
  accuracy <- (CD + ND) / length(ars_flag)
  
  list(
    IDCM_matrix = matrix,
    Accuracy = round(accuracy, 3),
    Description = "CD = common detection, FA = false alarm (ARSPI only), MD = missed detection (SPI only), ND = no drought"
  )
}

# --- Example usage:
# ars_values <- c(-2.1, -0.5, -1.6, -1.8, -0.2)
# spi_values <- c(-1.7, -0.3, -1.2, -2.0, -0.1)
# compute_IDCM(ars_values, spi_values)
