-- Day 57: Advanced Order, Product & Cohort Analysis
-- Queries: Q561 to Q570


-- Q561: Find the total number of unique customers
-- who placed orders
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;


-- Q562: Find each customer's first order month
WITH first_orders AS (
    SELECT customer_id,
           MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       EXTRACT(YEAR FROM first_order_date) AS first_order_year,
       EXTRACT(MONTH FROM first_order_date) AS first_order_month
FROM first_orders
ORDER BY first_order_date;


-- Q563: Find the number of customers acquired
-- in each month
WITH first_orders AS (
    SELECT customer_id,
           MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT EXTRACT(YEAR FROM first_order_date) AS order_year,
       EXTRACT(MONTH FROM first_order_date) AS order_month,
       COUNT(*) AS new_customers
FROM first_orders
GROUP BY EXTRACT(YEAR FROM first_order_date),
         EXTRACT(MONTH FROM first_order_date)
ORDER BY order_year, order_month;


-- Q564: Find customers who made their first purchase
-- and then returned for another purchase
WITH numbered_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS order_number
    FROM orders
)
SELECT customer_id,
       MIN(order_date) AS first_order_date,
       MAX(order_date) AS latest_order_date,
       COUNT(*) AS total_orders
FROM numbered_orders
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY total_orders DESC;


-- Q565: Calculate the average number of orders
-- per customer
SELECT ROUND(
           COUNT(order_id) * 1.0 /
           COUNT(DISTINCT customer_id),
           2
       ) AS average_orders_per_customer
FROM orders;


-- Q566: Find products purchased by the highest
-- number of unique customers
SELECT p.product_id,
       p.product_name,
       COUNT(DISTINCT o.customer_id) AS unique_customers
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name
ORDER BY unique_customers DESC;


-- Q567: Find the product purchased by the most
-- unique customers
WITH product_customers AS (
    SELECT p.product_id,
           p.product_name,
           COUNT(DISTINCT o.customer_id) AS unique_customers
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name
)
SELECT *
FROM product_customers
WHERE unique_customers = (
    SELECT MAX(unique_customers)
    FROM product_customers
);


-- Q568: Find customers who purchased from the same
-- category in multiple orders
WITH customer_category_orders AS (
    SELECT o.customer_id,
           p.category,
           COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY o.customer_id, p.category
)
SELECT customer_id,
       category,
       order_count
FROM customer_category_orders
WHERE order_count > 1
ORDER BY customer_id, order_count DESC;


-- Q569: Find the average time between orders
-- for each customer
WITH customer_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_date
    FROM orders
),
order_gaps AS (
    SELECT customer_id,
           order_date - previous_order_date AS days_between_orders
    FROM customer_orders
    WHERE previous_order_date IS NOT NULL
)
SELECT customer_id,
       ROUND(AVG(days_between_orders), 2)
           AS average_days_between_orders
FROM order_gaps
GROUP BY customer_id
ORDER BY average_days_between_orders;


-- Q570: Classify customers based on their purchase frequency
-- Frequent  : 5+ orders
-- Regular   : 3-4 orders
-- Occasional: 1-2 orders
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       total_orders,
       CASE
           WHEN total_orders >= 5 THEN 'Frequent'
           WHEN total_orders >= 3 THEN 'Regular'
           ELSE 'Occasional'
       END AS purchase_frequency
FROM customer_orders
ORDER BY total_orders DESC;
