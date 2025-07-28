#' Compute Drought Intensity Propagator (DIP)
#'
#' Calculates the Drought Intensity Propagator (DIP), which measures the extent
#' to which meteorological drought (as captured by ARSPI) propagates to a downstream
#' target drought index (e.g., NDVI-based index). The DIP is computed as the ratio
#' of target intensity to ARSPI intensity for each drought event.
#'
#' The function:
#' \enumerate{
#'   \item Identifies drought events in the ARSPI series based on a threshold.
#'   \item Computes the integrated intensity (sum) of ARSPI and target indices over the event duration.
#'   \item Calculates the DIP as the ratio of target to ARSPI intensity.
#' }
#'
#' @param arspi Numeric vector of ARSPI (meteorological drought index) values.
#' @param target Numeric vector of downstream drought index values (e.g., NDVI), must be same length as \code{arspi}.
#' @param thr Numeric threshold for defining drought events in \code{arspi} (default is -1).
#' @param min_dur Integer specifying the minimum duration (in months) for an event to be counted (default is 1).
#'
#' @return A \code{data.frame} with columns:
#' \describe{
#'   \item{start}{Index of drought event start.}
#'   \item{end}{Index of drought event end.}
#'   \item{duration}{Number of time steps in the event.}
#'   \item{arspi_int}{Integrated intensity (sum) of ARSPI values during the event.}
#'   \item{target_int}{Integrated intensity of the target index during the event.}
#'   \item{DIP}{Drought Intensity Propagator: target\_int / arspi\_int.}
#' }
#'
#' @examples
#' arspi <- c(-0.5, -1.2, -1.4, -0.8, -1.1, -0.7, 0.2)
#' target <- c(-0.2, -0.8, -0.9, -0.4, -0.6, -0.3, 0.1)
#' compute_DIP(arspi, target, thr = -1, min_dur = 2)
#'
#' @export

compute_DIP <- function(arspi, target, thr = -1, min_dur = 1) {
  if (length(arspi) != length(target))
    stop("`arspi` and `target` must have equal lengths.")

  # Identify events: run labeling
  is_drought <- arspi < thr
  runs <- rle(is_drought)
  ends <- cumsum(runs$lengths)
  starts <- ends - runs$lengths + 1

  # Prepare result container
  res <- data.frame(
    start = integer(), end = integer(),
    duration = integer(),
    arspi_int = numeric(), target_int = numeric(),
    DIP = numeric(), stringsAsFactors = FALSE
  )

  # Compute for each event
  idx <- 1
  for (i in seq_along(runs$values)) {
    if (runs$values[i] && runs$lengths[i] >= min_dur) {
      si <- starts[i]; ei <- ends[i]
      ai <- sum(arspi[si:ei], na.rm = TRUE)
      ti <- sum(target[si:ei], na.rm = TRUE)
      res[idx, ] <- c(si, ei, ei - si + 1, ai, ti, ifelse(ai != 0, ti / ai, NA))
      idx <- idx + 1
    }
  }

  # Clean up and format
  res$start <- as.integer(res$start)
  res$end <- as.integer(res$end)
  res$duration <- as.integer(res$duration)
  res
}
