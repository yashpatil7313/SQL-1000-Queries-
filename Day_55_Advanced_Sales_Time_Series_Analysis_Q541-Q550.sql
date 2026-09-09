-- Day 55: Advanced Sales Performance & Time-Series Analysis
-- Queries: Q541 to Q550


-- Q541: Find total revenue generated on each day
SELECT o.order_date,
       SUM(oi.quantity * oi.price) AS daily_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY o.order_date;


-- Q542: Find the highest-revenue day
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT order_date,
       revenue
FROM daily_revenue
WHERE revenue = (
    SELECT MAX(revenue)
    FROM daily_revenue
);


-- Q543: Calculate cumulative revenue over time
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT order_date,
       revenue,
       SUM(revenue) OVER (
           ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_date;


-- Q544: Calculate day-over-day revenue change
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT order_date,
       revenue,
       LAG(revenue) OVER (
           ORDER BY order_date
       ) AS previous_day_revenue,
       revenue - LAG(revenue) OVER (
           ORDER BY order_date
       ) AS revenue_change
FROM daily_revenue
ORDER BY order_date;


-- Q545: Calculate day-over-day revenue growth percentage
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
),
revenue_comparison AS (
    SELECT order_date,
           revenue,
           LAG(revenue) OVER (
               ORDER BY order_date
           ) AS previous_revenue
    FROM daily_revenue
)
SELECT order_date,
       revenue,
       previous_revenue,
       ROUND(
           (revenue - previous_revenue) * 100.0
           / NULLIF(previous_revenue, 0),
           2
       ) AS growth_percentage
FROM revenue_comparison
WHERE previous_revenue IS NOT NULL
ORDER BY order_date;


-- Q546: Find the best-selling product for each day
WITH daily_product_sales AS (
    SELECT o.order_date,
           p.product_id,
           p.product_name,
           SUM(oi.quantity) AS quantity_sold
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY o.order_date,
             p.product_id,
             p.product_name
),
ranked_products AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY order_date
               ORDER BY quantity_sold DESC
           ) AS product_rank
    FROM daily_product_sales
)
SELECT order_date,
       product_id,
       product_name,
       quantity_sold
FROM ranked_products
WHERE product_rank = 1
ORDER BY order_date;


-- Q547: Find the top 3 revenue-generating days
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
),
ranked_days AS (
    SELECT *,
           DENSE_RANK() OVER (
               ORDER BY revenue DESC
           ) AS revenue_rank
    FROM daily_revenue
)
SELECT order_date,
       revenue,
       revenue_rank
FROM ranked_days
WHERE revenue_rank <= 3
ORDER BY revenue_rank;


-- Q548: Calculate the average daily revenue
-- and show the difference from the average
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT order_date,
       revenue,
       ROUND(AVG(revenue) OVER (), 2) AS average_daily_revenue,
       ROUND(
           revenue - AVG(revenue) OVER (),
           2
       ) AS difference_from_average
FROM daily_revenue
ORDER BY order_date;


-- Q549: Find the highest-revenue category for each month
WITH monthly_category_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        p.category,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        p.category
),
ranked_categories AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY order_year, order_month
               ORDER BY revenue DESC
           ) AS category_rank
    FROM monthly_category_revenue
)
SELECT order_year,
       order_month,
       category,
       revenue
FROM ranked_categories
WHERE category_rank = 1
ORDER BY order_year, order_month;


-- Q550: Calculate a 3-day moving average of revenue
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
SELECT order_date,
       revenue,
       ROUND(
           AVG(revenue) OVER (
               ORDER BY order_date
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ),
           2
       ) AS three_day_moving_average
FROM daily_revenue
ORDER BY order_date;
