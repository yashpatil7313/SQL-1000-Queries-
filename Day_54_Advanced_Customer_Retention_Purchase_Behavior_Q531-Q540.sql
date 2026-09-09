-- Day 54: Advanced Customer Retention & Purchase Behavior
-- Queries: Q531 to Q540


-- Q531: Find the number of orders placed by each customer
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;


-- Q532: Find customers who placed their first order
-- within the year 2026
WITH first_orders AS (
    SELECT customer_id,
           MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       first_order_date
FROM first_orders
WHERE EXTRACT(YEAR FROM first_order_date) = 2026;


-- Q533: Find customers who placed another order
-- after their first order
WITH customer_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS order_number
    FROM orders
)
SELECT DISTINCT customer_id
FROM customer_orders
WHERE order_number > 1;


-- Q534: Find the number of days between consecutive
-- orders for each customer
WITH customer_orders AS (
    SELECT customer_id,
           order_id,
           order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_date
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date,
       previous_order_date,
       order_date - previous_order_date AS days_between_orders
FROM customer_orders
WHERE previous_order_date IS NOT NULL;


-- Q535: Find customers whose latest order value
-- is greater than their previous order value
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
),
order_comparison AS (
    SELECT *,
           LAG(order_total) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_value,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC, order_id DESC
           ) AS latest_order
    FROM order_totals
)
SELECT customer_id,
       order_id,
       order_total,
       previous_order_value
FROM order_comparison
WHERE latest_order = 1
  AND order_total > previous_order_value;


-- Q536: Find customers with an average order value
-- greater than 10,000
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id
)
SELECT customer_id,
       AVG(order_total) AS average_order_value
FROM order_totals
GROUP BY customer_id
HAVING AVG(order_total) > 10000
ORDER BY average_order_value DESC;


-- Q537: Find each customer's first and second order value
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
),
numbered_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS order_number
    FROM order_totals
)
SELECT customer_id,
       MAX(CASE WHEN order_number = 1
                THEN order_total END) AS first_order_value,
       MAX(CASE WHEN order_number = 2
                THEN order_total END) AS second_order_value
FROM numbered_orders
GROUP BY customer_id;


-- Q538: Find customers who purchased the same product
-- more than once
SELECT o.customer_id,
       oi.product_id,
       COUNT(*) AS purchase_count
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id, oi.product_id
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;


-- Q539: Find customers who purchased products from
-- at least 3 different categories
SELECT o.customer_id,
       COUNT(DISTINCT p.category) AS category_count
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category) >= 3
ORDER BY category_count DESC;


-- Q540: Classify customers based on their total spending
-- High Value   : >= 100000
-- Medium Value : >= 50000
-- Low Value    : < 50000

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
           WHEN total_spending >= 100000 THEN 'High Value'
           WHEN total_spending >= 50000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS customer_segment
FROM customer_spending
ORDER BY total_spending DESC;
