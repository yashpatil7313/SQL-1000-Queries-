-- Day 52: Advanced Customer & Sales Analytics
-- Queries: Q511 to Q520

-- Q511: Find customers who placed at least 3 orders
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) >= 3
ORDER BY total_orders DESC;


-- Q512: Find the average order value for each customer
SELECT o.customer_id,
       AVG(order_total) AS average_order_value
FROM (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) AS order_data
GROUP BY customer_id
ORDER BY average_order_value DESC;


-- Q513: Find customers whose spending is above the average customer spending
WITH customer_spending AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT *
FROM customer_spending
WHERE total_spending > (
    SELECT AVG(total_spending)
    FROM customer_spending
)
ORDER BY total_spending DESC;


-- Q514: Find the second-highest spending customer
WITH customer_spending AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT *,
           DENSE_RANK() OVER (
               ORDER BY total_spending DESC
           ) AS spending_rank
    FROM customer_spending
)
SELECT *
FROM ranked_customers
WHERE spending_rank = 2;


-- Q515: Find each customer's percentage contribution to total revenue
WITH customer_revenue AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT customer_id,
       revenue,
       ROUND(
           revenue * 100.0 /
           SUM(revenue) OVER (),
           2
       ) AS revenue_percentage
FROM customer_revenue
ORDER BY revenue DESC;


-- Q516: Find the highest-value order for each customer
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
ranked_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_total DESC, order_id
           ) AS rn
    FROM order_totals
)
SELECT *
FROM ranked_orders
WHERE rn = 1;


-- Q517: Find customers who purchased products from
-- more than one category
SELECT o.customer_id,
       COUNT(DISTINCT p.category) AS category_count
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY category_count DESC;


-- Q518: Find the most popular product category for each customer
WITH customer_categories AS (
    SELECT o.customer_id,
           p.category,
           SUM(oi.quantity) AS total_quantity
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY o.customer_id, p.category
),
ranked_categories AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY customer_id
               ORDER BY total_quantity DESC
           ) AS category_rank
    FROM customer_categories
)
SELECT *
FROM ranked_categories
WHERE category_rank = 1;


-- Q519: Calculate the difference between each customer's
-- current order and previous order value
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
           ) AS previous_order_total
    FROM order_totals
)
SELECT customer_id,
       order_id,
       order_date,
       order_total,
       previous_order_total,
       order_total - previous_order_total AS difference
FROM order_comparison
ORDER BY customer_id, order_date;


-- Q520: Find the top 5 customers in terms of total revenue
-- and assign their rank
WITH customer_revenue AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
ranked_customers AS (
    SELECT *,
           RANK() OVER (
               ORDER BY total_revenue DESC
           ) AS revenue_rank
    FROM customer_revenue
)
SELECT customer_id,
       total_revenue,
       revenue_rank
FROM ranked_customers
WHERE revenue_rank <= 5
ORDER BY revenue_rank;
