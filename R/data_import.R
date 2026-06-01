# Data import and source documentation for the TÜİK forecasting project.
# No local TXT/CSV/XLSX file is read by this script.
# The official TÜİK table was first identified through tuikr::statistical_tables().
# Because the SDMX data endpoint returned HTTP 401 during testing, the official
# values from the TÜİK istab table are embedded directly below for reproducible rendering.

fetch_tuik_services_insufficient_demand <- function() {
  theme_id <- "9"
  theme_name <- "Short-Term Economic Indicators"
  dataset_name <- "Main factors limiting activities in services sector"
  table_name <- "Main factors limiting activities in services sector"
  selected_variable <- "Insufficient demand"
  data_frequency <- "Quarterly"
  dataflow_id <- "TR,DF_GUVEN_ENDEKS_FAALIYET_KISITLAMA_SDMX,1.0"

  table_url <- NA_character_
  source_note <- "The selected table was identified from TÜİK Data Portal."

  if (requireNamespace("tuikr", quietly = TRUE)) {
    tables <- tryCatch(tuikr::statistical_tables(theme_id), error = function(e) NULL)
    if (!is.null(tables)) {
      candidate <- tables |>
        dplyr::filter(
          stringr::str_detect(table_name, stringr::regex("Main factors limiting activities in services sector", ignore_case = TRUE))
        ) |>
        dplyr::slice(1)
      if (nrow(candidate) > 0) {
        table_url <- candidate$table_url[1]
        source_note <- "TÜİK table metadata was retrieved by tuikr::statistical_tables('9'). The official table values are embedded because tuikr::statistical_data() returned HTTP 401 for this SDMX dataflow during project preparation."
      }
    }
  }

  raw <- tibble::tribble(
    ~year, ~month, ~none, ~insufficient_demand, ~labour_shortage, ~space_equipment_shortage, ~financial_constraints, ~other_factors,
    2011, 1, 43.363943, 31.639829, 6.202391, 4.938155, 28.110151, 9.248435,
    2011, 4, 52.613742, 25.806984, 5.092839, 3.501327, 21.342588, 8.047339,
    2011, 7, 58.822908, 21.482318, 6.093542, 2.550231, 18.955922, 6.562276,
    2011, 10, 52.316441, 27.057457, 5.050290, 3.734599, 21.876416, 7.362963,
    2012, 1, 45.132545, 31.434655, 6.578367, 2.417402, 23.382262, 9.846493,
    2012, 4, 53.226454, 26.268401, 6.316789, 3.223516, 20.570266, 7.024986,
    2012, 7, 55.225794, 25.461899, 6.932416, 2.251623, 19.538275, 5.221505,
    2012, 10, 54.088981, 27.517415, 4.955243, 2.814189, 17.882670, 5.425626,
    2013, 1, 44.728380, 30.736454, 7.036564, 2.075533, 22.155896, 11.930098,
    2013, 4, 49.837144, 29.912721, 7.069378, 2.221569, 21.109032, 7.267585,
    2013, 7, 52.981756, 28.390219, 6.331573, 2.420177, 19.059909, 6.763456,
    2013, 10, 53.765016, 25.923427, 7.910219, 2.127800, 18.589826, 6.895047,
    2014, 1, 40.168721, 33.603516, 10.788542, 3.636298, 27.113197, 11.759941,
    2014, 4, 40.870959, 36.319187, 10.963474, 3.651634, 27.481546, 6.900388,
    2014, 7, 41.299384, 35.879254, 12.458906, 3.422776, 27.039934, 8.043525,
    2014, 10, 40.531668, 36.592595, 10.455027, 3.914197, 25.038846, 8.111659,
    2015, 1, 72.457108, 12.890193, 4.256900, 1.628078, 10.888703, 10.268839,
    2015, 4, 76.230014, 11.415463, 4.321149, 1.467283, 11.180697, 7.270388,
    2015, 7, 78.795990, 8.572913, 4.956782, 0.992806, 9.725147, 7.246757,
    2015, 10, 76.815758, 8.303602, 3.789661, 1.331503, 10.300856, 9.159568,
    2016, 1, 65.151503, 15.593775, 5.282884, 1.189421, 14.466142, 12.519817,
    2016, 4, 73.913104, 13.966911, 4.791622, 1.409301, 11.667526, 9.197541,
    2016, 7, 75.182414, 12.475150, 3.398962, 0.870016, 8.781267, 7.874385,
    2016, 10, 72.259747, 14.957760, 4.694389, 1.068945, 11.586470, 7.901225,
    2017, 1, 62.984911, 22.110783, 4.250574, 1.333666, 20.043991, 7.385860,
    2017, 4, 70.737355, 14.778125, 4.306209, 1.565894, 15.689054, 6.632465,
    2017, 7, 75.265939, 11.851123, 3.979855, 1.525611, 13.465176, 5.424395,
    2017, 10, 74.098986, 10.627197, 3.609097, 0.859662, 14.199240, 6.684611,
    2018, 1, 63.860335, 17.300738, 7.139371, 2.128605, 18.481570, 8.895081,
    2018, 4, 71.189403, 12.726245, 4.597675, 1.742910, 15.738775, 7.106864,
    2018, 7, 70.257154, 14.622434, 5.447574, 1.780647, 17.142503, 2.648336,
    2018, 10, 63.059683, 17.557956, 4.436269, 1.902372, 26.804730, 1.684067,
    2019, 1, 55.255824, 25.878192, 3.372960, 1.783312, 30.719762, 1.896282,
    2019, 4, 63.544486, 20.203792, 3.018510, 1.695967, 23.665743, 1.462577,
    2019, 7, 64.544683, 19.462475, 4.290573, 2.408607, 24.388115, 1.068771,
    2019, 10, 66.997282, 18.588442, 3.645694, 2.213457, 21.989047, 0.834833,
    2020, 1, 62.262654, 20.234040, 4.209557, 3.974823, 25.726807, 1.025004,
    2020, 4, 31.392772, 35.131602, 4.139938, 1.477913, 24.625953, 49.839510,
    2020, 7, 45.915163, 34.212312, 3.249120, 1.544801, 24.389390, 23.877255,
    2020, 10, 44.161114, 32.561143, 3.438971, 3.360342, 22.814692, 28.486543,
    2021, 1, 52.432010, 26.358422, 1.837746, 2.036094, 18.266251, 26.598073,
    2021, 4, 52.349078, 24.744158, 2.819856, 3.470858, 16.104971, 27.836166,
    2021, 7, 62.017949, 18.156901, 2.009894, 3.005850, 13.077902, 20.061702,
    2021, 10, 63.818598, 16.158179, 3.635136, 3.473467, 14.335291, 13.333192,
    2022, 1, 62.570000, 14.010000, 3.660000, 4.200000, 18.370000, 13.480000,
    2022, 4, 68.720000, 11.320000, 2.920000, 4.910000, 15.300000, 10.650000,
    2022, 7, 68.830000, 6.130000, 3.300000, 7.230000, 21.000000, 5.900000,
    2022, 10, 73.800000, 8.800000, 4.520000, 3.040000, 15.480000, 3.600000,
    2023, 1, 76.330000, 7.280000, 3.090000, 3.320000, 14.700000, 3.060000,
    2023, 4, 78.640000, 7.420000, 2.710000, 3.630000, 12.920000, 2.530000,
    2023, 7, 74.380000, 6.850000, 6.210000, 6.520000, 15.870000, 0.650000,
    2023, 10, 75.490000, 7.060000, 3.450000, 5.390000, 12.490000, 2.580000,
    2024, 1, 77.375196, 8.618711, 3.609731, 2.953320, 14.328068, 2.628952,
    2024, 4, 78.557841, 6.731522, 3.479947, 3.452925, 14.401274, 1.859659,
    2024, 7, 76.831451, 6.310514, 6.440829, 5.771243, 13.822220, 1.413882,
    2024, 10, 77.454580, 7.251512, 6.134349, 4.992077, 12.954171, 3.953777,
    2025, 1, 75.707371, 8.436036, 6.340788, 5.183789, 14.711978, 1.012308,
    2025, 4, 77.555392, 8.284888, 3.236451, 2.599677, 13.871566, 3.046435,
    2025, 7, 79.069970, 8.851800, 2.633438, 4.291990, 12.784395, 1.030823,
    2025, 10, 78.289726, 9.276220, 2.645012, 4.648568, 13.465620, 0.478929,
    2026, 1, 78.855580, 7.512736, 2.955862, 4.225476, 11.302474, 2.629876,
    2026, 4, 78.459715, 9.338132, 2.592176, 3.013560, 12.703112, 3.412801
  )

  series <- raw |>
    dplyr::mutate(
      quarter = dplyr::case_when(
        month == 1 ~ "Q1",
        month == 4 ~ "Q2",
        month == 7 ~ "Q3",
        month == 10 ~ "Q4",
        TRUE ~ NA_character_
      ),
      quarter_num = dplyr::case_when(month == 1 ~ 1L, month == 4 ~ 2L, month == 7 ~ 3L, month == 10 ~ 4L),
      obsTime = paste0(year, "-Q", quarter_num),
      date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
      value = insufficient_demand,
      t = dplyr::row_number()
    ) |>
    dplyr::select(date, obsTime, year, month, quarter, quarter_num, t, value,
                  none, insufficient_demand, labour_shortage,
                  space_equipment_shortage, financial_constraints, other_factors) |>
    dplyr::arrange(date)

  list(
    data = series,
    metadata = list(
      student_name = "Ömer Faruk ASLANER",
      student_number = "138722028",
      dataset_name = dataset_name,
      theme_category = theme_name,
      theme_id = theme_id,
      table_name = table_name,
      dataflow_id = dataflow_id,
      selected_variable = selected_variable,
      data_frequency = data_frequency,
      unit = "Percent (%)",
      time_coverage = paste0(min(series$obsTime), " / ", max(series$obsTime)),
      number_of_observations = nrow(series),
      latest_available_observation = max(series$obsTime),
      forecast_target_period = paste0(ifelse(max(series$quarter_num) == 4, max(series$year) + 1, max(series$year)), "-Q", ifelse(max(series$quarter_num) == 4, 1, max(series$quarter_num) + 1)),
      data_access_date = as.character(Sys.Date()),
      table_url = table_url,
      source_note = source_note
    )
  )
}
