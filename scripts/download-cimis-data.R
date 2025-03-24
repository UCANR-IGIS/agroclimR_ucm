## This script will download temperature data from CIMIS using the cimir package, and save it as csv.
## OK to source!

library(dplyr)
library(tidyr)
library(lubridate)
library(cimir)

## Set my API key
## (To get a CIMIS key, sign-up at https://cimis.water.ca.gov/Auth/Register.aspx)
# my_cimis_key <- "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" 

my_cimis_key <- Sys.getenv("MY_CIMIS_KEY")

cimir::set_key(my_cimis_key)

## Define the CIMIS station we want
## 
cimis_stn_id <- 206
cimis_stn_name <- "denair2"

## Define the start and end dates
start_date <- make_date(2024, 9, 1)
end_date <- Sys.Date() - 1

## Define the data directory
data_dir <- here::here("exercises/data")
dir.exists(data_dir)

## Define the CSV file name
dly_minmax_csv <- file.path(data_dir, "stn206_dly_minmax_wyr25.csv")
dly_minmax_csv
file.exists(dly_minmax_csv)

## Get the data
## Note 1. This should take <10 seconds. If it takes longer, the API may be down. Try in a few minutes.
## Note 2. CIMIS is updating their API in 2024, so this code may not work forever.

dly_minmax_long_tbl <- cimis_data(targets = cimis_stn_id, start.date = start_date, end.date = end_date,
                              items = "day-air-tmp-max,day-air-tmp-min")

## View the data
# head(dly_minmax_long_tbl)
# dim(dly_minmax_long_tbl)
# sapply(dly_minmax_long_tbl, class)
# dly_minmax_long_tbl |> head() |> View()

## Do a little cleaning and reshaping
dly_minmax_wide_tbl <- dly_minmax_long_tbl |>
  mutate(dt = ymd(Date)) |> 
  select(station_id = Station, dt, Item, Value) |>  
  pivot_wider(id_cols = c(station_id, dt), 
              names_from = Item, 
              values_from = Value) |> 
  rename(tasmax_f = DayAirTmpMax, tasmin_f = DayAirTmpMin) |> 
  relocate(tasmin_f, .before = tasmax_f)
  
## Inspect
head(dly_minmax_wide_tbl)

## Write the data to disk
write.csv(dly_minmax_wide_tbl, dly_minmax_csv, row.names = FALSE)

## DONE!!

