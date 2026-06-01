# Forecast accuracy calculations for the TÜİK forecasting project.
# This file is sourced by forecasting_project.Rmd and forecasting_methods.R.

calc_accuracy <- function(actual, fitted) {
  actual <- as.numeric(actual)
  fitted <- as.numeric(fitted)
  ok <- is.finite(actual) & is.finite(fitted) & actual != 0
  actual <- actual[ok]
  fitted <- fitted[ok]
  errors <- actual - fitted
  mad <- mean(abs(errors))
  rsfe <- sum(errors)
  tibble::tibble(
    Bias = mean(errors),
    MAD = mad,
    MSE = mean(errors^2),
    MAPE = mean(abs(errors / actual)) * 100,
    RSFE = rsfe,
    Tracking_Signal = ifelse(mad == 0, NA_real_, rsfe / mad)
  )
}
