--- create table---
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
	(
	transactions_id	INT PRIMARY KEY,
	sale_date Date,
	sale_time	TIME,
	customer_id  INT,
	gender	VARCHAR(15),
	age	INT,
	category VARCHAR(20),
	quantiy	INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
)

select * from retail_sales limit 10

--------------------
SELECT 
	COUNT(*)
FROM retail_sales

----
SELECT 
	COUNT(DISTINCT customer_id) 
FROM retail_sales
---------------

SELECT 
	COUNT(DISTINCT category) 
FROM retail_sales

------------------
select * from retail_sales

SELECT * FROM retail_sales
	WHERE age IS NULL
	OR
	transactions_id IS NULL
	OR
	quantiy IS NULL

---- deleting the rows with null values in the columns such as 'transaction_id', retail_sale, quantity were null--

DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	quantiy IS NULL

---- Filling the null values in age column with the average age in the dataset---
SELECT *, 
	COALESCE(age, (SELECT ROUND(AVG(age), 0) FROM retail_sales)) AS age 
FROM retail_sales

------------------
-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT * 
FROM retail_sales
WHERE category = 'Clothing'
AND quantiy >= 4
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

select category, sum(total_sale) as net_sale,
count(*) as total_orders
from retail_sales
group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select round(avg(age), 2) as avg_age 
from retail_sales
where category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000
ORDER by total_sale;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT gender, category, COUNT(*) as total_transactions
FROM retail_sales
GROUP BY gender, category
ORDER BY 1;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.

SELECT sale_year, sale_month, avg_sale from 
(SELECT EXTRACT(YEAR from sale_date) as sale_year,
TO_CHAR(sale_date, 'FMMonth') as sale_month, ROUND(AVG(total_sale)) as Avg_sale,
RANK() OVER(PARTITION BY EXTRACT(YEAR from sale_date) ORDER BY AVG(total_sale) DESC) as rnk
from retail_sales
GROUP BY sale_year,sale_month) as t1
WHERE rnk = 1

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

WITH ranked_customer as(
SELECT customer_id, SUM(total_sale) as total_sales,
RANK() OVER(ORDER BY SUM(total_sale) DESC) as rnk 
FROM retail_sales
GROUP BY customer_id)
SELECT customer_id, total_sales FROM ranked_customer 
WHERE rnk <= 5
order by rnk

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select category, COUNT(DISTINCT customer_id) as ctg_count
FROM retail_sales
GROUP BY category

-- Q.10 Write a SQL query to find the number of unique customers who purchased items at least from 2 categories.

WITH catg_count AS (SELECT customer_id, COUNT(DISTINCT category) as ctg_count 
FROM retail_sales
GROUP BY customer_id)

SELECT rs.category, COUNT(DISTINCT cc.customer_id) as customer_count
FROM retail_sales AS rs
JOIN catg_count AS cc
ON rs.customer_id = cc.customer_id
WHERE cc.ctg_count >= 2
GROUP BY rs.category

-- Q.11 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH shift_table as (
SELECT *,
CASE WHEN sale_time <= '12:00:00' THEN 'MORNING'
	WHEN sale_time > '12:00:00' AND sale_time <= '17:00:00' THEN 'AFTERNOON'
	ELSE 'EVENING' END AS Shift
FROM retail_sales)
SELECT shift, count(*) as number_of_orders
FROM shift_table
Group by shift 
order by number_of_orders