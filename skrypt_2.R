# ------------------------------------------------------------------------#
# Pakiety -----------------------------------------------------------------
# ------------------------------------------------------------------------#

if (!require(rjson))     { install.packages("rjson")     ; library(rjson)     }
if (!require(tidyverse)) { install.packages("tidyverse") ; library(tidyverse) }
if (!require(lubridate)) { install.packages("lubridate") ; library(lubridate) }

# ------------------------------------------------------------------------#
# PODSTAWOWE --------------------------------------------------------------
# ------------------------------------------------------------------------#

path_data <- "D:/qsync/R/R_API/gios_api/"

# Funkcja konwersji daty z lokalnego czasu na GMT

convert_to_gmt <- function(x) {
  
  # out <- dmy_hms(as.character(x), tz = "Europe/Warsaw") # konweryjemy tekst na data.local
  # out <- strftime(x = out, tz = "GMT", usetz = T) # Przekształcenie na GMT
  # out <- as.POSIXct(out, tz = "GMT")  # przekształcenie na obiekt klasy ddtm
  
  as.POSIXct(strftime(x = ymd_hms(as.character(x), 
                                  tz = "Europe/Warsaw"), 
                      tz = "GMT", usetz = T), 
             tz = "GMT") - 3600 -> out
  
  
  return(out)
}

# ------------------------------------------------------------------------#
# Metadane ----------------------------------------------------------------
# ------------------------------------------------------------------------#

load(file = paste0(path_data, "metadane_api_gios.rdata"))   # Metadane skrypt 1

id_sensor <- metadane %>% unnest(data) %>% distinct(id_sensor) %>% pull()

url <- "https://api.gios.gov.pl/pjp-api/rest/data/getData/" # ADRES API 

# ------------------------------------------------------------------------#
# Wczytywanie -------------------------------------------------------------
# ------------------------------------------------------------------------#

# Sys.getlocale() %>% separate(sep = ";")
# strsplit(Sys.getlocale(), split = ";") %>% as_vector()

# Dane są zapisywane w UTC+00

out <-
  id_sensor %>%                                # Wczytanie wielu plików
  map_dfr(
    ~ fromJSON(file = paste0(url, .x)) %>%     # import API
      as_tibble(.,
                validate = F) %>%
      unnest_wider(values) %>%
      mutate(id = metadane %>%
               unnest(data) %>%              # Dodajemy id do identyfikacji
               filter(id_sensor == .x) %>%
               first() %>%
               .[[1]])
  ) %>%                                        # Zmiana ukłądu danych
  pivot_wider(names_from = key,
              values_from = value) %>%         # Konwersja daty z local to GMT
  mutate(date = convert_to_gmt(date))

# Usuwamy ostatni rekrd danych, ponieważ lubi być pusty. 

rm_date <- out$date %>% max()

out <- 
out %>% 
  filter(!(date %in% c(rm_date, rm_date-3600))) 


# ------------------------------------------------------------------------#
# Zapisywanie -------------------------------------------------------------
# ------------------------------------------------------------------------#

write.csv(out,
          row.names = F,
          file = paste0(
            path_data,
            "csv_arh/",
            format(Sys.time(), "%Y_%m_%d_%H_%M"),
            ".csv"
          ))

# ------------------------------------------------------------------------#
# Baza danych -------------------------------------------------------------
# ------------------------------------------------------------------------#


# Laczenie, usuwanie podwojnych wierszy, 

load(file = paste0(path_data, "data_air.rdata"))

data_air <- bind_rows(data_air, out)

data_air <- data_air[data_air %>% duplicated() %>% !.,]

save(data_air, file = paste0(path_data, "data_air.rdata"))

# END 

Sys.time() 

rm(out, data_air, path_data, id_sensor, url, convert_to_gmt, metadane, null_to_na_recurse)
gc()
