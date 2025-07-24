#' Run Bayesian ARSPI JAGS Model
#'
#' @param rainfall Numeric vector of monthly rainfall values.
#' @param scale Integer value for time scale (e.g., 3, 6, 12).
#' @param n.burnin Number of burn-in iterations.
#' @param n.iter Total number of iterations.
#' @param n.thin Thinning interval.
#' @param n.chains Number of chains.
#' @param use_parallel Logical, whether to use jags.parallel().
#' @param model_file Path to JAGS model file.
#' @param ... Additional prior parameters.
#'
#' @return A list with two elements:
#'   - arspi: Numeric vector of ARSPI values with NA padding
#'   - BUGSoutput: JAGS MCMC output object for diagnostics and plotting
#'
#' @export
computeARSPI <- function(rainfall, scale,
                            n.burnin = 1000, n.iter = 10000, n.thin = 2, n.chains = 3,
                            use_parallel = TRUE,
                            model_file = system.file("SPIAR1_HBpt.txt", package = "ARSPI"),
                            tau2beta_shape = 2, tau2beta_rate = 0.2,
                            phi_min = -0.99, phi_max = 0.99) {
  
  if (!is.numeric(rainfall) || any(rainfall < 0)) stop("Rainfall must be non-negative numeric.")
  if (length(rainfall) < scale) stop("Rainfall series too short for scale.")
  
  if (!requireNamespace("zoo", quietly = TRUE)) stop("Please install the 'zoo' package.")
  
  # Step 1: Aggregate rainfall using moving sum
  mtr_raw <- zoo::rollapply(rainfall, width = scale, FUN = sum, align = "right", fill = NA)
  mtr_model_input <- mtr_raw[!is.na(mtr_raw)]
  
  # Step 2: Replace zeros with epsilon for modeling
  epsilon <- 0.01
  zero.ind <- as.numeric(mtr_model_input == 0)
  mtr_model <- ifelse(mtr_model_input == 0, epsilon, mtr_model_input)
  n <- length(mtr_model)
  
  # Step 3: Prepare JAGS data list
  jagsdata <- list(
    T = n,
    r = mtr_model,
    isr0 = zero.ind,
    tau2beta_shape = tau2beta_shape,
    tau2beta_rate = tau2beta_rate,
    phi_min = phi_min,
    phi_max = phi_max,
    nu = 2  # Prior shape/rate parameter for tau2 ~ dgamma(nu/2, nu/2)
  )
  
  # Step 4: JAGS parameters and initial values
  jags.params <- c("p", "beta", "sig", "rP", "alpha", "phi")
  jags.inits <- function() {
    list(beta = runif(2, -0.5, 0.5), phi = runif(1, phi_min, phi_max))
  }
  
  message(if (use_parallel) "Using parallel JAGS" else "Using sequential JAGS")
  
  # Step 5: Run JAGS
  jags_result <- if (use_parallel) {
    R2jags::jags.parallel(
      data = jagsdata,
      inits = jags.inits,
      parameters.to.save = jags.params,
      n.burnin = n.burnin,
      n.iter = n.iter,
      n.thin = n.thin,
      n.chains = n.chains,
      model.file = model_file,
      DIC = TRUE
    )
  } else {
    R2jags::jags(
      data = jagsdata,
      inits = jags.inits,
      parameters.to.save = jags.params,
      n.burnin = n.burnin,
      n.iter = n.iter,
      n.thin = n.thin,
      n.chains = n.chains,
      model.file = model_file,
      DIC = TRUE
    )
  }
  
  # Step 6: Convert rP to ARSPI using empirical CDF and qnorm
  yP_samples <- jags_result$BUGSoutput$sims.list$rP
  pred_mat <- as.matrix(yP_samples)
  
  EMPCDF <- function(M, V) {
    raw_cdf <- sapply(1:ncol(M), function(i) mean(M[, i] < V[i]))
    pmin(pmax(raw_cdf, 1e-6), 1 - 1e-6)  # prevent -Inf/+Inf in qnorm
  }
  
  arspi_core <- qnorm(EMPCDF(pred_mat, mtr_model))
  
  # Step 7: Fill in ARSPI to full series with NA padding
  arspi_full <- rep(NA, length(rainfall))
  arspi_full[seq(from = scale, length.out = length(arspi_core))] <- arspi_core
  
  return(list(arspi = arspi_full, BUGSoutput = jags_result$BUGSoutput))
}
