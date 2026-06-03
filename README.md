# TÜİK Forecasting Project

## 1. Project Overview

This project forecasts **insufficient demand (%)** as a factor limiting activities in the Turkish services sector using a quarterly TÜİK time series.

## 2. Data Source and TÜİK Connection

- Student name: Ömer Faruk ASLANER
- Student number: 138722028
- TÜİK data set name: Main factors limiting activities in services sector
- TÜİK theme/category: Short-Term Economic Indicators
- TÜİK table name: Main factors limiting activities in services sector
- tuikr dataflow ID: TR,DF_GUVEN_ENDEKS_FAALIYET_KISITLAMA_SDMX,1.0
- Selected variable: Insufficient demand (%)
- Data frequency: Quarterly
- Time coverage: 2011-Q1 / 2026-Q2
- Latest available observation: 2026-Q2
- Forecast target period: 2026-Q3
- Date of data access: 2026-05-31
- R package used for TÜİK metadata access: `tuikr`

Important note: During project preparation, `tuikr::statistical_data()` returned HTTP 401 for the selected SDMX dataflow. The project therefore documents the official TÜİK metadata through `tuikr::statistical_tables("9")` and keeps the published official series in `R/data_import.R` for executable rendering.

## 3. Research Objective

The objective is to forecast the next quarterly value of the percentage of service-sector enterprises reporting insufficient demand as a limiting factor.

## 4. Use of TÜİK Data in R

The selected series is prepared in R by selecting the insufficient demand variable, constructing quarterly periods, ordering the observations chronologically, checking the time coverage, and converting the values into a quarterly time-series format.

## 5. Exploratory Time Series Analysis

The series is quarterly and contains visible short-term fluctuations. The COVID-19 period creates an exceptional shock, so forecast results should be interpreted with caution.

## 6. Forecasting Methods Applied

The following methods are applied:

- Naïve Forecasting
- Moving Average
- Weighted Moving Average
- Exponential Smoothing
- Trend-Adjusted Exponential Smoothing
- Linear Trend Projection
- Seasonal Indices
- Additive Decomposition
- Multiplicative Decomposition
- Regression with Trend and Seasonal Dummy Variables

## 7. Forecast Accuracy Comparison

The accuracy comparison is saved in:

`outputs/tables/accuracy_comparison.csv`

It includes Bias, MAD, MSE, MAPE, RSFE, Tracking Signal, and the next-period forecast.

## 8. Selection of the Superior Method

The superior method is selected using both forecast accuracy and suitability for a quarterly time series.

## 9. Final Next-Period Forecast

The final forecast is saved in:

`outputs/tables/final_forecast.csv`

## 10. Interpretation of Results

The forecasted value shows the expected share of service-sector enterprises likely to report insufficient demand in the next quarter.

## 11. Limitations

Limitations include the COVID-19 structural shock, possible revisions in TÜİK data, survey-based volatility, and the absence of external explanatory variables.

## 12. Reproducibility

Run the project with:

```r
source("run_all.R")
```

## 13. Repository Structure

```text
tuik-forecasting-project-138722028/
├── README.md
├── forecasting_project.Rmd
├── forecasting_project.html
├── run_all.R
├── outputs/
│   ├── tables/
│   │   ├── accuracy_comparison.csv
│   │   └── final_forecast.csv
│   └── figures/
│       ├── actual_series_plot.png
│       ├── naive_forecast_plot.png
│       ├── moving_average_plot.png
│       ├── weighted_moving_average_plot.png
│       ├── exponential_smoothing_plot.png
│       ├── trend_adjusted_smoothing_plot.png
│       ├── trend_projection_plot.png
│       ├── seasonal_indices_plot.png
│       ├── additive_decomposition_plot.png
│       ├── multiplicative_decomposition_plot.png
│       ├── regression_seasonal_dummy_plot.png
│       └── superior_method_plot.png
├── R/
│   ├── data_import.R
│   ├── forecasting_methods.R
│   ├── accuracy_measures.R
│   └── plots.R
├── renv.lock
└── .gitignore
```

## 14. Author

Ömer Faruk ASLANER  
Student Number: 138722028
