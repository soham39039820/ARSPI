#' Compute ARSPI and Drought Characteristics
#'
#' @param rainfall A numeric vector of monthly rainfall values.
#' @param scale An integer indicating the time scale (e.g., 3, 6, 12).
#' @param model_file Optional path to a user-defined JAGS model file with prior specifications.
#'                   If NULL, the default internal model is used.
#'
#' @param df1_shape Description of df1_shape
#' @param df1_rate Description of df1_rate
#' @param df2_shape Description of df2_shape
#' @param df2_rate Description of df2_rate
#' @param tau2beta_shape Description of tau2beta_shape
#' @param tau2beta_rate Description of tau2beta_rate
#' @param nu1_rate Description of nu1_rate
#' @param nu2_rate Description of nu2_rate
#' @param phi_min Description of phi_min
#' @param phi_max Description of phi_max
#' @return A list with three components:
#'   \describe{
#'     \item{ARSPI}{Numeric vector of ARSPI values.}
#'     \item{Drought_Analysis}{List of drought characteristics for each category.}
#'     \item{Summary}{Data frame summarizing drought characteristics.}
#'   }
#'
#' @import R2jags
#' @importFrom stats filter runif qnorm
#' @export
arspi_estimate <- function(rainfall, scale,
                           df1_shape = 2, df1_rate = 0.2,
                           df2_shape = 2, df2_rate = 0.2,
                           tau2beta_shape = 2, tau2beta_rate = 0.2,
                           nu1_rate = 0.1, nu2_rate = 0.1,
                           phi_min = -0.99, phi_max = 0.99,
                           model_file = NULL) {

  if (!is.numeric(rainfall) || any(rainfall < 0)) {
    stop("Rainfall data must be a numeric vector of non-negative values.")
  }
  if (!is.numeric(scale) || length(scale) != 1 || scale < 1) {
    stop("Scale must be a positive integer.")
  }

  # Compute moving total rainfall (MTR)
  T_mtr <- length(rainfall)
  if (T_mtr < scale) stop("Rainfall series is shorter than the scale.")
  mtr <- stats::filter(rainfall, rep(1, scale), sides = 1)
  mtr <- mtr[!is.na(mtr)]
  n <- length(mtr)
  zero.ind <- as.numeric(mtr == 0)

  # Prepare data list with priors
  jagsdata <- list(
    T = n - 2,
    r = mtr[2:(n - 1)],
    isr0 = zero.ind[2:(n - 1)],
    df1_shape = df1_shape,
    df1_rate = df1_rate,
    df2_shape = df2_shape,
    df2_rate = df2_rate,
    tau2beta_shape = tau2beta_shape,
    tau2beta_rate = tau2beta_rate,
    nu1_rate = nu1_rate,
    nu2_rate = nu2_rate,
    phi_min = phi_min,
    phi_max = phi_max
  )

  jags.params <- c("p", "beta", "sig", "yP", "alp", "phi")
  jags.inits <- function() {
    list(beta = runif(2, min = -1, max = 1), phi = runif(1, phi_min, phi_max))
  }

  if (is.null(model_file)) {
    model_file <- system.file("inst", "SPIAR1_HBpt.txt", package = "ARSPI")
  }
  if (model_file == "") {
    stop("Model file not found in package.")
  }

  # Run JAGS model with the specified priors
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

  rslt.mcmc <- results.jgs$BUGSoutput$sims.list
  pred.rslt <- as.array(rslt.mcmc$yP)

  EMPCDF <- function(M, V) {
    sapply(1:ncol(M), function(i) mean(M[, i] < V[i]))
  }

  arspi <- qnorm(EMPCDF(pred.rslt, mtr[2:(n - 1)]))

  drought_categories <- list(
    Mild = list(range = c(-0.99, 0.0)),
    Moderate = list(range = c(-1.49, -1.00)),
    Severe = list(range = c(-1.99, -1.50)),
    Extreme = list(range = c(-Inf, -2.00))
  )

  extract_drought_events <- function(series, lower, upper) {
    idx <- which(series > lower & series <= upper)
    if (length(idx) == 0) return(list(events = 0, duration = NULL, severity = NULL, peak = NULL))
    split_idx <- split(idx, cumsum(c(1, diff(idx) != 1)))
    duration <- sapply(split_idx, length)
    severity <- sapply(split_idx, function(i) sum(series[i]))
    peak <- sapply(split_idx, function(i) min(series[i]))
    list(events = length(split_idx), duration = duration, severity = severity, peak = peak)
  }

  drought_results <- lapply(names(drought_categories), function(cat) {
    bounds <- drought_categories[[cat]]$range
    extract_drought_events(arspi, bounds[1], bounds[2])
  })
  names(drought_results) <- names(drought_categories)

  summary_df <- data.frame(
    Category = character(),
    Events = integer(),
    Avg_Duration = numeric(),
    Total_Severity = numeric(),
    Peak_Intensity = numeric(),
    stringsAsFactors = FALSE
  )

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

  return(list(
    ARSPI = arspi,
    Drought_Analysis = drought_results,
    Summary = summary_df
  ))
}
