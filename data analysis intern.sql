use orders;
select * from dataset;

-- Task 1: Top Cuisines
-- Determine the top three most common cuisines in the dataset.
 select Cuisines,count(Cuisines) as most_common_Cuisines 
 from dataset 
 group by Cuisines order by most_common_Cuisines desc limit 3;
 
 --  Calculate the percentage of restaurants that serve each of the top cuisines.
WITH cte AS (SELECT Restaurant_Name,COUNT(*) AS no_of_orders FROM dataset GROUP BY Restaurant_Name),
cuisine_counts AS (SELECT Restaurant_Name,Cuisines,COUNT(*) AS cuisine_orders FROM dataset GROUP BY Restaurant_Name, Cuisines)
SELECT cc.Restaurant_Name,cc.Cuisines,ROUND(100.0 * cc.cuisine_orders / c.no_of_orders, 2) AS percentage_cuisines
FROM cuisine_counts cc
JOIN cte c ON cc.Restaurant_Name = c.Restaurant_Name
ORDER BY percentage_cuisines asc
LIMIT 3;

-- Task 2: City Analysis

-- Identify the city with the highest number of order in the dataset.
select city, count(*) as no_orders_in_cities from dataset 
group by city order by no_orders_in_cities desc limit 3;

--  Identify the city with the highest number of restaurants in the dataset.
select City,count(distinct Restaurant_Name)as number_of_restaurants 
from dataset 
group by City order by number_of_restaurants desc limit 3;

-- Calculate the average rating for restaurants in each city
SELECT City,Restaurant_Name,ROUND(AVG(Aggregate_rating),1) AS avg_rating_in_city
FROM dataset
GROUP BY City, Restaurant_Name
ORDER BY avg_rating_in_city DESC, Restaurant_Name limit 3;

--  Determine the city with the highest average rating.
select City, round(avg(Aggregate_rating),2) as avg_rating 
from dataset group by city order by avg_rating desc limit 5;

-- Percentage of a Restaurant’s Orders in Its City
with cte as (select City,Restaurant_Name, count(*) as nor from dataset group by City,Restaurant_Name ), 
cte1 as (select city , count(*) as noc from dataset group  by city) 
select c.city,c.Restaurant_Name , 100.0 *c.nor/c1.noc as rating_restaurants_incity from cte as c
join cte1 as c1 on c.city=c1.city order by  rating_restaurants_incity desc,Restaurant_Name limit 3;

--  Task 3: Price Range Distribution
-- Calculate the percentage of restaurants in each price range category.
select Price_range, concat(round(100.00*count(*)/(select count(*) from dataset),2),'%')as percent_restaurants_each_pricce_rating  
from dataset group  by Price_range order by Price_range asc;

-- the distribution of price ranges among the restaurants
SELECT Price_range, COUNT(*) AS restaurant_count FROM dataset GROUP BY Price_range order by Price_range ;

-- Task 4: Online Delivery
-- Compare the average ratings of restaurants with and without online delivery.
SELECT 'Yes' AS Online_Delivery, round(AVG(Aggregate_rating),2) AS Average_Rating
FROM dataset WHERE Has_Online_delivery = 'Yes'
UNION ALL
SELECT 'No' AS Online_Delivery, round(AVG(Aggregate_rating),2) AS Average_Rating
FROM dataset WHERE Has_Online_delivery = 'No';

-- Determine the percentage of restaurants that offer online delivery.
select concat(round(100.00*count(*)/(select count(*) from dataset),2),'%') as percentage_online_delivery from dataset where Has_Online_delivery='Yes';


--  Task 5: Restaurant Ratings
-- Analyze the distribution of aggregate ratings and determine the most common rating range
SELECT Aggregate_rating, COUNT(*) AS rating_count
FROM dataset WHERE Aggregate_rating > 0
GROUP BY Aggregate_rating
ORDER BY Aggregate_rating desc,rating_count DESC limit 5;

-- Calculate the average number of votes received by restaurants.
select Restaurant_Name, round(avg(Votes),0) as avg_votes_restaurant 
from dataset
group by Restaurant_Name
order by avg_votes_restaurant desc
limit 5;

-- Task 6: Cuisine Combination
-- Identify the most common combinations of cuisines in the dataset.
with cte as (select Cuisines,count(Cuisines) as no_of_cuisines_order 
from dataset 
group by Cuisines) select Cuisines as most_common_cuisines from cte order by no_of_cuisines_order desc limit 5 ;

-- Determine if certain cuisine combinations tend to have higher ratings.
SELECT Cuisines, ROUND(AVG(Aggregate_rating), 2) AS average_rating, COUNT(*) AS num_restaurants
FROM dataset
WHERE Aggregate_rating > 0  
GROUP BY Cuisines
HAVING COUNT(*) >= 5         
ORDER BY average_rating DESC,num_restaurants desc limit 5;

select * from dataset;

-- Task 7: Restaurant Chains
-- Identify if there are any restaurant chains present in the dataset.
with cte as (SELECT Restaurant_Name, City, COUNT(*) AS count_in_city
FROM dataset
GROUP BY Restaurant_Name, City
HAVING COUNT(*) > 1
ORDER BY count_in_city DESC) select City,Max(count_in_city) as max_count_in_city from cte  group by City limit 5;

-- Analyze the ratings and popularity of different restaurant chains.
SELECT Restaurant_Name,COUNT(*) AS branch_count,ROUND(AVG(Aggregate_rating), 2) AS avg_rating
FROM dataset
GROUP BY Restaurant_Name
HAVING COUNT(*) > 1 -- Indicates it's a chain
ORDER BY branch_count DESC;

--  Task 8: Restaurant Reviews
-- Analyze the text reviews to identify the most common positive and negative keywords.
select distinct Rating_Text from dataset;
select Rating_Text, count(Rating_Text) as no_rating 
from dataset 
group  by Rating_Text
order by no_rating desc;

-- Calculate the average length of reviews and explore if there is a relationship between review length and rating.
SELECT Aggregate_rating,ROUND(AVG(CHAR_LENGTH(Rating_text)), 2) AS avg_review_length,COUNT(*) AS review_count
FROM dataset
WHERE Rating_text IS NOT NULL AND Rating_text != ''
GROUP BY Aggregate_rating
ORDER BY Aggregate_rating DESC,review_count desc  limit 5;

--  Task 9: Votes Analysis
-- Identify the restaurants with the highest and lowest number of votes.
select max(Votes) as highest_number_of_votes , min(Votes) as lowest_number_of_votes from dataset;
SELECT 'restaurant_highest_number_of_votes',Restaurant_Name, Votes
FROM dataset
WHERE Votes = (SELECT MAX(Votes) FROM dataset)
union all
SELECT 'restaurant_lowest_number_of_votes',Restaurant_Name, Votes
FROM dataset
WHERE Votes = (SELECT min(Votes) FROM dataset);

-- Analyze if there is a correlation between the number of votes and the rating of a restaurant.
SELECT Aggregate_rating,COUNT(*) AS rating_count,SUM(Votes) AS total_votes,ROUND(AVG(Votes), 2) AS avg_votes_per_rating
FROM dataset
GROUP BY Aggregate_rating
ORDER BY Aggregate_rating;

-- Task 10: Price Range vs. Online Delivery and Table Booking
--  Analyze if there is a relationship between the price range and the availability of online delivery and table booking.
with cte as (select Price_range, count(Has_Online_delivery) as no_of_online_delivery from dataset where Has_online_delivery='Yes' group by Price_range) 
, cte1 as (select Price_range, count(Has_Table_booking) as no_of_table_booking from dataset where Has_Table_booking='Yes' group by Price_range) 
select cte.*,sum(cte.no_of_online_delivery)  over(order by cte.Price_range) as cummulative_online_delivery,
cte1.no_of_table_booking,sum(cte1.no_of_table_booking)  over(order by cte1.Price_range) as cummulative_table_booking
from cte1 join cte on cte.Price_range=cte1.Price_range order by cte.Price_range asc ;

-- OR 
SELECT d.Price_range,
    COUNT(CASE WHEN Has_online_delivery = 'Yes' THEN 1 END) AS no_of_online_delivery,
    COUNT(CASE WHEN Has_Table_booking = 'Yes' THEN 1 END) AS no_of_table_booking
FROM dataset as d
GROUP BY d.Price_range
ORDER BY d.Price_range;

--  Determine if higher-priced restaurants are more likely to offer these services.
SELECT Price_range,COUNT(*) AS total_restaurants,COUNT(CASE WHEN Has_online_delivery = 'Yes' THEN 1 END) AS online_delivery_count,
concat(ROUND(100.0 * COUNT(CASE WHEN Has_online_delivery = 'Yes' THEN 1 END) / COUNT(*), 2),'%') AS online_delivery_percentage,
COUNT(CASE WHEN Has_Table_booking = 'Yes' THEN 1 END) AS table_booking_count,
concat(ROUND(100.0 * COUNT(CASE WHEN Has_Table_booking = 'Yes' THEN 1 END) / COUNT(*), 2),'%') AS table_booking_percentage
FROM dataset GROUP BY Price_range
ORDER BY Price_range;








 
 