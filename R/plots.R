# Plot generation functions.

plot_series <- function(series) {
  ggplot2::ggplot(series, ggplot2::aes(x = date, y = value)) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::labs(
      title = "Actual Time Series: Insufficient Demand in Services Sector",
      x = "Date",
      y = "Insufficient demand (%)"
    ) +
    ggplot2::theme_minimal()
}

plot_method_fit <- function(series, methods, method_name, title = NULL) {
  plot_data <- series |>
    dplyr::mutate(Forecast = as.numeric(methods[[method_name]]$fitted)) |>
    tidyr::pivot_longer(cols = c(value, Forecast), names_to = "Series", values_to = "Value") |>
    dplyr::mutate(Series = dplyr::recode(Series, value = "Actual", Forecast = "Forecast / fitted"))
  ggplot2::ggplot(plot_data, ggplot2::aes(x = date, y = Value, linetype = Series)) +
    ggplot2::geom_line(linewidth = 0.8, na.rm = TRUE) +
    ggplot2::labs(
      title = ifelse(is.null(title), paste("Actual vs Forecast -", method_name), title),
      x = "Date",
      y = "Insufficient demand (%)",
      linetype = "Series"
    ) +
    ggplot2::theme_minimal()
}

save_all_method_plots <- function(series, methods, best_method) {
  plot_files <- c(
    "Naive Forecasting" = "naive_forecast_plot.png",
    "Moving Average" = "moving_average_plot.png",
    "Weighted Moving Average" = "weighted_moving_average_plot.png",
    "Exponential Smoothing" = "exponential_smoothing_plot.png",
    "Trend-Adjusted Exponential Smoothing" = "trend_adjusted_smoothing_plot.png",
    "Linear Trend Projection" = "trend_projection_plot.png",
    "Seasonal Indices" = "seasonal_indices_plot.png",
    "Additive Decomposition" = "additive_decomposition_plot.png",
    "Multiplicative Decomposition" = "multiplicative_decomposition_plot.png",
    "Regression with Trend and Seasonal Dummies" = "regression_seasonal_dummy_plot.png"
  )
  for (method_name in names(plot_files)) {
    p <- plot_method_fit(series, methods, method_name)
    ggplot2::ggsave(file.path("outputs", "figures", plot_files[[method_name]]), p, width = 8, height = 4.5)
  }
  p_best <- plot_method_fit(series, methods, best_method, paste("Superior Method -", best_method))
  ggplot2::ggsave(file.path("outputs", "figures", "superior_method_plot.png"), p_best, width = 8, height = 4.5)
}
