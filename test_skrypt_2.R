
if (!require(rjson))     { install.packages("rjson")     ; library(rjson)     }
if (!require(tidyverse)) { install.packages("tidyverse") ; library(tidyverse) }
if (!require(lubridate)) { install.packages("lubridate") ; library(lubridate) }

a <- Sys.time() ; a
# ------------------------------------------------------------------------#
# PODSTAWOWE --------------------------------------------------------------
# ------------------------------------------------------------------------#

path_data <- "D:/Qnap/R/R_API/gios_api/"

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

# Wczytywanie -------------------------------------------------------------
.x =id_sensor[100]


out1
fromJSON(file = paste0(url, .x)) %>%     # import API
  as_tibble(.,
            validate = F) %>%
  unnest_wider(values) 



%>%
  mutate(id = metadane %>%
           unnest(data) %>%              # Dodajemy id do identyfikacji
           filter(id_sensor == .x) %>%
           first() %>%
           .[[1]],
         id_sensor = .x)
) %>% 
  mutate(date = convert_to_gmt(date)) %>% 
  na.omit()




out <-
  id_sensor %>%                                # Wczytanie wielu plików
  map_dfr(
    ~ fromJSON(file = paste0(url, .x)) %>%     # import API
      as_tibble(.,
                validate = F) %>%
      unnest_wider(values)) 
    
    
    
    %>%
      mutate(id = metadane %>%
               unnest(data) %>%              # Dodajemy id do identyfikacji
               filter(id_sensor == .x) %>%
               first() %>%
               .[[1]],
             id_sensor = .x)
  ) %>% 
  mutate(date = convert_to_gmt(date)) %>% 
  na.omit()

