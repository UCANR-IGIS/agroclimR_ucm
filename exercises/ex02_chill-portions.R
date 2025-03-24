#################################
## Load packages

library(tidyverse)
library(units)
library(chillR)

################################
## Import Weather data for CIMIS Station 206
##  - see https://cimis.water.ca.gov/Stations.aspx
##  - more data available at https://fruitsandnuts.ucdavis.edu/station-data

stn206_dly_minmax_wyr25_tbl <- read_csv("exercises/data/stn206_dly_minmax_wyr25.csv")

head(stn206_dly_minmax_wyr25_tbl)

View(stn206_dly_minmax_wyr25_tbl)

range(stn206_dly_minmax_wyr25_tbl$dt)

################################
## Plot temperature

ggplot(stn206_dly_minmax_wyr25_tbl, aes(x = dt, y = tasmin_f)) +
  geom_line() +
  xlab("2024-25") +
  ylab("temp (F)") +
  labs(title = "Minimum Daily Temperature",
       subtitle = "CIMIS Station 206") 

###############################
## Chill portions
##  - see https://ucanr-igis.github.io/caladaptr-res/notebooks/chill.nb.html

## Step 1: Reformat the tibble for chillr

stn206_dly4chillr_tbl <- stn206_dly_minmax_wyr25_tbl |> 
  mutate(Year = as.integer(year(dt)), 
         Month = as.integer(month(dt)), 
         Day = day(dt),
         Tmax = as.numeric((tasmax_f - 32) * 5/9),
         Tmin = as.numeric((tasmin_f - 32) * 5/9)) |> 
  select(Year, Month, Day, Tmax, Tmin)

head(stn206_dly4chillr_tbl)

## Step 2: Model Hourly Temperature

stn206_hly_wide_tbl <- make_hourly_temps(latitude = 37.545869,
                                    year_file = stn206_dly4chillr_tbl,
                                    keep_sunrise_sunset = FALSE)
stn206_hly_wide_tbl |> head()

## Step 3: Go from wide to long
stn206_hly_long_tbl <- stn206_hly_wide_tbl |> 
  pivot_longer(cols = starts_with("Hour_"),
               names_to = "Hour",
               names_prefix = "Hour_",
               names_transform = list(hour = as.integer),
               values_to = "temp_c") |> 
  mutate(date_hour = ISOdatetime(Year, Month, Day, Hour, 0, 0, tz = "America/Los_Angeles")) %>%
  select(date_hour, temp_c) |> 
  arrange(date_hour)

head(stn206_hly_long_tbl)

## Step 4: Compute Chill Portions

stn206_hlychill_long_tbl <- stn206_hly_long_tbl |>  
  mutate(cp_dynamic = Dynamic_Model(stn206_hly_long_tbl$temp_c))

head(stn206_hlychill_long_tbl)

## Step 5: Plot them

ggplot(data = stn206_hlychill_long_tbl,
       aes(x = date_hour, y = cp_dynamic)) +
  geom_line(aes(color="red"), show.legend = FALSE) +
  labs(title = "Accumulated Chill Portions for Denair II (CIMIS Station 206)", 
       subtitle = "September 1, 2024 - March 22, 2025",
       x = "date", y = "Chill Portion") 

## When did we reach 23 chill portions?

ggplot(data = stn206_hlychill_long_tbl,
       aes(x = date_hour, y = cp_dynamic)) +
  geom_line(aes(color="red"), show.legend = FALSE) +
  geom_hline(yintercept = 23, color = "blue", size = 1) +
  labs(title = "Accumulated Chill Portions for Denair II (CIMIS Station 206)", 
       subtitle = "September 1, 2024 - March 22, 2025",
       x = "date", y = "Chill Portion") 

stn206_hlychill_long_tbl |> 
  filter(cp_dynamic >= 23) |> 
  slice(1:10)



