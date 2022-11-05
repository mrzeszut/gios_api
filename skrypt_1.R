# https://hendrikvanb.gitlab.io/2018/07/nested_data-json_to_tibble/
# https://anderfernandez.com/en/blog/how-to-automate-r-scripts-on-windows-and-mac/
# https://powietrze.gios.gov.pl/pjp/content/api

if (!require(rjson))     { install.packages("rjson")     ; library(rjson)     }
if (!require(tidyverse)) { install.packages("tidyverse") ; library(tidyverse) }

# Funkcje -----------------------------------------------------------------

# Funkcja usuwa NULL z JSON - niestey R nie kuma NULL w json. Musi być NA.

null_to_na_recurse <- function(obj) {
  if (is.list(obj)) {
    obj <- jsonlite:::null_to_na(obj)
    obj <- lapply(obj, null_to_na_recurse)
  }
  return(obj)
}

# Metadane

air_stat_to_df <- function(data, x) {
  bind_cols(
    data[[x]] %>% as_tibble(),
    data[[x]] %>% as_tibble() %>%
      .$city %>% as_tibble() %>%
      .$commune %>% as_tibble()
  ) %>% select(
    id,
    stationName,
    gegrLat,
    gegrLon,
    addressStreet,
    communeName,
    districtName,
    provinceName
  ) %>% .[1, ] %>% mutate(addressStreet = as.character(addressStreet))
  
}

# Stanowiska 

air_stan_to_df <- function(i) {
  
  url <- "https://api.gios.gov.pl/pjp-api/rest/station/sensors/"
  
  out <- fromJSON(file = paste0(url, i)) %>%
    null_to_na_recurse()
  
  out <-
    1:length(out) %>%
    map_df(~ bind_cols(
      id_sensor = out[[.x]]$id,
      out[[.x]] %>% as_tibble() %>%
        pull(param) %>% as_tibble()
    ))
  
  out <- bind_cols(id = i, out)
  
}

# Stcaje -------------------------------------------------------------------

result <- fromJSON(file = "http://api.gios.gov.pl/pjp-api/rest/station/findAll") 

result <- null_to_na_recurse(result)

stacje <- 
1:length(result) %>% 
  map_dfr(~air_stat_to_df(x = .x, data = result)) %>% 
  select(-stationName) %>% 
  mutate(gegrLat = as.numeric(gegrLat),   
         gegrLon = as.numeric(gegrLon))

rm(result)

colnames(stacje) <- c("id", "lat", "lon", "ul", "miasto", "pow", "woj")

# Stanowiska --------------------------------------------------------------

stanowiska <- 
stacje$id %>% 
  map_dfr(air_stan_to_df, .x = .)

colnames(stanowiska) <- c("id", "id_sensor", 
                          "sub_nazwa", "sub_form", "sub_kod", "is_sub")

# Laczenie ----------------------------------------------------------------

metadane <- full_join(stacje, stanowiska, by = "id") %>% 
  nest(data = !c("id", "lat", "lon", "ul", "miasto", "pow", "woj"))

# rm(stanowiska)

save(stacje, stanowiska, metadane, null_to_na_recurse, file = "metadane_api_gios.rdata")

rm(air_stan_to_df, air_stat_to_df, metadane, null_to_na_recurse, stanowiska)
gc()




