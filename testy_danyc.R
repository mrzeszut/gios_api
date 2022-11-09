library(tidyverse)
load("data_air_0.rdata")

test <- 
data_air %>% 
  mutate(dd = lubridate::day(date), 
         mm = lubridate::month(date)) %>% 
  group_by(id, mm, dd, key) %>% 
  summarise(n = n())



test_2 <- 
data_air %>% 
  filter(id == 9173, key == "PM10") %>% 
  openair::selectByDate(month = 11, day = 7)

metadane %>% unnest(data) %>% filter(id == 9173)

out <-
  id_sensor[30:40] %>%                                # Wczytanie wielu plików
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




metadane %>% unnest(data) %>% filter(id == 117)

# id i idsensor - nie aktualizuje się, trzeba dodac chyba dwa numery, by mieć pewność. hmn 

test <-  data_air %>% pivot_longer(SO2:C6H6)  
  
test <- 
  test[test %>% duplicated() %>% !.,] %>% ungroup() %>% 
  pivot_wider(names_from = "name", values_from = "value")

#  mutate(dd = lubridate::day(date), 
         mm = lubridate::month(date)) %>% 
    group_by(id, mm, dd) %>% 
    summarise(n = n())


# data_air %>% 
#   mutate(dd = lubridate::day(date), 
#          mm = lubridate::month(date)) %>% 
#   filter(id == 11, mm == 11, dd == 3) %>% print(n = 25)


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  