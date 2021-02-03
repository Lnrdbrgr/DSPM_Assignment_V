#### Code for Assignment No. 5 in DSPM

## Leonard Berger




#### Exercise 2 - Gettin to know the API
rm(list = ls())


# Allowed: 5000 API calls per day and 5 requests per second


## Installing packages
# install.packages("jsonlite")
# install.packages("httr")
library(jsonlite)
library(httr)
library(rlist)



# set working directory
setwd("C:/Users/leona/OneDrive/Data Science Project Management/DSPM_Assignment_V")


# include API Key
source("C:/Users/leona/OneDrive/Uni Tübingen Data Science/1. Semester/Data Science Project Management/Assignment 5/API_key.R")







#### Exercise 3 - Interacting with the API

# contruct the API url with the API key searching for venues
api_url <- ("https://app.ticketmaster.com/discovery/v2/venues.json?")

# GET request
APIcontent <- GET(url = api_url,
                  query = list(apikey = API_key,
                               countryCode = "DE"))


venue_results <- content(APIcontent)


# The resulting List has three elements. The locations seem to be stored in _embedded/venues.
# There, the locations are listed with Name, Address, country, etc... The latitude and longitude
# is storred in location. The List element pages tells us that each page has 20 results listed,
# the total number of results is 4743 contained on 238 pages.



### Extracting name, city, postalCode, address, url, lat and long

venue_data <- data.frame("name" = rep(NA, 20),
                         "city" = rep(NA, 20),
                         "postalCode" = rep(NA, 20),
                         "address" = rep(NA, 20),
                         "url" = rep(NA, 20),
                         "longitude" = rep(NA, 20),
                         "latitude" = rep(NA, 20))


# how many results?
no_results <- venue_results$page$size


# extract the data from the list

for (i in 1:no_results){
  
  venue_data$name[i] <- venue_results$`_embedded`[[1]][[i]]$name
  venue_data$city[i] <- venue_results$`_embedded`[[1]][[i]]$city
  venue_data$postalCode[i] <- venue_results$`_embedded`[[1]][[i]]$postalCode
  venue_data$address[i] <- venue_results$`_embedded`[[1]][[i]]$address
  venue_data$url[i] <- venue_results$`_embedded`[[1]][[i]]$url
  
  # account for missing values in latitude and longitude
  if (!is.null(venue_results$`_embedded`[[1]][[i]]$location$longitude)){
    venue_data$longitude[i] <- venue_results$`_embedded`[[1]][[i]]$location$longitude
  }
  
  if (!is.null(venue_results$`_embedded`[[1]][[i]]$location$latitude)){
    venue_data$latitude[i] <- venue_results$`_embedded`[[1]][[i]]$location$latitude
  }
  
}


# perform some modification on the data types
venue_data$city <- as.character(venue_data$city)
venue_data$address <- as.character(venue_data$address)
venue_data$longitude <- as.numeric(venue_data$longitude)
venue_data$latitude <- as.numeric(venue_data$latitude)

# take a look on the data
dplyr::glimpse(venue_data)
## apparently, most venues have missing values when it comes to latitude and longitude































