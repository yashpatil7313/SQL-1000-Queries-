-- Day 56: Advanced Customer Segmentation & RFM Analysis
-- Queries: Q551 to Q560


-- Q551: Find each customer's total number of orders
-- and total spending
SELECT o.customer_id,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC;


-- Q552: Find each customer's last order date
SELECT customer_id,
       MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
ORDER BY last_order_date DESC;


-- Q553: Find customers who have not ordered
-- for more than 90 days from their latest order date
WITH customer_last_order AS (
    SELECT customer_id,
           MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       last_order_date,
       CURRENT_DATE - last_order_date AS days_since_last_order
FROM customer_last_order
WHERE CURRENT_DATE - last_order_date > 90
ORDER BY days_since_last_order DESC;


-- Q554: Create customer segments based on total orders
-- 5+ orders  = Frequent
-- 3-4 orders = Regular
-- 1-2 orders = Occasional
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       total_orders,
       CASE
           WHEN total_orders >= 5 THEN 'Frequent'
           WHEN total_orders >= 3 THEN 'Regular'
           ELSE 'Occasional'
       END AS customer_segment
FROM customer_orders
ORDER BY total_orders DESC;


-- Q555: Create customer segments based on spending
-- >=100000 = Premium
-- >=50000  = Gold
-- >=20000  = Silver
-- <20000   = Bronze
WITH customer_spending AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT customer_id,
       total_spending,
       CASE
           WHEN total_spending >= 100000 THEN 'Premium'
           WHEN total_spending >= 50000 THEN 'Gold'
           WHEN total_spending >= 20000 THEN 'Silver'
           ELSE 'Bronze'
       END AS spending_segment
FROM customer_spending
ORDER BY total_spending DESC;


-- Q556: Calculate Recency, Frequency and Monetary Value
-- for each customer
WITH customer_rfm AS (
    SELECT
        o.customer_id,
        CURRENT_DATE - MAX(o.order_date) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.quantity * oi.price) AS monetary
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT *
FROM customer_rfm
ORDER BY monetary DESC;


-- Q557: Rank customers by Monetary Value
WITH customer_monetary AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS monetary_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT customer_id,
       monetary_value,
       DENSE_RANK() OVER (
           ORDER BY monetary_value DESC
       ) AS monetary_rank
FROM customer_monetary
ORDER BY monetary_rank;


-- Q558: Rank customers by order frequency
WITH customer_frequency AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS order_frequency
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       order_frequency,
       DENSE_RANK() OVER (
           ORDER BY order_frequency DESC
       ) AS frequency_rank
FROM customer_frequency
ORDER BY frequency_rank;


-- Q559: Find customers who are both frequent
-- buyers and high spenders
WITH customer_metrics AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.order_id) AS total_orders,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT customer_id,
       total_orders,
       total_spending
FROM customer_metrics
WHERE total_orders >= 5
  AND total_spending >= 50000
ORDER BY total_spending DESC;


-- Q560: Create an overall customer value segment
-- using both order frequency and spending
WITH customer_metrics AS (
    SELECT o.customer_id,
           COUNT(DISTINCT o.order_id) AS total_orders,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT customer_id,
       total_orders,
       total_spending,
       CASE
           WHEN total_orders >= 5
                AND total_spending >= 100000
                THEN 'VIP Customer'

           WHEN total_orders >= 3
                AND total_spending >= 50000
                THEN 'High Value Customer'

           WHEN total_orders >= 2
                AND total_spending >= 20000
                THEN 'Growing Customer'

           ELSE 'Low Value Customer'
       END AS customer_value_segment
FROM customer_metrics
ORDER BY total_spending DESC;
