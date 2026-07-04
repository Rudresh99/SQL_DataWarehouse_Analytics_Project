-- ## Change over time Trends
-- Find the sales performance over time
SELECT 
DATE_FORMAT(order_date, '%Y %m') as order_month, 
SUM(sales_amount) as total_revenue,
COUNT(DISTINCT(customer_key)) as total_customer
FROM Gold_Bara_Project.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

-- ## Cummulative Analysis
-- Calculate the total sales per month and the running total of sales over time
 SELECT order_month,total_revenue,
SUM(total_revenue) OVER(ORDER BY order_month) as running_total
 FROM
 (SELECT
 DATE_FORMAT(order_date, '%Y %m') as order_month,
 SUM(sales_amount) as total_revenue
 FROM Gold_Bara_Project.fact_sales
 WHERE order_date IS NOT NULL
 GROUP BY DATE_FORMAT(order_date, '%Y %m'))t;
 
 -- ## Performance Analysis
 -- Analyse the yearly performance of product by comparing each product's sales to both average sales performance and the previous year's sales 
WITH yearly_product_sales AS(
SELECT 
DATE_FORMAT(s.order_date,'%Y') order_year,
p.product_name as product_name,
SUM(s.sales_amount) as current_sales
FROM Gold_Bara_Project.fact_sales s
LEFT JOIN Gold_Bara_Project.dim_products p
ON p.product_key = s.product_key
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(s.order_date,'%Y'),p.product_name)

SELECT 
order_year,
product_name,
current_sales,
ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) as avg_sales,
current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) as diff_avg,
CASE 
	WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) >= ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) THEN 'Above/Metting Average'
    WHEN current_sales - ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) < ROUND(AVG(current_sales) OVER(PARTITION BY product_name)) THEN 'Below Average'
    ELSE 'N/a'
END as Avg_criteria,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) as previous_yr_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) as diff_previous_year_sales,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increased'
     WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decreased'
     ELSE 'No Change'
END as Sales_change_status -- Year Over Year Analysis
FROM yearly_product_sales
ORDER BY product_name,order_year;

-- ## Part-To-Whole Analysis
-- Which category contribute the most to the overall sales
WITH category_sale AS(
SELECT
p.category as category,
SUM(s.sales_amount) as total_sale
FROM Gold_Bara_Project.fact_sales s
LEFT JOIN Gold_Bara_Project.dim_products p
ON p.product_key = s.product_key
GROUP BY p.category
ORDER BY p.category)

SELECT  
category,
total_sale,
SUM(total_sale) OVER() as overall_sale,
CONCAT(ROUND((total_sale / SUM(total_sale) OVER())*100,2),'%') as category_percentage
FROM category_sale
ORDER BY category_percentage DESC;

-- Data Segmentation
-- Segment product into cost range and count how many product fall under each segment
SELECT 
cost_range,
COUNT(product_key) as total_product
FROM 
(SELECT
product_key, 
product_name,
cost,
CASE WHEN cost < 100 THEN '0-100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 501 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END as cost_range
FROM Gold_Bara_Project.dim_products) t
GROUP BY cost_range
ORDER BY total_product DESC;

-- Group customer into 3 segment based on their spending behaivour
-- VIP: Customer who has 12 months of history and spend more than $5000
-- Regular : Customer who has 12 months of history and spend $ 5000 or less.
-- New: Newlife span customer or less then 12 months of history
-- find the total number of customers by each group
WITH cust_spending AS(
	SELECT
	c.customer_key,
	MIN(s.order_date) as first_order_dt,
	MAX(s.order_date) as last_order_dt,
	SUM(s.sales_amount) as total_spending,
	timestampdiff(Month,MIN(s.order_date),MAX(s.order_date)) as lifespan
	FROM Gold_Bara_Project.fact_sales s
	LEFT JOIN Gold_Bara_Project.dim_customer c
	ON c.customer_key = s.customer_key
	GROUP BY c.customer_key)

SELECT 
cust_category,
COUNT(customer_key) as total_customer 
FROM(
		SELECT 
		customer_key,
		total_spending,
		lifespan,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New Customer'
		END as cust_category
		FROM cust_spending)t
GROUP BY cust_category
ORDER BY total_customer DESC; 















