-- Day 59: Advanced Sales Funnel & Customer Conversion Analysis
-- Queries: Q581 to Q590


-- Q581: Find customers who placed exactly one order
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) = 1;


-- Q582: Find customers who placed 2 or more orders
-- and calculate their repeat purchase rate
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_repeat_customers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM customer_orders),
        2
    ) AS repeat_customer_percentage
FROM customer_orders
WHERE total_orders >= 2;


-- Q583: Find the percentage of customers who
-- placed more than one order
WITH customer_orders AS (
    SELECT customer_id,
           COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT ROUND(
           SUM(
               CASE
                   WHEN total_orders > 1 THEN 1
                   ELSE 0
               END
           ) * 100.0 / COUNT(*),
           2
       ) AS repeat_customer_percentage
FROM customer_orders;


-- Q584: Find customers whose second order value
-- was greater than their first order value
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id,
             o.order_id,
             o.order_date
),
numbered_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS order_number
    FROM order_totals
),
first_second AS (
    SELECT customer_id,
           MAX(
               CASE
                   WHEN order_number = 1
                   THEN order_value
               END
           ) AS first_order_value,
           MAX(
               CASE
                   WHEN order_number = 2
                   THEN order_value
               END
           ) AS second_order_value
    FROM numbered_orders
    GROUP BY customer_id
)
SELECT customer_id,
       first_order_value,
       second_order_value
FROM first_second
WHERE second_order_value > first_order_value;


-- Q585: Calculate the average number of products
-- purchased per order
SELECT ROUND(
           SUM(oi.quantity) * 1.0 /
           COUNT(DISTINCT o.order_id),
           2
       ) AS average_products_per_order
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id;


-- Q586: Find customers whose total spending
-- increased with every consecutive order
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id,
             o.order_id,
             o.order_date
),
comparisons AS (
    SELECT *,
           LAG(order_value) OVER (
               PARTITION BY customer_id
               ORDER BY order_date, order_id
           ) AS previous_order_value
    FROM order_totals
),
customer_check AS (
    SELECT customer_id,
           COUNT(*) AS total_orders,
           SUM(
               CASE
                   WHEN previous_order_value IS NOT NULL
                        AND order_value > previous_order_value
                   THEN 1
                   ELSE 0
               END
           ) AS increasing_orders
    FROM comparisons
    GROUP BY customer_id
)
SELECT customer_id,
       total_orders
FROM customer_check
WHERE total_orders >= 2
  AND increasing_orders = total_orders - 1;


-- Q587: Find the percentage of revenue generated
-- by the top 10% of customers
WITH customer_revenue AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT *,
           NTILE(10) OVER (
               ORDER BY revenue DESC
           ) AS customer_decile
    FROM customer_revenue
)
SELECT ROUND(
           SUM(
               CASE
                   WHEN customer_decile = 1
                   THEN revenue
                   ELSE 0
               END
           ) * 100.0 /
           SUM(revenue),
           2
       ) AS top_10_percent_revenue_share
FROM ranked_customers;


-- Q588: Find the percentage of customers belonging
-- to each spending segment
WITH customer_spending AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
segments AS (
    SELECT customer_id,
           total_spending,
           CASE
               WHEN total_spending >= 100000
                   THEN 'Premium'
               WHEN total_spending >= 50000
                   THEN 'Gold'
               WHEN total_spending >= 20000
                   THEN 'Silver'
               ELSE 'Bronze'
           END AS segment
    FROM customer_spending
)
SELECT segment,
       COUNT(*) AS customer_count,
       ROUND(
           COUNT(*) * 100.0 /
           SUM(COUNT(*)) OVER (),
           2
       ) AS percentage_of_customers
FROM segments
GROUP BY segment
ORDER BY customer_count DESC;


-- Q589: Find customers whose latest order value
-- is below their average order value
WITH order_totals AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id,
             o.order_id,
             o.order_date
),
customer_metrics AS (
    SELECT *,
           AVG(order_value) OVER (
               PARTITION BY customer_id
           ) AS average_order_value,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC, order_id DESC
           ) AS latest_order
    FROM order_totals
)
SELECT customer_id,
       order_id,
       order_value,
       average_order_value
FROM customer_metrics
WHERE latest_order = 1
  AND order_value < average_order_value;


-- Q590: Create a customer loyalty classification
-- based on orders and spending
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
           WHEN total_orders >= 10
                AND total_spending >= 100000
               THEN 'Platinum'

           WHEN total_orders >= 5
                AND total_spending >= 50000
               THEN 'Gold'

           WHEN total_orders >= 3
                AND total_spending >= 20000
               THEN 'Silver'

           ELSE 'Bronze'
       END AS loyalty_level
FROM customer_metrics
ORDER BY total_spending DESC;
