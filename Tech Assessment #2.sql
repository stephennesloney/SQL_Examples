/*
Question 2 | SQL Knowledge 
Using the 3 tables below, please answer the following questions: 

1. Top 3 product categories in GMV (sum of price) from last month 
2. Categories that have GMV (sum of price) > $1,000,000 from last month 
3. Weekly percentage of new registered customers who purchased within 7 days of registration 
4. Daily average order size (GMV / total orders) by new customers vs. returning customers?[New customer is defined as customer purchased on the same day as registration] 

Table Name: orders
Column Name 
Data Type 
Description
buyer_id 
integer 
ID of the buyer
seller_id 
integer 
ID of the seller
product_id 
string 
ID of the product
timestamp 
datetime 
Timestamp of the order
price 
float 
Price of the product



Table Name: product 
Column Name 
Data Type 
Description
product_id 
integer 
ID of the product
category_id 
integer 
ID of the product category
brand_id 
integer 
ID of the product brand
category_name 
string 
name of the product category



Table Name: Users
Column Name 
Data Type 
Description
user_id 
integer 
ID of the user
created 
timestamp 
Timestamp of user registered
device 
String 
Device that user registered on (ios, android, web)

*/






--This assessment was not given a specific SQL version to code in. I used Snowflake commonly so that's the version I typically think in and what I used here. 
--1

SELECT
	SUM(o.price),
	p.category_name
FROM orders AS o
LEFT JOIN product AS p
	ON	o.product_id = p.product_id
WHERE date_trunc(month,o.timestamp) = ( DATE_TRUNC(month,DATEADD(month,-1,current_date)) )
GROUP BY p.category_name
ORDER BY SUM(o.price) DESC
LIMIT 3



--2
SELECT
	SUM(o.price),
	p.category_name
FROM orders AS o
LEFT JOIN product AS p
	ON	o.product_id = p.product_id
WHERE date_trunc(month,o.timestamp) = ( DATE_TRUNC(month,DATEADD(month,-1,current_date)) )
GROUP BY p.category_name
HAVING SUM(o.price) > 1000000 
ORDER BY SUM(o.price) DESC
--LIMIT 3



--3
--ranking all orders by users where rank = 1 is their first order date
WITH first_order_date AS (
	SELECT 
		ROW_NUMBER() OVER(PARTION BY buyer_id ORDER BY "timestamp" ASC) AS rank,
		buyer_id,
		"timestamp" AS order_date
	FROM orders	AS o
),
--getting a list of all users and their account registration date
registration_date AS (
	SELECT 
		user_id,
		created
		FROM "Users"
)
--joining the date to the users to see compare order date and 
SELECT
	DATE_TRUNC(week,r.created),
--	weekly % is count of people who bought / count of people who registered. Error checking for nulls just not counting (if you don't have a first order date you didn't buy)
	COUNT(CASE WHEN f.order_date IS NULL THEN 0
				WHEN DATE_TRUNC(day, f.order_date)-DATE_TRUNC(date,r.created) < 7 THEN 1
				ELSE 0 END) / COUNT(*) AS weekly_percent_of_registered_users_who_bought_within_7_days
FROM registration_date AS r
LEFT JOIN first_order_date AS f
	ON buyer_id = user_id AND rank = 1
GROUP BY DATE_TRUNC(week,r.created)
ORDER BY DATE_TRUNC(week,r.created) ASC




--4
SELECT 
date_trunc(day,o."timestamp"),
--this decides if the user is new or returning by comparing the date the account was created with the date of the order
CASE WHEN date_trunc(day,u.created) = date_trunc(day,o."timestamp") THEN 'New Customer' ELSE 'Returning Customer' END AS "customer_type",
--calculates the average order size. Typically I would use the order ID for the denomenator because sometimes that's not distinct in a transaction table. Either the products are many to 1 or the order id isn't the primary key. 
SUM(price)/count(*) AS "daily_average_order_size"
FROM orders o
--join to users table to pull in each order's account created date to compare with the order date
LEFT JOIN "Users" u ON o.buyer_id = u.created
GROUP BY 2,1
ORDER BY 1 ASC
