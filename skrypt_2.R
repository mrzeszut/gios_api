# ------------------------------------------------------------------------#
# Pakiety -----------------------------------------------------------------
# ------------------------------------------------------------------------#

if (!require(rjson))     { install.packages("rjson")     ; library(rjson)     }
if (!require(tidyverse)) { install.packages("tidyverse") ; library(tidyverse) }
if (!require(lubridate)) { install.packages("lubridate") ; library(lubridate) }

a <- Sys.time() ; a
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
               .[[1]],
             id_sensor = .x)
  ) %>% 
  mutate(date = convert_to_gmt(date)) %>% 
  na.omit()

# Usuwamy ostatni rekrd danych, ponieważ lubi być pusty. 

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

load(file = paste0(path_data, "data_air_1.rdata"))

data_air <- bind_rows(data_air, out)

data_air <- data_air[data_air %>% duplicated() %>% !.,]

save(data_air, file = paste0(path_data, "data_air_1.rdata"))

# END 

b <- Sys.time() ; b 
a-b

rm(out, data_air, path_data, id_sensor, url, convert_to_gmt, metadane, null_to_na_recurse, a, b)
gc()
