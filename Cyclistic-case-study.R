# Cyclistic case study using R
In this case study, I used historical data from a Chicago based bike-share company to analyze and identify trends on how their casual riders and annual members use Cyclistic bikes differently.

## Scenario
Cyclistic is a bike-share company located in Chicago. Cyclistic has two types of customers; those who purchase single-ride or full-day passes, casual riders, and those who purchase annual memberships, members. The marketing director believes the future success of the company depends on maximizing the number of annual memberships. The marketing analytics team wants to understand how causal riders and members use Cyclistic bikes differently. From these insights, the team will design a new marketing strategy to convert casual riders into annual members.

## Defining the problem
Moreno, the director of marketing, states the main problem is designing marketing strategies aimed at converting Cyclistic’s casual riders into annual members. I am tasked with answering the following question: How do annual members and casual riders use Cyclistic bikes differently? Answering this question will give the marketing analytics team a better understanding of the differences between the two groups. The marketing analytics team will use these insights to design new marketing strategies for converting casual riders into annual members.

## Business task
To use historical bike trip data to identify and analyze trends on how annual members and casual riders use Cyclistic bikes differently.

## Data sources
I will be using Cyclstic’s historical bike trip data from the last 12 months, which is publicly available. The data is made by Motivate international Inc. The data can be found *[here](https://divvy-tripdata.s3.amazonaws.com/index.html)*
  
  The data seems to be structured; it is organized by rows and columns. Each record represents one trip, and each trip has a unique field that identifies the trip: ride_id. Each trip is anonymized and includes the following fields:
  
  Ride_id	Ride | id – unique  
Rideable_type	| Bike type – classic, docked, electric  
Started_at | Trip start day and time  
Ended_at | Trip end day and time  
Start_station_name | Trip start station  
Start_station_id | Trip start station id  
End_station_name | Trip end station  
End_station_id | Trip end station id  
Start_lat	Trip | start latitude  
Start_lng	Trip | start longitude  
End_lat	Trip | end latitude  
End_lng	Trip | end longitude  
Member_casual	| Rider type – member or casual  

### Step 1: install and load necessary packages

```{r error=FALSE, warning=FALSE, message=FALSE}
library(tidyverse)
library(janitor)
library(geosphere)
```

### Step 2: import data into R

```{r}
m2_2022 <- read.csv("C:/Users/desto/.../202202-divvy-tripdata.csv")
m3_2022 <- read.csv("C:/Users/desto/.../202203-divvy-tripdata.csv")
m4_2022 <- read.csv("C:/Users/desto/.../202204-divvy-tripdata.csv")
m5_2022 <- read.csv("C:/Users/desto/.../202205-divvy-tripdata.csv")
m6_2022 <- read.csv("C:/Users/desto/.../202206-divvy-tripdata.csv")
m7_2022 <- read.csv("C:/Users/desto/.../202207-divvy-tripdata.csv")
m8_2022 <- read.csv("C:/Users/desto/.../202208-divvy-tripdata.csv")
m9_2022 <- read.csv("C:/Users/desto/.../202209-divvy-publictripdata.csv")
m10_2022 <- read.csv("C:/Users/desto/.../202210-divvy-tripdata.csv")
m11_2022 <- read.csv("C:/Users/desto/.../202211-divvy-tripdata.csv")
m12_2022 <- read.csv("C:/Users/desto/.../202212-divvy-tripdata.csv")
m1_2023 <- read.csv("C:/Users/desto/.../202301-divvy-tripdata.csv")
```

* **check for consistency** 
  ```{r}
colnames(m2_2022)
colnames(m3_2022)
colnames(m4_2022)
colnames(m5_2022)
colnames(m6_2022)
colnames(m7_2022)
colnames(m8_2022)
colnames(m9_2022)
colnames(m10_2022)
colnames(m11_2022)
colnames(m12_2022)
colnames(m1_2023)
```

* **check data structures**
  ```{r}
str(m2_2022)
str(m3_2022)
str(m4_2022)
str(m5_2022)
str(m6_2022)
str(m7_2022)
str(m8_2022)
str(m9_2022)
str(m10_2022)
str(m11_2022)
str(m12_2022)
str(m1_2023)
```

### Step 3: combine data set into single data frame

```{r}
trip_data <- bind_rows(m2_2022, m3_2022, m4_2022, m5_2022, m6_2022, m7_2022, m8_2022, m9_2022, m10_2022, m11_2022, m12_2022, m1_2023)
```

* **check merged data frame**
  ```{r}
colnames(trip_data) # extract list of column names 
str(trip_data) # extract list of columns and data types 
summary(trip_data) # extract statistical summary of data 
head(trip_data) # extract first 6 rows of data frame
nrow(trip_data) # extract number of rows in data frame 
dim(trip_data) # extract dimensions of data frame 
```

### Step 4: remove unnecessary data and add data to prep for analysis

* **check unique output values** 
  ```{r}
table(trip_data$member_casual)
table(trip_data$rideable_type)
```


* **add date, month, year, day of week columns** 
  ```{r}
trip_data$date <- as.Date(trip_data$started_at) 
trip_data$month <- format(as.Date(trip_data$date), "%m")
trip_data$day <- format(as.Date(trip_data$date), "%d")
trip_data$year <- format(as.Date(trip_data$date), "%Y")
trip_data$day_of_week <- format(as.Date(trip_data$date), "%A")
colnames(trip_data)
```

* **add ride_length column**
  ```{r}
trip_data$ride_length <- difftime(trip_data$ended_at, trip_data$started_at)
```

* **convert ride_length to numeric for calculations later**
  ```{r}
trip_data$ride_length <- as.numeric(as.character(trip_data$ride_length)) 
is.numeric(trip_data$ride_length) # verify right format  

trip_data$ride_distance <- distGeo(matrix(c(trip_data$start_lng, trip_data$start_lat), ncol=2), matrix (c(trip_data$end_lng, trip_data$end_lat), ncol=2))
trip_data$ride_distance <- trip_data$ride_distance/1000 #distance in km
glimpse(trip_data) # extract column names and data
```

* **check for negative ride_length data**
  ```{r}
sum(trip_data$ride_length <= 0)
```

* **remove negative ride_length data**
  ```{r}
trip_data <- trip_data[!(trip_data$ride_length <= 0),]
```

* **verify 0 entries for negative ride_length**
  ```{r}
sum(trip_data$ride_length <= 0)
```

* **the rideable_type, "docked_bike" is not being used by either member or casual riders so entries can be omitted from data frame**
  ```{r}
updated_trip_data <- trip_data[!(trip_data$rideable_type == "docked_bike" | trip_data$ride_length<0),]
glimpse(updated_trip_data) # extract every column in data frame
```

### Step 5: analyze clean data

* **find mean, median, max, and min**
  + Mean – straight average (total ride length/total rides)  
+ Median – midpoint number of ride length  
+ Max – longest ride  
+ Min – shortest ride  

```{r}
updated_trip_data %>%
  group_by(member_casual) %>%
  summarise(number_of_rides = n()
            ,average_ride_length = mean(ride_length), median_length = median(ride_length), max_ride_length = max(ride_length), min_ride_length = min(ride_length))
```

* **calculate total number of rides**
  ```{r}
updated_trip_data %>%
  group_by(member_casual) %>%
  summarise(ride_count = length(ride_id))
```

* **calculate total rides and average ride time by each day for members and casual riders**
  ```{r}
updated_trip_data %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(),
            average_ride_length = mean(ride_length),.groups = "drop")
```

* **Visualize total rides taken by members and casual riders**
  ```{r}
updated_trip_data %>%
  group_by(member_casual) %>%
  summarise(ride_count = length(ride_id)) %>%
  ggplot() + geom_col(mapping = aes(x = member_casual, y = ride_count, fill = member_casual), show.legend = FALSE) +
  labs(title = "Total rides")
```

Based on the data represented on the graph, we can see that member riders used Cyclistic’s bikes about 30% more frequently than casual riders.  


* **Visualize comparison of total rides with the type of ride**
  ```{r}
updated_trip_data %>%
  group_by(member_casual, rideable_type) %>%
  summarise(number_of_rides = n(), .groups = "drop") %>%
  ggplot() + geom_col(mapping = aes(x = rideable_type, y = number_of_rides, fill = member_casual), show.legend = TRUE) +
  labs(title = "Total rides vs. Ride type")
```

We can see that member riders slightly prefer classic bikes over electric ones whereas casual riders prefer electric ones.  


* **put days of the week in order**
  ```{r}
updated_trip_data$day_of_week <- ordered(updated_trip_data$day_of_week, 
                                         levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
```

* **Visualize the days of the week with no. of rides taken by riders**               
  ```{r}
updated_trip_data %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), .groups = "drop") %>%
  arrange(member_casual, day_of_week) %>%
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  labs(title = "Total rides vs. Day of the week") +
  geom_col(width = 0.5, position = position_dodge(width = 0.5)) +
  scale_y_continuous(labels = function(x) format(x,scientific = FALSE))
```

The graph depicts a relationship between the total rides and the day of the week. The lowest total for member riders is Sunday. The highest total for member riders is from Tuesday to Thursday. The lowest total for casual riders is from Monday to Wednesday. The highest total for casual riders is Saturday.   
This means that the busiest days for members would be Tuesday to Thursday, with their slowest being Sunday. For casual riders, their busiest days would be Saturday and Sunday and their slowest days would be Monday to Wednesday.  


* **Visualize average ride by day of the week**
  ```{r}
updated_trip_data %>%
  group_by(member_casual, day_of_week) %>%
  summarise(average_ride_length = mean(ride_length), .groups = "drop") %>%
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  geom_col(width = 0.5, position = position_dodge(width = 0.5)) +
  labs(title = "Average ride length vs. Day of the week")
```

Based on the graph, we can see that member riders overall maintain a consistent average time throughout the week with a slight drop in average time during the weekends. Casual riders, in general, spend more time on the bikes with their longest average time being on the weekends and their lowest being Wednesday.   
It can be concluded that because casual riders’ average ride length is significantly longer than member riders, they also travel longer distances, making those days busier than usual.  


* **Visualize average rides by month**
  ```{r}
updated_trip_data %>%
  group_by(member_casual, month) %>%
  summarise(average_ride_length = mean(ride_length), .groups = "drop") %>%
  ggplot(aes(x = month, y = average_ride_length, fill = member_casual)) +
  geom_col(width = 0.5, position = position_dodge(width = 0.5)) +
  labs(title = "Average ride length vs. Month")
```

Average ride length for members is fairly consistent with times ranging from 600 seconds to 850 seconds, with the month of June being the longest average ride length. For casual riders, their average ride length ranges between 850 seconds to 1500 seconds, with May being the month with the longest average ride length.


* **Visualize and compare casual and member rides by distance**
  ```{r}
updated_trip_data %>%
  group_by(member_casual) %>%
  summarise(average_ride_distance = mean(ride_length)) %>%
  ggplot() + geom_col(mapping = aes(x = member_casual, y = average_ride_distance, fill = member_casual), show.legend = FALSE) +
  labs(title = "Mean distance traveled")
```

From the graph, we can see that casual riders, compared to member riders, almost doubled their distance traveled. Member rides averaged just above 750km while casual riders averaged slightly above 1250km.

### Step 6: Share findings

This phase will be done with a presentation to the stakeholders.  

The presentation will include these main insights and findings:      
  * Members hold the biggest portion of the total rides, about 30% more than casual riders  
* Casual riders prefer electric bikes over classic bikes  
* The busiest days for casual riders are the weekends  
* Casual riders have the longest average ride length and the largest mean distance traveled despite being the smaller group  
* Casual riders prefer using the bikes during the weekends rather than the weekdays  

#### Recommendations  
1. Marketing and Promotional/Discount campaigns  
* Monthly market emails  
+ Provide information on the benefits of being an annual member  
* Discounts
+ The company can offer discounts on a daily, weekly, or monthly basis or based on usage or distanced traveled    
2. Host ride events  
* Host ride events on weekends as they are the most popular days for casual riders and offer member benefits and/or free member trial as prizes   
3. Offer a weekend-only membership  
* Since casual riders are more active during the weekends it might be a good idea to offer weekend membership passes to encourage them to upgrade their membership status  

### Step 7: Act
Ultimately, this stage will be left to the stakeholders and the marketing director to decide after hearing my recommendations.
