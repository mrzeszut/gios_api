# gios_api
Project of automatic data download via API from the Air Quality Portal for
Poland


## Wprowadznie

Projekt składa się z 3 skryptów. 

* skrypt_0 - uruchamia proces automatycznego pobierania danych 
* skrypt_1 - przygotowanie metadanych do skrypt_2
* skrypt_2 - skrypt pobierania danych z gioś API 

W pierwszej kolejności należy przećwiczyć i zrozumieć działanie skryptu 1 i 2.
Poprawić ścieżki dostępu. Następnie można próbować uruchomić skrypt 0 w celu
uruchomienia procesu. W tym przypadku skrypt uruchamia się raz dziennie. Pobiera
dane o jakości powietrza z wszystkich stacji zlokalizowanych w Polsce. Dane
zapisuje w plikach csv. Pliki csv są potrzebne tylko w celu ewentualnego
sprawdzenia danych (etap wdrożeniowy). Pobrane dane są zapisywane wpliku
**data_air.rdata**. Ten plik jest codziennie aktualizowany. 

## Co dalej ...

* utworzenie bazy danych (Postgres SQL - udostępnienie jej w ramach sieci AGH)
* Napisanie API dla ERA5 (prognozy i re-analizy)
* Napisanie API dla danych z IMGW lub ftjagh ? Jest kilka znakóW zapytania.
* Stworzenie aplikacji prezentujacych dane w ciekawej i interesującej formie.
Może nawet kilka różnych aplikacji (wykresy wielu parametrów, mapa itd.).


## CEL

Utworzenie modelu prognoz Jakości Powietrza zgodnie z przykładem
[bike_predict](https://github.com/sol-eng/bike_predict). Wiecje można przeczytać
na [Blogu Rstudio] (https://www.rstudio.com/blog/update-your-machine-learning-pipeline-with-vetiver-and-quarto/)



