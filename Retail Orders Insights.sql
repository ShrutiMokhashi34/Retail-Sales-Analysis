
--Creating the table, then appending the cleaned data fro Python to use less memory
CREATE TABLE retail_orders (
       [order_id] int primary key
      ,[order_date] date
      ,[ship_mode] varchar(20)
      ,[segment] varchar(20)
      ,[country] varchar(20)
      ,[city] varchar(20)
      ,[state] varchar(20)
      ,[postal_code] varchar(20)
      ,[region] varchar(20)
      ,[category] varchar(20)
      ,[sub_category] varchar(20)
      ,[product_id] varchar(50)
      ,[quantity] int
      ,[discount] decimal(7,2)
      ,[sell_price] decimal(7,2)
      ,[profit] decimal(7,2)
	  )


SELECT * FROM retail_orders


--Top 10 Highest Revenue Generating Product Categories

SELECT TOP 10
    category,
    sub_category,
	product_id,
    SUM(quantity * sell_price) AS total_revenue
FROM 
    retail_orders
GROUP BY 
    product_id, category, sub_category
ORDER BY 
    total_revenue DESC;



--Top 5 Highest Selling Products in Each Region

WITH CTE_1 AS (
SELECT region, product_id, category, SUM(quantity * sell_price) AS total_revenue
FROM retail_orders
GROUP BY region, product_id, category)
SELECT * FROM (SELECT * , RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC) AS reg
               FROM CTE_1) A
WHERE reg<=5;



--Month over Month Growth Comparison for 2022 and 2023 Sales
WITH CTE_2 AS(
SELECT 
YEAR(order_date) AS year_order, MONTH(order_date) AS month_order, sum(quantity*sell_price) AS total_revenue
FROM retail_orders
GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT month_order,
SUM(CASE WHEN year_order='2022' THEN total_revenue ELSE 0 END) AS sales_2022,
SUM(CASE WHEN year_order='2023' THEN total_revenue ELSE 0 END) AS sales_2023
FROM CTE_2
GROUP BY month_order
ORDER BY month_order;



--Which Month had the Highest Sales per Category
WITH CTE_3 AS(
SELECT 
category, FORMAT(order_date, 'yyyyMM') AS order_month_year, SUM(quantity*sell_price) AS total_revenue
FROM retail_orders
GROUP BY category, FORMAT(order_date, 'yyyyMM') 
)
SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY category ORDER BY total_revenue) AS Ranking
               FROM CTE_3) B
WHERE Ranking=1;



--Which 2 Sub Categories had Highest Growth in Revenue in 2023 compared to 2022
WITH CTE_4 AS(
SELECT sub_category,
YEAR(order_date) AS year_order, sum(quantity*sell_price) AS total_revenue
FROM retail_orders
GROUP BY sub_category, YEAR(order_date)
)
,CTE_5 AS(
SELECT sub_category,
SUM(CASE WHEN year_order='2022' THEN total_revenue ELSE 0 END) AS salessub_2022,
SUM(CASE WHEN year_order='2023' THEN total_revenue ELSE 0 END) AS salessub_2023
FROM CTE_4
GROUP BY sub_category)
SELECT TOP 2 *, (salessub_2023-salessub_2022) AS YearlyDiff, (salessub_2023-salessub_2022)*100/salessub_2022 AS growth_percent
FROM CTE_5 
ORDER BY (salessub_2023-salessub_2022)*100/salessub_2022 DESC
