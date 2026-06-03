fetch_tuik_services_insufficient_demand <- function() {
  
  library(tidyr)
  library(tuikr)
  library(dplyr)
  library(stringr)
  library(httr)
  library(readxl)
  library(lubridate)
  
  theme_id <- "9"
  theme_name <- "Short-Term Economic Indicators"
  dataset_name <- "Main factors limiting activities in services sector"
  table_name_selected <- "Main factors limiting activities in services sector"
  selected_variable <- "Insufficient demand"
  data_frequency <- "Quarterly"
  dataflow_id <- "TR,DF_GUVEN_ENDEKS_FAALIYET_KISITLAMA_SDMX,1.0"
  
  tables9 <- tuikr::statistical_tables(theme_id)
  
  url_en <- tables9 %>%
    filter(node_type == "istab") %>%
    filter(table_name == "Main factors limiting activities in services sector") %>%
    slice(2) %>%
    pull(table_url)
  
  url <- gsub("/api/en/", "/api/tr/", url_en)
  
  session <- httr::handle("https://veriportali.tuik.gov.tr")
  
  httr::GET(
    "https://veriportali.tuik.gov.tr",
    handle = session
  )
  
  tmp <- tempfile(fileext = ".xls")
  
  res <- httr::GET(
    url,
    handle = session,
    httr::write_disk(tmp, overwrite = TRUE),
    httr::add_headers(
      "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
      "Referer" = "https://veriportali.tuik.gov.tr/"
    )
  )
  
  if (httr::status_code(res) != 200) {
    stop(paste("TÜİK istab download failed. HTTP status:", httr::status_code(res)))
  }
  
  raw_excel <- readxl::read_xls(tmp, col_names = FALSE)
  
  header_row <- which(apply(raw_excel, 1, function(x) {
    any(grepl("Yıl", as.character(x), ignore.case = TRUE)) &&
      any(grepl("Ay", as.character(x), ignore.case = TRUE))
  }))[1]
  
  if (is.na(header_row)) {
    print(head(raw_excel, 25))
    stop("Header row could not be detected. First rows were printed above.")
  }
  
  raw <- readxl::read_xls(tmp, skip = header_row - 1)
  
  names(raw) <- names(raw) %>%
    str_replace_all("\\n", " ") %>%
    str_squish()
  
  year_col <- names(raw)[grepl("Yıl|Year", names(raw), ignore.case = TRUE)][1]
  month_col <- names(raw)[grepl("Ay|Month", names(raw), ignore.case = TRUE)][1]
  demand_col <- names(raw)[grepl("Talep yetersizliği|Insufficient demand", names(raw), ignore.case = TRUE)][1]
  
  if (any(is.na(c(year_col, month_col, demand_col)))) {
    print(names(raw))
    stop("Required columns could not be detected.")
  }
  
  series <- raw %>%
    transmute(
      year = suppressWarnings(as.integer(.data[[year_col]])),
      month = suppressWarnings(as.integer(.data[[month_col]])),
      value = suppressWarnings(as.numeric(.data[[demand_col]]))
    ) %>%
    tidyr::fill(year, .direction = "down") %>%
    filter(!is.na(year), !is.na(month), !is.na(value)) %>%
    mutate(
      quarter_num = case_when(
        month == 1 ~ 1L,
        month == 4 ~ 2L,
        month == 7 ~ 3L,
        month == 10 ~ 4L,
        TRUE ~ NA_integer_
      ),
      quarter = paste0("Q", quarter_num),
      obsTime = paste0(year, "-Q", quarter_num),
      date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
      t = row_number()
    ) %>%
    filter(!is.na(quarter_num)) %>%
    arrange(date)
  
  latest_year <- max(series$year)
  latest_quarter <- series$quarter_num[which.max(series$date)]
  
  forecast_target_period <- if (latest_quarter == 4) {
    paste0(latest_year + 1, "-Q1")
  } else {
    paste0(latest_year, "-Q", latest_quarter + 1)
  }
  
  list(
    data = series,
    metadata = list(
      student_name = "Ömer Faruk ASLANER",
      student_number = "138722028",
      dataset_name = dataset_name,
      theme_category = theme_name,
      theme_id = theme_id,
      table_name = table_name_selected,
      dataflow_id = dataflow_id,
      selected_variable = selected_variable,
      data_frequency = data_frequency,
      unit = "Percent (%)",
      time_coverage = paste0(min(series$obsTime), " / ", max(series$obsTime)),
      number_of_observations = nrow(series),
      latest_available_observation = max(series$obsTime),
      forecast_target_period = forecast_target_period,
      data_access_date = as.character(Sys.Date()),
      table_url = url,
      source_note = "The TÜİK istab URL was identified through tuikr::statistical_tables('9'), converted from the English API endpoint to the Turkish API endpoint, downloaded during runtime with httr, and read directly into R as a temporary file."
    )
  )
}