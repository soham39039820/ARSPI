source("R/arspi_functions.R")
source("R/compute_DIP.R")
source("tests/test_arspi.R")

test_compute_DIP <- function() {
  result <- test_arspi()
  ars <- result$ARSPI
  target <- -0.3 * ars + rnorm(length(ars), 0, 0.2)
  compute_DIP(ars, target, thr = -1, min_dur = 2)
}
