-- Day 51: Advanced E-Commerce SQL
-- Queries: Q501 to Q510

-- Q501: Find total spending of each customer using a CTE
WITH customer_spending AS (
    SELECT o.customer_id,
           SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT c.customer_id,
       c.customer_name,
       cs.total_spending
FROM customers c
INNER JOIN customer_spending cs
    ON c.customer_id = cs.customer_id
ORDER BY cs.total_spending DESC;


-- Q502: Find the highest-spending customer for each month
WITH monthly_customer_sales AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        o.customer_id,
        SUM(oi.quantity * oi.price) AS total_spending
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        o.customer_id
),
ranked_customers AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY order_year, order_month
               ORDER BY total_spending DESC
           ) AS customer_rank
    FROM monthly_customer_sales
)
SELECT *
FROM ranked_customers
WHERE customer_rank = 1;


-- Q503: Find customers who have placed more than one order
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY total_orders DESC;


-- Q504: Find customers whose latest order was cancelled
WITH latest_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC, order_id DESC
           ) AS rn
    FROM orders
)
SELECT c.customer_id,
       c.customer_name,
       lo.order_id,
       lo.order_date,
       lo.status
FROM latest_orders lo
INNER JOIN customers c
    ON lo.customer_id = c.customer_id
WHERE lo.rn = 1
  AND lo.status = 'Cancelled';


-- Q505: Find products whose revenue is greater than
-- the average product revenue
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT *
FROM product_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM product_revenue
)
ORDER BY total_revenue DESC;


-- Q506: Rank categories based on total revenue
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.category
)
SELECT category,
       total_revenue,
       RANK() OVER (
           ORDER BY total_revenue DESC
       ) AS category_rank
FROM category_revenue
ORDER BY category_rank;


-- Q507: Calculate each customer's running total spending
WITH customer_orders AS (
    SELECT
        o.customer_id,
        o.order_date,
        o.order_id,
        SUM(oi.quantity * oi.price) AS order_total
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        o.order_date,
        o.order_id
)
SELECT customer_id,
       order_id,
       order_date,
       order_total,
       SUM(order_total) OVER (
           PARTITION BY customer_id
           ORDER BY order_date, order_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total
FROM customer_orders
ORDER BY customer_id, order_date, order_id;


-- Q508: Calculate month-over-month revenue
WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
)
SELECT order_year,
       order_month,
       revenue,
       LAG(revenue) OVER (
           ORDER BY order_year, order_month
       ) AS previous_month_revenue,
       revenue -
       LAG(revenue) OVER (
           ORDER BY order_year, order_month
       ) AS revenue_change
FROM monthly_revenue
ORDER BY order_year, order_month;


-- Q509: Find each customer's first and latest order date
SELECT customer_id,
       MIN(order_date) AS first_order_date,
       MAX(order_date) AS latest_order_date,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY first_order_date;


-- Q510: Find the top 3 products in each category
WITH product_sales AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY category
               ORDER BY total_revenue DESC
           ) AS product_rank
    FROM product_sales
)
SELECT product_id,
       product_name,
       category,
       total_revenue,
       product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;
