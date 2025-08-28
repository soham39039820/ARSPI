#' Compute Innovative Drought Characterization Matrix (IDCM)
#'
#' Compares ARSPI computed on the full record vs a recent reference window, and
#' reports performance metrics (RMSE, CC, R^2, HH) and an 8x8 classification matrix.
#'
#' @param rainfall Numeric vector of monthly rainfall values.
#' @param scale Integer. Accumulation period (e.g., 3, 12, 24).
#' @param ref_years Integer. Length of the reference period in years (e.g., 10).
#' @param model_file Path to JAGS model file (default: included in ARSPI package).
#'
#' @return A list with:
#' \describe{
#'   \item{FullPeriod_ARSPI}{ARSPI for the full data period}
#'   \item{Reference_ARSPI}{ARSPI computed only on the reference window}
#'   \item{Ti}{Full-period ARSPI restricted to the reference window (used for metrics)}
#'   \item{Ri}{Reference-period ARSPI aligned with Ti (used for metrics)}
#'   \item{Metrics}{Data frame with RMSE, Correlation, R2, HH, DiagonalDominance, N}
#'   \item{IDCM}{8x8 contingency matrix of category cross-classifications (rows = Ti, cols = Ri)}
#' }
#' @export
#'
#' @examples
#' # compute_IDCM(rainfall_series, scale = 12, ref_years = 10)
#'
compute_IDCM <- function(rainfall, scale = 12, ref_years = 10,
                         model_file = system.file("SPIAR1_HBpt.txt", package = "ARSPI")) {
  if (!requireNamespace("ARSPI", quietly = TRUE)) {
    stop("Package 'ARSPI' is required. Please install it.")
  }
  # Basic checks
  if (!is.numeric(rainfall) || length(rainfall) < (ref_years * 12 + scale)) {
    warning("Rainfall length may be too short for the requested reference period and scale.")
  }
  if (ref_years <= 0) stop("'ref_years' must be positive.")
  if (scale <= 0) stop("'scale' must be positive.")

  # --- 1. Compute ARSPI for full period ---
  full_result <- computeARSPI(
    rainfall = rainfall,
    scale = scale,
    model_file = model_file
  )
  full_ars <- full_result$arspi

  # --- 2. Compute ARSPI for reference period ---
  ref_months <- ref_years * 12
  ref_rainfall <- tail(rainfall, ref_months)

  ref_result <- computeARSPI(
    rainfall = ref_rainfall,
    scale = scale,
    model_file = model_file
  )
  ref_ars <- ref_result$arspi


  # --- 3) Build Ti (full ARSPI restricted to the ref window) and Ri (reference ARSPI) ---
  # Use the last ref_months of the full-period ARSPI as Ti_raw
  Ti_raw <- utils::tail(full_ars, ref_months)
  Ri_raw <- ref_ars

  # Keep only months where both series are available (non-NA)
  ok <- stats::complete.cases(Ti_raw, Ri_raw)
  Ti <- Ti_raw[ok]
  Ri <- Ri_raw[ok]
  N  <- length(Ti)

  if (N == 0) {
    stop("No overlapping, non-NA months available to compare. Check inputs/scale/ref_years.")
  }

  # --- 4) Metrics: RMSE, CC, R^2, HH (corrected) ---
  RMSE <- sqrt(mean((Ti - Ri)^2))
  CC   <- suppressWarnings(stats::cor(Ti, Ri))
  R2   <- CC^2

  denom_HH <- sum(abs(Ti * Ri))
  if (denom_HH == 0) {
    HH <- NA_real_
    warning("HH denominator is zero; HH set to NA.")
  } else {
    HH <- sqrt(sum((Ti - Ri)^2) / denom_HH)
  }

  # --- 5) Category classification (Table: 8 classes) ---
  # Boundaries per your table; 0 is assigned to 'Mild Wet' to avoid a gap.
  classify8 <- function(z) {
    if (is.na(z)) return(as.integer(NA))
    if (z >=  2.00) return(1L)   # Extreme Wet
    if (z >=  1.50 && z <  2.00) return(2L)
    if (z >=  1.00 && z <  1.50) return(3L)
    if (z >=  0.00 && z <  1.00) return(4L)
    if (z >= -0.99 && z <  0.00) return(5L)
    if (z >= -1.49 && z < -1.00) return(6L)
    if (z >= -1.99 && z < -1.50) return(7L)
    if (z <= -2.00) return(8L)
    return(as.integer(NA))  # safety
  }

  cat_Ti <- vapply(Ti, classify8, integer(1))
  cat_Ri <- vapply(Ri, classify8, integer(1))

  # --- 6) 8x8 IDCM (rows = Ti categories; cols = Ri categories) ---
  IDCM <- matrix(0L, nrow = 8, ncol = 8)
  for (k in seq_len(N)) {
    i <- cat_Ti[k]; j <- cat_Ri[k]
    if (!is.na(i) && !is.na(j)) {
      IDCM[i, j] <- IDCM[i, j] + 1L
    }
  }

  cat_names <- c("Extreme Wet","Severe Wet","Moderate Wet","Mild Wet",
                 "Mild Drought","Moderate Drought","Severe Drought","Extreme Drought")
  dimnames(IDCM) <- list(
    `Full ARSPI (Ti)`      = cat_names,
    `Reference ARSPI (Ri)` = cat_names
  )

  # --- 7) Diagonal Dominance ---
  DiagonalDominance <- sum(diag(IDCM)) / sum(IDCM)

  # --- 8) Pack metrics ---
  Metrics <- data.frame(
    Scale            = scale,
    ReferenceYears   = ref_years,
    N                = N,
    RMSE             = round(RMSE, 3),
    Correlation      = round(CC, 3),
    R2               = round(R2, 3),
    HH_Index         = round(HH, 3),
    DiagonalDominance= round(DiagonalDominance, 3)
  )

  # --- 9) Return ---
  list(
    FullPeriod_ARSPI = full_ars,
    Reference_ARSPI  = ref_ars,
    Ti               = Ti,
    Ri               = Ri,
    Metrics          = Metrics,
    IDCM             = IDCM
  )
}
