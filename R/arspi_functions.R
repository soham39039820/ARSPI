#' Compute ARSPI and Drought Characteristics
#'
#' @param rainfall A numeric vector of monthly rainfall values.
#' @param scale An integer indicating the scale (e.g., 3, 6, 12).
#' @return A list containing ARSPI values and drought characteristics for each drought category.
#' @import R2jags
#' @importFrom stats runif qnorm
#' @export
arspi_estimate <- function(rainfall, scale, model_file = NULL) {
  if (!is.numeric(rainfall) || any(rainfall < 0)) {
    stop("Rainfall data must be a numeric vector of non-negative values.")
  }
  if (!is.numeric(scale) || length(scale) != 1 || scale < 1) {
    stop("Scale must be a positive integer.")
  }
  
  # Step 1: Compute Moving Total Rainfall (MTR)
  T_mtr <- length(rainfall)
  if (T_mtr < scale) stop("Rainfall series is shorter than the scale.")
  mtr <- stats::filter(rainfall, rep(1, scale), sides = 1)
  mtr <- mtr[!is.na(mtr)]
  n <- length(mtr)
  zero.ind <- as.numeric(mtr == 0)
  
  jagsdata <- list(
    T = n - 2,
    r = mtr[2:(n - 1)],
    isr0 = zero.ind[2:(n - 1)]
  )
  
  jags.params <- c("p", "beta", "sig", "yP", "alp", "phi")
  jags.inits <- function() {
    list(beta = runif(2, min = -1, max = 1), phi = runif(1, -1, 1))
  }
  
  if (is.null(model_file)) {
    model_file <- system.file("inst", "SPIAR1_HBpt.txt", package = "ARSPI")
  }
  if (model_file == "") {
    stop("Model file not found in package.")
  }
  
  # Run JAGS model
  results.jgs <- R2jags::jags.parallel(
    data = jagsdata,
    inits = jags.inits,
    parameters.to.save = jags.params,
    n.burnin = 5000,
    n.iter = 150000,
    n.thin = 10,
    n.chains = 3,
    n.cluster = 3,
    model.file = model_file,
    DIC = TRUE
  )
  
  # Extract MCMC results
  rslt.mcmc <- results.jgs$BUGSoutput$sims.list
  pred.rslt <- as.array(rslt.mcmc$yP)
  
  # Define the Empirical CDF function
  EMPCDF <- function(M, V) {
    sapply(1:ncol(M), function(i) {
      mean(M[, i] < V[i])
    })
  }
  
  # Compute ARSPI values (quantiles of the empirical CDF)
  arspi <- qnorm(EMPCDF(pred.rslt, mtr[2:(n-1)]))
  
  # Define drought categories with ranges
  drought_categories <- list(
    Mild = list(range = c(-0.99, 0.0)),
    Moderate = list(range = c(-1.49, -1.00)),
    Severe = list(range = c(-1.99, -1.50)),
    Extreme = list(range = c(-Inf, -2.00))
  )
  
  # Function to extract drought events for a given range
  extract_drought_events <- function(series, lower, upper) {
    idx <- which(series > lower & series <= upper)
    if (length(idx) == 0) return(list(events = 0, duration = NULL, severity = NULL, peak = NULL))
    
    split_idx <- split(idx, cumsum(c(1, diff(idx) != 1)))
    duration <- sapply(split_idx, length)
    severity <- sapply(split_idx, function(i) sum(series[i]))
    peak <- sapply(split_idx, function(i) min(series[i]))
    
    list(
      events = length(split_idx),
      duration = duration,
      severity = severity,
      peak = peak
    )
  }
  
  # Collect drought event results
  drought_results <- lapply(names(drought_categories), function(cat) {
    bounds <- drought_categories[[cat]]$range
    extract_drought_events(arspi, bounds[1], bounds[2])
  })
  names(drought_results) <- names(drought_categories)
  
  # Summarize the drought characteristics into a clean data frame
  summary_df <- data.frame(
    Category = character(),
    Events = integer(),
    Avg_Duration = numeric(),
    Total_Severity = numeric(),
    Peak_Intensity = numeric(),
    stringsAsFactors = FALSE
  )
  
  # Populate the summary table
  for (cat in names(drought_results)) {
    cat_data <- drought_results[[cat]]
    n_events <- cat_data$events
    avg_duration <- if (!is.null(cat_data$duration)) mean(cat_data$duration) else NA
    total_severity <- if (!is.null(cat_data$severity)) sum(cat_data$severity) else NA
    peak_intensity <- if (!is.null(cat_data$peak)) min(cat_data$peak) else NA
    
    summary_df <- rbind(summary_df, data.frame(
      Category = cat,
      Events = n_events,
      Avg_Duration = avg_duration,
      Total_Severity = total_severity,
      Peak_Intensity = peak_intensity
    ))
  }
  
  # Return ARSPI values, drought analysis, and summary table
  return(list(
    ARSPI = arspi,
    Drought_Analysis = drought_results,
    Summary = summary_df
  ))
}
