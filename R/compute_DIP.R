#’ Compute Drought Intensity Propagator (DIP)
#’
#’ This function calculates the DIP by:
#’   1. Identifying drought events in the ARSPI series by threshold crossing.
#’   2. Summing the ARSPI values (integrated intensity) over each event window.
#’   3. Doing the same for a downstream target index (e.g., NDVI‑based drought).
#’   4. Calculating the ratio of target intensity to ARSPI intensity per event.
#’
#’ @param arspi numeric vector: Meteorological drought index values.
#’ @param target numeric vector: Downstream drought index values, same length.
#’ @param thr numeric: ARSPI threshold for defining drought (default –1).
#’ @param min_dur integer: Minimum duration (months) for counting event.
#’ @return data.frame with event start, end, duration, arspi_int, target_int, DIP.
#’ @export
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
