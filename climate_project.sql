-- /Users/danielalejandro/Library/DBeaverData/workspace6/General/Scripts/stations_ADVANCED_SQL_QUERIES.sql

-- SQL Challenges 


-- Task 1: How many records are there in the temperature data?

SELECT COUNT(*)
from mean_temperature mt;

-- Task 2: Get a list of all countries included. Remove all duplicates 
-- and sort it alphabetically.

SELECT DISTINCT name 
FROM countries
order by name asc;

-- Task 3: Get the number of weather stations for each country. 
-- Group by the number of stations in descending order!

table countries 
limit 5;

table stations;

SELECT DISTINCT cn
FROM stations
order by cn asc;


select cnt.name, count(st.cn)
from stations st
join countries cnt on st.cn = cnt.alpha2
group by cnt.name
order by count asc;

-- Task 4: What’s the average height of stations in 
-- Switzerland compared to Netherlands?

select cnt.name, avg(st.hight)
from stations st
join countries cnt on st.cn = cnt.alpha2
group by cnt.name
order by avg asc;

select st.cn, st.hight
from stations st
WHERE cn in ('BE') and st.hight < 0;

select cnt.name, avg(st.hight)
from stations st
join countries cnt on st.cn = cnt.alpha2
WHERE cnt.name in ('Netherlands','Switzerland')
group by cnt.name
order by avg asc;

-- Task 5: What is the highest station in Germany?

select st.staid, st.cn, st.hight
from stations st
WHERE cn = 'DE'
group by st.staid,st.cn, st.hight
order by st.hight desc
limit 1;

-- Task 6: What’s the minimum and maximum daily average 
-- temperature ever recorded in Germany?

table mean_temperature
limit 5;


-- ADVANCED SQL QUERIES

-- 1. Take a look at the stationstable:

table stations
limit 5;

-- 2. Add a new column called coordinateswhich is of the datatype POINT:

ALTER TABLE stations ADD coordinates POINT;

table stations 

-- 3. Although the current datatypes of the lat and lon columns are both 
-- VARCHAR, the values are meant to hold the following information:

-- lat : Latitude in degrees:minutes:seconds (+: North, -: South)
-- lon : Longitude in degrees:minutes:seconds (+: East, -: West)

UPDATE stations SET coordinates = (
    point(
        split_part(lat, ':', 1)::numeric + -- the degrees
        split_part(lat, ':', 2)::numeric/60+ -- the minutes divided by 60
        split_part(lat, ':', 3)::numeric/(60*60), -- the seconds divided by 3600 all summed up 
        split_part(lon, ':', 1)::numeric +
        split_part(lon, ':', 2)::numeric/60+
        split_part(lon, ':', 3)::numeric/(60*60)
    )
);


table stations 

-- Advanced SQL Challenges

-- 1. Bucketize tg values. Use CASE to to return a column that will hold the 
-- value hot when the temperature is above 25 degrees, normal when between 
-- 10 and 15 and cold when under 10.

table mean_temperature 
limit 5;

SELECT 
    CASE 
        WHEN tg > 25 THEN 'hot'
        WHEN tg BETWEEN 10 AND 25 THEN 'normal'
        ELSE 'cold' 
    END 
FROM mean_temperature
limit 100;

-- Using GROUP BY and a subquery show the yearly average of the maximum 
-- temperatures of all staions.

select * 
from mean_temperature
limit 5;

SELECT date_part('year', date) AS year,
FROM mean_temperature;

select year, avg(max_tg) as avg_max_tg
from (
SELECT mt.staid, date_part('year', date) AS year, max(mt.tg) as max_tg
FROM mean_temperature mt
group by mt.staid, year
LIMIT 5) avg_tg
group by year 
limit 5;

-- 3. Create derived table that contain yearly temperature averages 
-- for all weather stations:


CREATE TABLE yearly_temperature_averages AS
SELECT mt.staid, date_part('year', date) AS year, trunc(AVG(mt.tg)/10,2) as avg_temperature
FROM mean_temperature mt 
group by mt.staid, year;


table yearly_temperature_averages
limit 5;

table mean_temperature
limit 200;

table stations
limit 50;

table countries 
limit 5;

-- Establishing Primary/ Foreign key relations. 

alter table stations 
add primary key (staid);

alter table mean_temperature
add foreign key (staid) references stations (staid);

alter table countries  
add primary key (alpha2);

alter table stations 
add foreign key (cn) references countries (alpha2);


-- Index creation 

CREATE INDEX idx_date ON mean_temperature(date);


-- The yearly average temp per country:

select yta.staid, yta.year, yta.avg_temperature , cnt.name, cnt.alpha2, cnt.alpha3
from stations st
join countries cnt on st.cn = cnt.alpha2
join yearly_temperature_averages yta on yta.staid= st.staid
where yta.year between'2012' AND '2022';


select yta.staid, yta.year, yta.avg_temperature , cnt.name, cnt.alpha2, cnt.alpha3,
cnt.lat, cnt.lon
from stations st
inner join countries cnt on st.cn = cnt.alpha2
inner join yearly_temperature_averages yta on yta.staid= st.staid
where yta.year between'2012' AND '2022';

