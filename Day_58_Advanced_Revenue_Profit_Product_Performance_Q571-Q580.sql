-- Day 58: Advanced Revenue, Profit & Product Performance
-- Queries: Q571 to Q580


-- Q571: Calculate total revenue and total profit
-- for each product
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity * oi.price) AS total_revenue,
       SUM(
           oi.quantity * (oi.price - p.cost_price)
       ) AS total_profit
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_profit DESC;


-- Q572: Calculate profit margin for each product
WITH product_profit AS (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity * oi.price) AS revenue,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_id,
       product_name,
       revenue,
       profit,
       ROUND(
           profit * 100.0 /
           NULLIF(revenue, 0),
           2
       ) AS profit_margin_percentage
FROM product_profit
ORDER BY profit_margin_percentage DESC;


-- Q573: Find the most profitable product in each category
WITH product_profit AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id,
             p.product_name,
             p.category
),
ranked_products AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY category
               ORDER BY total_profit DESC
           ) AS profit_rank
    FROM product_profit
)
SELECT *
FROM ranked_products
WHERE profit_rank = 1;


-- Q574: Find products with a profit margin
-- greater than 30%
WITH product_metrics AS (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity * oi.price) AS revenue,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_id,
       product_name,
       revenue,
       profit,
       ROUND(
           profit * 100.0 /
           NULLIF(revenue, 0),
           2
       ) AS profit_margin
FROM product_metrics
WHERE profit * 100.0 / NULLIF(revenue, 0) > 30
ORDER BY profit_margin DESC;


-- Q575: Find total revenue and profit for each category
SELECT p.category,
       SUM(oi.quantity * oi.price) AS total_revenue,
       SUM(
           oi.quantity * (oi.price - p.cost_price)
       ) AS total_profit
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_profit DESC;


-- Q576: Rank categories by total profit
WITH category_profit AS (
    SELECT p.category,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.category
)
SELECT category,
       total_profit,
       RANK() OVER (
           ORDER BY total_profit DESC
       ) AS profit_rank
FROM category_profit
ORDER BY profit_rank;


-- Q577: Find products whose profit is above
-- the average product profit
WITH product_profit AS (
    SELECT p.product_id,
           p.product_name,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT *
FROM product_profit
WHERE total_profit > (
    SELECT AVG(total_profit)
    FROM product_profit
)
ORDER BY total_profit DESC;


-- Q578: Calculate each product's contribution
-- to total company profit
WITH product_profit AS (
    SELECT p.product_id,
           p.product_name,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_id,
       product_name,
       total_profit,
       ROUND(
           total_profit * 100.0 /
           NULLIF(SUM(total_profit) OVER (), 0),
           2
       ) AS profit_contribution_percentage
FROM product_profit
ORDER BY profit_contribution_percentage DESC;


-- Q579: Find the top 3 most profitable products
WITH product_profit AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id,
             p.product_name,
             p.category
),
ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER (
               ORDER BY total_profit DESC
           ) AS profit_rank
    FROM product_profit
)
SELECT *
FROM ranked_products
WHERE profit_rank <= 3
ORDER BY profit_rank;


-- Q580: Classify products based on profit margin
-- >= 40%  = Excellent
-- >= 25%  = Good
-- >= 10%  = Average
-- < 10%   = Low
WITH product_metrics AS (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity * oi.price) AS revenue,
           SUM(
               oi.quantity * (oi.price - p.cost_price)
           ) AS profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_id,
       product_name,
       revenue,
       profit,
       ROUND(
           profit * 100.0 /
           NULLIF(revenue, 0),
           2
       ) AS profit_margin,
       CASE
           WHEN profit * 100.0 / NULLIF(revenue, 0) >= 40
               THEN 'Excellent'
           WHEN profit * 100.0 / NULLIF(revenue, 0) >= 25
               THEN 'Good'
           WHEN profit * 100.0 / NULLIF(revenue, 0) >= 10
               THEN 'Average'
           ELSE 'Low'
       END AS performance
FROM product_metrics
ORDER BY profit_margin DESC;
