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

ucm_tasmax_degf_tbl <- ucm_tbl |>
  filter(cvar == "tasmax") |> 
  mutate(temp_f = set_units(val, degF))

head(ucm_tasmax_degf_tbl)

## Plot the data

ggplot(data = ucm_tasmax_degf_tbl, aes(x = as.Date(dt), y = as.numeric(temp_f))) +
  geom_line(aes(color=gcm)) +
  labs(title = "Average Maximum Daily Temperature Per Year for RCP4.5", 
       subtitle = "UC Merced",
       x = "year", 
       y = "temp (F)")

## Add a trend line

ggplot(data = ucm_tasmax_degf_tbl, aes(x = as.Date(dt), y = as.numeric(temp_f))) +
  geom_line(aes(color=gcm)) +
  geom_smooth(method=lm, formula = y ~ x) +
  labs(title = "Average Maximum Daily Temperature Per Year for RCP4.5", 
       subtitle = "UC Merced",
       x = "year", 
       y = "temp (F)")

## Challenge: Do the same for average daily minimum 


## PART 2: COMPUTE FUTURE CHILL
## Source: https://ucanr-igis.github.io/caladaptr-res/notebooks/chill.nb.html#2)_Fetch_Data_from_Cal-Adapt

pt1_dyr_tbl <- pt1_tbl %>%
  mutate(DATE = as.POSIXct(format(dt), tz="America/Los_Angeles")) %>%
  mutate(Year = as.integer(year(DATE)), 
         Month = as.integer(month(DATE)), 
         Day = day(DATE),
         temp_c = as.numeric(temp_c)) %>%
  select(cvar, temp_c, Year, Month, Day) %>%
  pivot_wider(names_from = cvar, values_from = temp_c) %>%
  rename(Tmax = tasmax, Tmin = tasmin)

head(pt1_dyr_tbl)




###############################
## Chill portions




