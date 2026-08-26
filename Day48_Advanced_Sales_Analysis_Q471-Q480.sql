-- Day 48: Advanced Sales Analysis
-- Queries: Q471 to Q480
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- sales(
--     sale_id,
--     customer_id,
--     product_id,
--     category,
--     sale_date,
--     quantity,
--     price
-- )

-- =========================================
-- Q471: Find the top 3 products by total revenue
-- =========================================
SELECT product_id,
       SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 3;


-- =========================================
-- Q472: Find the top-selling product by quantity
-- =========================================
SELECT product_id,
       SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_id
ORDER BY total_quantity DESC
LIMIT 1;


-- =========================================
-- Q473: Find monthly total revenue
-- =========================================
SELECT YEAR(sale_date) AS sale_year,
       MONTH(sale_date) AS sale_month,
       SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sale_year, sale_month;


-- =========================================
-- Q474: Find the month with the highest revenue
-- =========================================
SELECT YEAR(sale_date) AS sale_year,
       MONTH(sale_date) AS sale_month,
       SUM(quantity * price) AS total_revenue
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY total_revenue DESC
LIMIT 1;


-- =========================================
-- Q475: Find customers who spent more than 50000
-- =========================================
SELECT customer_id,
       SUM(quantity * price) AS total_spending
FROM sales
GROUP BY customer_id
HAVING SUM(quantity * price) > 50000;


-- =========================================
-- Q476: Find categories with more than 100 units sold
-- =========================================
SELECT category,
       SUM(quantity) AS total_quantity
FROM sales
GROUP BY category
HAVING SUM(quantity) > 100;


-- =========================================
-- Q477: Find the average revenue per customer
-- =========================================
SELECT AVG(total_spending) AS average_customer_spending
FROM (
    SELECT customer_id,
           SUM(quantity * price) AS total_spending
    FROM sales
    GROUP BY customer_id
) t;


-- =========================================
-- Q478: Find each customer's highest-value transaction
-- =========================================
SELECT customer_id,
       MAX(quantity * price) AS highest_transaction
FROM sales
GROUP BY customer_id;


-- =========================================
-- Q479: Find products that generated revenue above the average product revenue
-- =========================================
WITH product_revenue AS (
    SELECT product_id,
           SUM(quantity * price) AS total_revenue
    FROM sales
    GROUP BY product_id
)
SELECT *
FROM product_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM product_revenue
);


-- =========================================
-- Q480: Rank products by total revenue
-- =========================================
WITH product_revenue AS (
    SELECT product_id,
           SUM(quantity * price) AS total_revenue
    FROM sales
    GROUP BY product_id
)
SELECT product_id,
       total_revenue,
       DENSE_RANK() OVER (
           ORDER BY total_revenue DESC
       ) AS revenue_rank
FROM product_revenue;
