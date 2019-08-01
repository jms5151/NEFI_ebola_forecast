# download up-to-date ebola data from web and format data --------------------- 
rm(list=ls()) #remove previous variable assignments

# URL links
urls <- c("https://docs.google.com/spreadsheets/d/e/2PACX-1vSrr9DRaC2fXzPdmOxLW-egSYtxmEp_RKoYGggt-zOKYXSx4RjPsM4EO19H7OJVX1esTtIoFvlKFWcn/pub?gid=0&single=true&output=csv",
          "https://docs.google.com/spreadsheets/d/e/2PACX-1vSrr9DRaC2fXzPdmOxLW-egSYtxmEp_RKoYGggt-zOKYXSx4RjPsM4EO19H7OJVX1esTtIoFvlKFWcn/pub?gid=1564028913&single=true&output=csv")

# names for data at country and zone levels
csvNames <- c("ebola_country", "ebola_zone")

# download data from URLS, format date and class, and rename dataset
for (i in 1:length(csvNames)){
  x <- read.csv(url(urls[i]), stringsAsFactors = F) # read in data
  x <- x[2:nrow(x),] # remove metadata in first row
  x$report_date <- as.Date(x$report_date, "%Y-%m-%d")
  colIndexes <- grep("cases$|change$|cured$|deaths$",colnames(x))
  x[,colIndexes] <- lapply(x[,colIndexes], as.numeric)
  assign(csvNames[i], x)
}

# remove temporary file
 x <- NULL

# aggregate to health zone and weekly cases ----------------------------------
library(lubridate)
library(dplyr)

# remove negative case values
ebola_zone$confirmed_cases_change[ebola_zone$confirmed_cases_change<0] <- NA 

# aggregate by health zone and week
ebola <- ebola_zone %>% 
  group_by(health_zone, week = cut(report_date + 1, "week")) %>% 
  summarise(confirmed_cases = sum(confirmed_cases_change, na.rm = T))

# keep provinces with > 100 cases   
provincesToKeep <- ebola_zone %>% 
  group_by(health_zone) %>%
  summarise(confirmed_cases = sum(confirmed_cases_change, na.rm = T))

provincesToKeep <- subset(provincesToKeep, confirmed_cases > 100)   

ebola <- ebola[ebola$health_zone %in% unique(provincesToKeep$health_zone),]

