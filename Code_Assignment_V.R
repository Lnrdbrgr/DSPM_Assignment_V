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
library(ggplot2)



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
                               locale="*",
                               countryCode = "DE"))


venue_results_ex3 <- content(APIcontent)


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
no_results <- venue_results_ex3$page$size


# extract the data from the list
for (i in 0:no_results){
  
  venue_data$name[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$name
  venue_data$city[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$city
  venue_data$postalCode[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$postalCode
  venue_data$address[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$address
  venue_data$url[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$url
  
  # account for missing values in latitude and longitude
  if (!is.null(venue_results_ex3$`_embedded`[[1]][[i]]$location$longitude)){
    venue_data$longitude[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$location$longitude
  }
  
  if (!is.null(venue_results_ex3$`_embedded`[[1]][[i]]$location$latitude)){
    venue_data$latitude[i] <- venue_results_ex3$`_embedded`[[1]][[i]]$location$latitude
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






#### Exercise 4

# data frame to store results
venue_data <- data.frame("name" = NA,
                         "city" = NA,
                         "postalCode" = NA,
                         "address" = NA,
                         "url" = NA,
                         "longitude" = NA,
                         "latitude" = NA)





# get no. of pages we need to loop through
no_pages <- venue_results_ex3$page$totalPages

# contruct the API url with the API key searching for venues
api_url <- ("https://app.ticketmaster.com/discovery/v2/venues.json?")


for (i in 0:no_pages){
  
  # GET request
  APIcontent <- GET(url = api_url,
                    query = list(apikey = API_key,
                                 countryCode = "DE",
                                 locale="*",
                                 page = i))
  
  # get content
  venue_results <- content(APIcontent)
  
  # help data frame to store results
  venue_help_df <- data.frame("name" = rep(NA, 20),
                              "city" = rep(NA, 20),
                              "postalCode" = rep(NA, 20),
                              "address" = rep(NA, 20),
                              "url" = rep(NA, 20),
                              "longitude" = rep(NA, 20),
                              "latitude" = rep(NA, 20))
  
  
  # extract the data from the list
  for (j in 1:20){
    
    
    # account for missing values in latitude and longitude
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$name)){
      venue_help_df$name[j] <- venue_results$`_embedded`[[1]][[j]]$name
    }
    
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$city)){
      venue_help_df$city[j] <- venue_results$`_embedded`[[1]][[j]]$city
    }
    
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$postalCode)){
      venue_help_df$postalCode[j] <- venue_results$`_embedded`[[1]][[j]]$postalCode
    }
    
    
    if(length(venue_results$`_embedded`[[1]][[j]]$address)==0){
      venue_help_df$address[j] <- NA
    } else if (!is.null(venue_results$`_embedded`[[1]][[j]]$address)){
      venue_help_df$address[j] <- venue_results$`_embedded`[[1]][[j]]$address
    }
    
    
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$url)){
      venue_help_df$url[j] <- venue_results$`_embedded`[[1]][[j]]$url
    }
    
    
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$location$longitude)){
      venue_help_df$longitude[j] <- venue_results$`_embedded`[[1]][[j]]$location$longitude
    }
    
    if (!is.null(venue_results$`_embedded`[[1]][[j]]$location$latitude)){
      venue_help_df$latitude[j] <- venue_results$`_embedded`[[1]][[j]]$location$latitude
    }
    
  }
  
  # perform some modification on the data types
  venue_help_df$city <- as.character(venue_help_df$city)
  venue_help_df$address <- as.character(venue_help_df$address)
  venue_help_df$longitude <- as.numeric(venue_help_df$longitude)
  venue_help_df$latitude <- as.numeric(venue_help_df$latitude)
  
  
  # ignore efficiency for the time being and append the data frame
  venue_data <- rbind(venue_data, venue_help_df)
  
  
  # sleep for X seconds to stay in line with the guidelines
  Sys.sleep(0.33)
  
}


# make some modifications to the data frame
venue_data_2 <- venue_data[2:12221,]

glimpse(venue_data_2)



# adjust lat and long to extreme points of Germany
venue_data_2$longitude_mod <- ifelse((venue_data_2$longitude < 5.866944 | venue_data_2$longitude > 15.043611), NA, venue_data_2$longitude)
venue_data_2$latitude_mod <- ifelse((venue_data_2$latitude < 47.271679 | venue_data_2$latitude > 55.0846), NA, venue_data_2$latitude)




#### Visualization of event locations in Germany


## set up a map of germany which diplays the locations of the venues
ggplot() +
  geom_polygon(
    aes(x = long, y = lat, group = group), data = map_data("world", region = "Spain"),
    fill = "grey90",color = "black") +
  theme_void() + coord_quickmap() +
  labs(title = "Event locations across Germany", caption = "Source: ticketmaster.com") +
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic")) +
  geom_point(aes(x = longitude_mod,
                 y = latitude_mod),
             data = venue_data_2,
             alpha = 05,
             size = 0.7,
             col = "red")



## Set up the Same for Spain


# Perform the GET request examplary for the first page
APIcontent <- GET(url = api_url,
                  query = list(apikey = API_key,
                               locale = "*",
                               countryCode = "ES"))


APIcontent_Spain <- GET(url = api_url,
                        query = list(apikey = API_key,
                                     locale = "*",
                                     countryCode = "ES"))


venue_results_Spain <- content(APIcontent_Spain)


# extract the total number of Pages
no_pages_Spain <- venue_results_Spain$page$totalPages



### Extract all locations

## set up Data frame
venue_data_Spain <- data.frame("name" = NA,
                               "city" = NA,
                               "postalCode" = NA,
                               "address" = NA,
                               "url" = NA,
                               "longitude" = NA,
                               "latitude" = NA)


## loop through all pages and extract locations

for (i in 0:no_pages_Spain){
  
  # GET request
  APIcontent_Spain <- GET(url = api_url,
                          query = list(apikey = API_key,
                                       countryCode = "ES",
                                       locale="*",
                                       page = i))
  
  # get content
  venue_results_Spain <- content(APIcontent_Spain)
  
  # help data frame to store results
  venue_help_df_Spain <- data.frame("name" = rep(NA, 20),
                                    "city" = rep(NA, 20),
                                    "postalCode" = rep(NA, 20),
                                    "address" = rep(NA, 20),
                                    "url" = rep(NA, 20),
                                    "longitude" = rep(NA, 20),
                                    "latitude" = rep(NA, 20)) 
  
  
  # extract the data from the list
  for (j in 1:20){
    
    
    # account for missing values in latitude and longitude
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$name)){
      venue_help_df_Spain$name[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$name
    }
    
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$city)){
      venue_help_df_Spain$city[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$city
    }
    
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$postalCode)){
      venue_help_df_Spain$postalCode[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$postalCode
    }
    
    
    if(length(venue_results_Spain$`_embedded`[[1]][[j]]$address)==0){
      venue_help_df_Spain$address[j] <- NA
    } else if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$address)){
      venue_help_df_Spain$address[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$address
    }
    
    
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$url)){
      venue_help_df_Spain$url[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$url
    }
    
    
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$location$longitude)){
      venue_help_df_Spain$longitude[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$location$longitude
    }
    
    if (!is.null(venue_results_Spain$`_embedded`[[1]][[j]]$location$latitude)){
      venue_help_df_Spain$latitude[j] <- venue_results_Spain$`_embedded`[[1]][[j]]$location$latitude
    }
    
  }
  
  # perform some modification on the data types
  venue_help_df_Spain$city <- as.character(venue_help_df_Spain$city)
  venue_help_df_Spain$address <- as.character(venue_help_df_Spain$address)
  venue_help_df_Spain$longitude <- as.numeric(venue_help_df_Spain$longitude)
  venue_help_df_Spain$latitude <- as.numeric(venue_help_df_Spain$latitude)
  
  
  # ignore efficiency for the time being and append the data frame
  venue_data_Spain <- rbind(venue_data_Spain, venue_help_df_Spain)
  
  
  # sleep for X seconds to stay in line with the guidelines
  Sys.sleep(0.33)
  
}



write.csv(venue_data_Spain, "venue_data_spain.csv")


## make some modifications to the resulting data frame
venue_data_Spain_2 <- venue_data_Spain[-1,] 

glimpse(venue_data_Spain_2)


# adjust lat and long to extreme points of Spain
venue_data_Spain_2$longitude_mod <- ifelse((venue_data_Spain_2$longitude < -9.3 | venue_data_Spain_2$longitude > 3.316667), NA, venue_data_Spain_2$longitude)
venue_data_Spain_2$latitude_mod <- ifelse((venue_data_Spain_2$latitude < 36 | venue_data_Spain_2$latitude > 43.783333), NA, venue_data_Spain_2$latitude)



## set up a map of Spain which diplays the locations of the venues
ggplot() +
  geom_polygon(
    aes(x = long, y = lat, group = group), data = map_data("world", region = "Spain"),
    fill = "grey90",color = "black") +
  theme_void() + coord_quickmap() +
  labs(title = "Event locations across Spain", caption = "Source: ticketmaster.com") +
  theme(title = element_text(size=8, face='bold'),
        plot.caption = element_text(face = "italic")) +
  geom_point(aes(x = longitude_mod,
                 y = latitude_mod),
             data = venue_data_Spain_2,
             alpha = 0.5,
             size = 0.7,
             col = "red")

















