# install.packages("taskscheduleR")
# Uruchom ponownie R
# Otwórz addind
# shedule r scripts in windows
# i postepuj zgodnie z
# https://anderfernandez.com/en/blog/how-to-automate-r-scripts-on-windows-and-mac/

# taskscheduleR::taskschedulerAddin()

library(taskscheduleR)
skrypt_air <- "D:\\qsync\\R\\R_API\\gios_api\\skrypt_2.R"

taskscheduler_create(taskname = "gios_api_import", 
                     rscript = skrypt_air,
                     schedule = "HOURLY", 
                     starttime = format(Sys.time() + 20, "%H:%M:%OS"),
                     startdate = format(Sys.time(), "%d/%m/%Y"))

# Proces uruchomiony, na dzień 03.11.2022
# starttime = "04:50",

# Zatrzymaj !!!

# system.file("extdata", "helloworld.R", package = "taskscheduleR")

# taskscheduleR::taskscheduler_stop(taskname = "gios_api_import")
               
# taskscheduleR::taskscheduler_delete(taskname = "gios_api_import")
