
data_air %>% 
  mutate(dd = lubridate::day(date), 
         mm = lubridate::month(date)) %>% 
  group_by(id, mm, dd) %>% 
  summarise(n = n())


# data_air %>% 
#   mutate(dd = lubridate::day(date), 
#          mm = lubridate::month(date)) %>% 
#   filter(id == 11, mm == 11, dd == 3) %>% print(n = 25)

.x = id_sensor[1]
out <-
  id_sensor[1:10] %>%                                # Wczytanie wielu plików
  map_dfr(
    ~ fromJSON(file = paste0(url, .x)) %>%     # import API
      as_tibble(.,
                validate = F) %>%
      unnest_wider(values) %>%
      mutate(id = metadane %>%
               unnest(data) %>%              # Dodajemy id do identyfikacji
               filter(id_sensor == .x) %>%
               first() %>%
               .[[1]]) %>% na.omit()
  )

out %>% 
  pivot_wider(names_from = key,
              values_from = value) %>%         # Konwersja daty z local to GMT
  mutate(date = convert_to_gmt(date))

# Usuwamy ostatni rekrd danych, ponieważ lubi być pusty. 


rm_date <- out$date %>% max()

out <- 
  out %>% 
  filter(!(date %in% c(rm_date, rm_date-3600))) 