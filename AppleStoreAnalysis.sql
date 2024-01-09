CREATE TABLE appleStore_description_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL 
SELECT * FROM appleStore_description3
UNION ALL 
SELECT * FROM appleStore_description4

*EXPLORATORY DATA ANALYSIS*
--Check the number of unique apps in both tableAppleStore
SELECT count(DISTINCT id) as UniqueAppIDs
FROM AppleStore
SELECT count(DISTINCT id) as UniqueAppIDs
FROM appleStore_description_combined
-- check for any missing values in key fields
SELECT COUNT(*) as MissingValues
FROM AppleStore
WHERE track_name is null or user_rating is null OR prime_genre is NULL
SELECT COUNT(*) as MissingValues
FROM appleStore_description_combined
WHERE app_desc is NULL
-- Find out the numer of apps per genre 
SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
group by prime_genre
order BY NumApps DESC
-- Get an overview of the apps ratings
SELECT min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
 FROM AppleStore      
 --Get distribution of app prices
 SELECT
 (price/2) * 2 AS PriceBinStart,
  ((price/2) * 2) + 2  AS PriceBinStart,
  COUNT(*) AS NumApps
  FROM AppleStore
  GROUP BY  PriceBinStart
  ORDER BY PriceBinStart
  **Data Analysis**
 --Determine whether paid apps have higher ratings than free apps
 SELECT CASE
 WHEN price > 0 THEN 'Paid'
 else 'Free'
 END AS App_Type,
 avg(user_rating) as Avg_Rating
 FROM AppleStore
 GROUP by App_Type
--Check if apps with more languages have higher rating--
select CASE
 when lang_num < 10 THEN '<10 languages'
 WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
 ELSE '>30 languages'
 end as language_bucket,
 avg(user_rating) as Avg_Rating
FROM AppleStore
GROUP BY language_bucket
order by Avg_Rating DESC
--Check Genres with low ratings
SELECT prime_genre,
avg(user_rating)  as Avg_Rating
From AppleStore
group by prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10 
--Check if there is a correlation between the length of app description and the user ratingAppleStore
Select case 

when length (b.app_desc) < 500 then 'Short'
when length (b.app_desc) BETWEEN 500 AND 1000 then 'Medium'
else 'Long'
end  as description_length_bucket,
avg(a.user_rating) as average_rating

FROM AppleStore AS A 
JOIN appleStore_description_combined as b
ON
a.id = b.id
GROUP by description_length_bucket
ORDER BY average_rating DESC 
--Check the top rated app for each genre
SELECT
prime_genre,
track_name,
user_rating
FROM ( 
  SELECT
  prime_genre,
  track_name,
  user_rating,
  RANK  () OVER (Partition by prime_genre order by user_rating desc, rating_count_tot DESC) AS rank
  from 
  AppleStore
     ) as a 
  where 
  a.rank = 1 
