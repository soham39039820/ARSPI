#' Summarize Drought Events Based on SPI or ARSPI Index
#'
#' @param index Numeric vector of drought index values (e.g., SPI or ARSPI).
#' @param categories Named list of drought category thresholds (lower, upper).
#'
#' @return A list with:
#'   - summary: Data frame with summary statistics per drought category.
#'   - details: List with duration, severity, and peak intensity of individual events.
#'
#' @export
summarize_drought_events <- function(index,
                                     categories = list(
                                       Extreme  = c(-Inf, -2.00),
                                       Severe   = c(-2.00, -1.50),
                                       Moderate = c(-1.50, -1.00),
                                       Mild     = c(-1.00, -0.01)
                                     )) {
  
  # Helper function to extract event metrics within a threshold
  extract_events <- function(series, lower, upper) {
    idx <- which(series > lower & series <= upper)
    if (length(idx) == 0) {
      return(list(events = 0, duration = NULL, severity = NULL, peak = NULL, indices = NULL))
    }
    split_idx <- split(idx, cumsum(c(1, diff(idx) != 1)))
    duration <- sapply(split_idx, length)
    severity <- sapply(split_idx, function(i) sum(series[i]))
    peak <- sapply(split_idx, function(i) min(series[i]))
    indices <- lapply(split_idx, function(i) i)
    
    list(
      events = length(split_idx),
      duration = duration,
      severity = severity,
      peak = peak,
      indices = indices
    )
  }
  
  # Initialize output containers
  summary_df <- data.frame(
    Category = character(),
    Events = integer(),
    Avg_Duration = numeric(),
    Total_Severity = numeric(),
    Peak_Intensity = numeric(),
    stringsAsFactors = FALSE
  )
  
  details_list <- list()
  
  # Compute for each category
  for (cat in names(categories)) {
    bounds <- categories[[cat]]
    result <- extract_events(index, bounds[1], bounds[2])
    
    # Summary stats
    n_events <- result$events
    avg_duration <- if (!is.null(result$duration)) mean(result$duration) else NA
    total_severity <- if (!is.null(result$severity)) sum(result$severity) else NA
    peak_intensity <- if (!is.null(result$peak)) min(result$peak) else NA
    
    summary_df <- rbind(summary_df, data.frame(
      Category = cat,
      Events = n_events,
      Avg_Duration = avg_duration,
      Total_Severity = total_severity,
      Peak_Intensity = peak_intensity
    ))
    
    # Store full details
    details_list[[cat]] <- list(
      duration = result$duration,
      severity = result$severity,
      peak = result$peak,
      indices = result$indices
    )
  }
  
  return(list(summary = summary_df, details = details_list))
}
