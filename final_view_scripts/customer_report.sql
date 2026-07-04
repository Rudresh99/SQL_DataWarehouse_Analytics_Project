/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

DROP VIEW IF EXISTS Gold_Bara_Project.customer_dashboard;
CREATE VIEW customer_dashboard AS 
-- =======================================================
-- 1. Base Query : Retrive Core Columns from table
-- =======================================================
WITH base_query AS(
	SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) as full_name,
	timestampdiff(YEAR,c.birth_date,NOW()) as age
	FROM Gold_Bara_Project.fact_sales s
	LEFT JOIN Gold_Bara_Project.dim_customer c
	ON c.customer_key = s.customer_key
	WHERE order_date IS NOT NULL)

-- =======================================================
-- 2. Customer Aggeration: Summarize key metric at customer level
-- =======================================================
,customer_segmentation AS (
SELECT 
customer_key,
customer_number,
full_name,
age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(product_key) as total_product,
MAX(order_date) as last_order_date,
TIMESTAMPDIFF(Month,MIN(order_date),MAX(order_date)) as lifespan
FROM base_query
GROUP BY customer_key,full_name,customer_number,age)

SELECT 
customer_key,
customer_number,
full_name,
CASE 
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New Customer'
END as cust_category,
total_orders,
total_sales,
total_quantity,
total_product,
last_order_date,
TIMESTAMPDIFF(Month,last_order_date,NOW()) as receny,
lifespan,
CASE 
	WHEN age BETWEEN 20 and 30 THEN 'Age 20-30'
	WHEN age BETWEEN 30 and 40 THEN 'Age 30-40'
    WHEN age BETWEEN 40 and 50 THEN 'Age 40-50'
    ELSE '50 and Above'
END as age_group,
-- Compute average order value
CASE
	WHEN total_sales = 0 THEN 0
	ELSE ROUND(total_sales/total_orders,2)
END as avg_order_value,
-- Compute Average monthly spend
CASE
	WHEN lifespan = 0 THEN total_sales
    ELSE ROUND(total_sales/lifespan,2)
END as avg_monthly_spend 
FROM customer_segmentation;





