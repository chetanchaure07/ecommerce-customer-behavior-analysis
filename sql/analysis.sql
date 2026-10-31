-- How many rows are in the orders and customers tables?
SELECT count(*) AS row_count FROM customers;
SELECT count(*) AS row_count FROM orders;

-- Show the first 10 orders?
SELECT * From orders
order by order_date limit 10;

-- What are the distinct product categories?
SELECT DISTINCT(product_category) FROM orders;

-- How many orders are Delivered, Returned and Cancelled?
SELECT order_status, count(*) as Count from orders
group by order_status;

-- What is the total revenue from Delivered orders?
SELECT order_status, SUM(order_total) AS Total from orders
GROUP BY order_status
HAVING order_status = 'Delivered';

-- What are the highest and lowest order totals?
SELECT
min(order_total) AS lowerest_order_total,
max(order_total) AS highest_order_total
from orders;

-- Which orders are above 20,000, highest first?
SELECT * From orders
WHERE order_total > 20000
ORDER BY order_total DESC;

-- How many orders were paid by UPI?
SELECT payment_method, count(*) FROM orders
GROUP BY payment_method
HAVING payment_method = 'UPI';

-- What is the total revenue per category?
SELECT product_category, SUM(order_total) FROM orders
WHERE order_status = 'Delivered'
GROUP BY product_category
ORDER BY sum(order_total) DESC;

-- What is the AOV per category?
SELECT
    product_category,
    ROUND(AVG(order_total), 2) AS aov
FROM orders
WHERE order_status = 'Delivered'
GROUP BY product_category
ORDER BY aov DESC;

-- How many orders are there per payment method?
SELECT payment_method, count(*) AS total_orders FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- How many orders were placed in each year?
SELECT 
	EXTRACT( YEAR FROM order_date) AS order_year,
	count(*) AS order_placed
FROM orders
GROUP BY order_year
ORDER BY order_year DESC;

-- What is the monthly revenue for 2025?
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    ROUND(SUM(order_total), 2) AS monthly_revenue
FROM orders
WHERE order_date >= DATE '2025-01-01'
  AND order_date < DATE '2026-01-01'
  AND order_status = 'Delivered'
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY EXTRACT(MONTH FROM order_date);

-- Which categories have more than 800 orders?
SELECT
	product_category,
	count(*) AS order_count
FROM orders
GROUP BY product_category
HAVING count(*) > 800;

-- How many orders fall into the Low, Medium and High value bands?
SELECT
	CASE
	WHEN order_total < 1000 THEN 'Low'
	WHEN order_total < 10000 THEN 'Medium'
	ELSE 'High'
	END AS value_band,
	count(*) AS total_order
FROM orders
GROUP BY value_band;

-- What is the revenue per city (top 5)?
SELECT 
	c.city,
	sum(o.order_total) AS revenue
FROM orders AS o
JOIN customers AS c
	ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY revenue DESC
LIMIT 5;

-- How many customers and how much revenue does each acquisition channel have?
SELECT c.acquisition_channel,
       COUNT(DISTINCT c.customer_id) AS customers,
       COALESCE(ROUND(SUM(o.order_total), 2), 0) AS revenue
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id AND o.order_status = 'Delivered'
GROUP BY c.acquisition_channel
ORDER BY revenue DESC;


-- Do Prime members have a higher AOV than non-Prime members?
SELECT
	c.is_prime_member,
	ROUND(AVG(o.order_total), 2) AS aov
FROM orders AS o
JOIN customers AS c
	ON o.customer_id = c.customer_id
WHERE order_status = 'Delivered'
GROUP BY c.is_prime_member
ORDER BY aov DESC;

-- What is the return rate per payment method?
SELECT payment_method,
       COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE order_status = 'Returned') AS returned_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE order_status = 'Returned') / COUNT(*), 1) AS return_rate_pct
FROM orders
GROUP BY payment_method
ORDER BY return_rate_pct DESC;

-- Which customers have never placed an order?
SELECT c.customer_id FROM customers AS c
LEFT JOIN orders AS o
	ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;