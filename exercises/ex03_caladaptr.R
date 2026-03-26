## Load libraries

library(tidyverse)
library(caladaptr)
library(units)

## Create a Cal-Adapt API request object

ucm_cap <- ca_loc_pt(coords = c(-120.43, 37.36)) |> 
  ca_gcm(gcms[1:4]) |>   
  ca_scenario("rcp85") |> 
  ca_period("year") |> 
  ca_years(start = 2030, end = 2099) |> 
  ca_cvar(c("tasmin", "tasmax"))

## View it
ucm_cap

## Plot the request area
plot(ucm_cap, locagrid = TRUE)

## Do a preflight check
ca_preflight(ucm_cap)

## Fetch the data
ucm_tbl = ca_getvals_tbl(ucm_cap)

head(ucm_tbl)

## Add a column for degrees Fahrenheit

ucm_tasmax_degc_tbl <- ucm_tbl |>
  filter(cvar == "tasmax") |> 
  mutate(temp_c = set_units(val, degC))

head(ucm_tasmax_degc_tbl)

## Plot the data

ggplot(data = ucm_tasmax_degc_tbl, aes(x = as.Date(dt), y = as.numeric(temp_c))) +
  geom_line(aes(color=gcm)) +
  labs(title = "Average Maximum Daily Temperature Per Year for RCP4.5", 
       subtitle = "UC Merced",
       x = "year", 
       y = "temp (C)")

## Add a trend line

ggplot(data = ucm_tasmax_degc_tbl, aes(x = as.Date(dt), y = as.numeric(temp_c))) +
  geom_line(aes(color=gcm)) +
  geom_smooth(method=lm, formula = y ~ x) +
  labs(title = "Average Maximum Daily Temperature Per Year for RCP4.5", 
       subtitle = "UC Merced",
       x = "year", 
       y = "temp (C)")

## Challenge: Do the same for average daily minimum 


## PART 2: COMPUTE FUTURE CHILL
## Source: https://ucanr-igis.github.io/caladaptr-res/notebooks/chill.nb.html#2)_Fetch_Data_from_Cal-Adapt



