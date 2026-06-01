# Forecasting method workflows.
# All methods use the selected quarterly TÜİK time series prepared in R/data_import.R.

source("R/accuracy_measures.R")

moving_average_fit <- function(y, window = 4) {
  fitted <- rep(NA_real_, length(y))
  for (i in (window + 1):length(y)) {
    fitted[i] <- mean(y[(i - window):(i - 1)], na.rm = TRUE)
  }
  fitted
}

weighted_moving_average_fit <- function(y, weights = c(0.10, 0.20, 0.30, 0.40)) {
  fitted <- rep(NA_real_, length(y))
  k <- length(weights)
  for (i in (k + 1):length(y)) {
    fitted[i] <- sum(y[(i - k):(i - 1)] * weights)
  }
  fitted
}

build_candidate_forecasts <- function(series) {
  y <- as.numeric(series$value)
  n <- length(y)
  freq <- 4
  t <- series$t
  q <- factor(series$quarter_num)
  y_ts <- stats::ts(y, start = c(series$year[1], series$quarter_num[1]), frequency = freq)
  next_q <- ifelse(tail(series$quarter_num, 1) == 4, 1, tail(series$quarter_num, 1) + 1)
  methods <- list()

  # 1. Naive Forecasting
  methods[["Naive Forecasting"]] <- list(
    fitted = dplyr::lag(y, 1),
    next_forecast = tail(y, 1),
    note = "Previous quarter value is used as the next forecast."
  )

  # 2. Moving Average
  ma_window <- 4
  ma_fitted <- moving_average_fit(y, ma_window)
  methods[["Moving Average"]] <- list(
    fitted = ma_fitted,
    next_forecast = mean(tail(y, ma_window)),
    note = "Four-quarter moving average is used because the data are quarterly."
  )

  # 3. Weighted Moving Average
  w <- c(0.10, 0.20, 0.30, 0.40)
  wma_fitted <- weighted_moving_average_fit(y, w)
  methods[["Weighted Moving Average"]] <- list(
    fitted = wma_fitted,
    next_forecast = sum(tail(y, 4) * w),
    note = "Recent quarters receive larger weights: 0.10, 0.20, 0.30, 0.40."
  )

  # 4. Exponential Smoothing
  ses_fit <- forecast::ses(y_ts, h = 1)
  methods[["Exponential Smoothing"]] <- list(
    fitted = as.numeric(ses_fit$fitted),
    next_forecast = as.numeric(ses_fit$mean[1]),
    note = "Simple exponential smoothing with optimized alpha."
  )

  # 5. Trend-Adjusted Exponential Smoothing
  holt_fit <- forecast::holt(y_ts, h = 1)
  methods[["Trend-Adjusted Exponential Smoothing"]] <- list(
    fitted = as.numeric(holt_fit$fitted),
    next_forecast = as.numeric(holt_fit$mean[1]),
    note = "Holt trend-adjusted smoothing with optimized level and trend parameters."
  )

  # 6. Linear Trend Projection
  trend_lm <- stats::lm(y ~ t)
  methods[["Linear Trend Projection"]] <- list(
    fitted = as.numeric(stats::fitted(trend_lm)),
    next_forecast = as.numeric(stats::predict(trend_lm, newdata = data.frame(t = n + 1))),
    note = paste0("Trend equation: y = ", round(coef(trend_lm)[1], 3), " + ", round(coef(trend_lm)[2], 3), "t.")
  )

  # 7. Seasonal Indices
  season_means <- tapply(y, series$quarter_num, mean, na.rm = TRUE)
  overall <- mean(y, na.rm = TRUE)
  seasonal_indices <- season_means / overall
  seasonal_fitted <- overall * seasonal_indices[as.character(series$quarter_num)]
  methods[["Seasonal Indices"]] <- list(
    fitted = as.numeric(seasonal_fitted),
    next_forecast = as.numeric(overall * seasonal_indices[as.character(next_q)]),
    note = paste0("Quarterly seasonal indices: ", paste(names(seasonal_indices), round(seasonal_indices, 3), collapse = "; "))
  )

  # 8. Additive Decomposition
  decomp_add <- stats::decompose(y_ts, type = "additive")
  add_fitted <- as.numeric(decomp_add$trend + decomp_add$seasonal)
  add_fc <- forecast::forecast(decomp_add, h = 1)
  methods[["Additive Decomposition"]] <- list(
    fitted = add_fitted,
    next_forecast = as.numeric(add_fc$mean[1]),
    note = "Additive decomposition separates trend, seasonal, and random components."
  )

  # 9. Multiplicative Decomposition
  decomp_mul <- stats::decompose(y_ts, type = "multiplicative")
  mul_fitted <- as.numeric(decomp_mul$trend * decomp_mul$seasonal)
  mul_fc <- forecast::forecast(decomp_mul, h = 1)
  methods[["Multiplicative Decomposition"]] <- list(
    fitted = mul_fitted,
    next_forecast = as.numeric(mul_fc$mean[1]),
    note = "Multiplicative decomposition is considered because the series is positive."
  )

  # 10. Regression with Trend and Seasonal Dummy Variables
  season_lm <- stats::lm(y ~ t + q)
  methods[["Regression with Trend and Seasonal Dummies"]] <- list(
    fitted = as.numeric(stats::fitted(season_lm)),
    next_forecast = as.numeric(stats::predict(season_lm, newdata = data.frame(t = n + 1, q = factor(next_q, levels = levels(q))))),
    note = "Regression uses a time trend and quarterly seasonal dummy variables."
  )

  accuracy <- purrr::imap_dfr(methods, function(m, nm) {
    calc_accuracy(y, m$fitted) |>
      dplyr::mutate(
        Method = nm,
        Next_Period_Forecast = as.numeric(m$next_forecast),
        Note = m$note,
        .before = 1
      )
  }) |>
    dplyr::arrange(MAPE, MAD)

  list(methods = methods, accuracy = accuracy)
}
