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
                               countryCode="DE"))


venue_results <- content(APIcontent)



















