
/* Data Structure
ma_towns
______________________________
|town_id|town_name	|town_type|
______________________________
|  50	|MILFORD	|T 		  |
|  277	|CANTON		|TC       |
|  70	|DALTON		|C        |
______________________________

ma_town_population
________________________
|town_id|pop2010|pop2020|
________________________
|  50	|1566	|1521   |
|  277	|5125	|4750   |
|  70	|1897	|1809   |
________________________


*/

--1 How many towns are there
SELECT 
	COUNT(town_id)
	--could also use COUNT(*) in most cases
FROM ma_towns 

--could use a count(distinct ) if you suspect there is duplicate data

--2) how many towns, cities, town/city hybrids are there

SELECT 
	COUNT(town_id),
	town_type
FROM ma_towns 
GROUP BY town_type
ORDER BY COUNT(town_id) DESC

--3) Which towns (town names) had a population above 20,000 in 2010?


SELECT 
mt.town_name
--if you want the count of the population included just uncomment this
--, mtp.pop2010 
FROM ma_towns AS mt 
	INNER JOIN ma_town_populations AS mtp
	ON mt.town_id = mtp.town_id
	WHERE mtp.pop2010 > '20000'


-- 4)	Which town has the smallest population? (There are several ways to get to this answer. Feel free to do it all in one query, or broken into a few.) 

--I'm assuming you meant population in 2020 here as it's not specified in which decade 

WITH smallest_town (town_id,) AS (
	SELECT 
		town_id,
		rank() OVER (PARTITION BY town_id ORDER BY pop2020 ASC) AS rank
		--the goal of this is to rank the town_ids from smallest to largest so the smallest is rank = 1
	FROM ma_town_populations
	)
SELECT 
town_name
FROM ma_towns AS mt
	INNER JOIN smallest_town AS st 
		ON mt.town_id = st.town_id
		AND st.rank = 1

--you could probably also do it with some sort of nested query in a where clause simliar to "where town_id IN (return only the smallest town id)"

-- 5)	It turns out that some of our census data is missing; i.e., there are towns listed in ma_towns that are not in ma_town_populations. How many towns are missing census data? Which towns are they? 

--I actually noticed this before this question just because the row count was different but didn't want to waste time figuring out which

--this should give you the count
SELECT 
COUNT(town_id) 
FROM ma_towns
WHERE town_id NOT IN (SELECT town_id FROM ma_town_populations)

--this is which towns by name

SELECT 
town_name 
FROM ma_towns
WHERE town_id NOT IN (SELECT town_id FROM ma_town_populations)



-- 6) What was the total population of the towns in our dataset in 2000 and 2010? 

--I'm going to answer this assuming you meant 2010 and 2020 instead since that's what in the dataset 

WITH pop2010 (pop2010) AS (
	SELECT 
		SUM(pop2010) AS pop2010
	FROM ma_town_populations
	),
pop2020 (pop2020) AS (
	SELECT 
		SUM(pop2020) AS pop2020
	FROM ma_town_populations
	)
SELECT 
pop2010 AS "Total 2010 Population",
pop2020 AS "Total 2020 Population"

--I don't believe I need a from clause here since the column names are distinct but I can't run it to check. 

-- 7)	What was the average population in 2000 and 2010? (Average population = total population / count of towns.) Hint: If you only use the population table, you don’t need to worry about excluding towns without population data. Your output should once again have two columns and one row.

WITH average_pop2010 (average_pop2010) AS (
	SELECT 
		AVG(pop2010) AS average_pop2010
	FROM ma_town_populations
	),
average_pop2020 (average_pop2020) AS (
	SELECT 
		AVG(pop2020) AS average_pop2020
	FROM ma_town_populations
	)
SELECT 
average_pop2010,
average_pop2020

--your hint specifically mentioned the formula for population / total so you could do it without the avg function by using sum(pop)/count(town_id) as well


-- 8)	Which towns had a population increase from 2000 to 2010 (pop2010 - pop2000 > 0)?

SELECT 
mt.town_name
FROM ma_town_populations AS mtp 
WHERE mtp.pop2020 > mtp.pop2010 
--alternatively your suggestion 
--WHERE pop2010 - pop2000 > 0
	LEFT JOIN ma_towns AS mt
	ON mtp.town_id = mt.town_id

--if you just want the town_id instead of name you don't need the join, but trying to be consistent with previous questions where you ask for name specifically

-- 9)	Upon first glance, the T, C, and TC designations for town_type don’t make much sense. Run a query on the ma_towns data where you redefine these categories in a new column as follows:
-- ●	T = Town
-- ●	C = City
-- ●	TC = Suburb

--case statement should do the trick

SELECT 
town_name AS "Town",
CASE WHEN town_type = 'T' THEN 'Town'
	WHEN town_type = 'C' THEN 'City'
	WHEN town_type = 'TC' THEN 'Suburb'
		ELSE 'Error - Town Type Unknown'
			END AS "Town_Type"
FROM ma_towns


-- 10) Finally, add another column to your previous output that tells us whether the population Increased, Decreased, or Stayed the Same from 2000 to 2010. If we don’t have the population data for the town, we still want it to appear in the table with the label “Unknown” for population change.

SELECT 
mt.town_name AS "Town",
CASE WHEN mt.town_type = 'T' THEN 'Town'
	WHEN mt.town_type = 'C' THEN 'City'
	WHEN mt.town_type = 'TC' THEN 'Suburb'
		ELSE 'Error - Town Type Unknown'
			END AS "Town_Type",
CASE WHEN mtp.pop2020 > mt.pop2010 THEN 'Increased'
	WHEN mtp.pop2020 < mt.pop2010 THEN 'Decreased'
	WHEN mtp.pop2020 = mt.pop2010 THEN 'Stayed the Same'
		ELSE 'Unknown'
			END AS "Population_Change_2010_to_2020"		
FROM ma_towns AS mt
LEFT JOIN ma_town_populations AS mtp
	ON mt.town_id = mtp.town_id