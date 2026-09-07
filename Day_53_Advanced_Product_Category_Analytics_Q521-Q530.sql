-- Day 53: Advanced Product & Category Analytics
-- Queries: Q521 to Q530


-- Q521: Find total quantity sold for each product
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC;


-- Q522: Find the average selling price of each product
SELECT product_id,
       AVG(price) AS average_selling_price
FROM order_items
GROUP BY product_id
ORDER BY average_selling_price DESC;


-- Q523: Find products whose sales quantity is above
-- the average product sales quantity
WITH product_sales AS (
    SELECT product_id,
           SUM(quantity) AS total_quantity
    FROM order_items
    GROUP BY product_id
)
SELECT p.product_id,
       p.product_name,
       ps.total_quantity
FROM product_sales ps
INNER JOIN products p
    ON ps.product_id = p.product_id
WHERE ps.total_quantity > (
    SELECT AVG(total_quantity)
    FROM product_sales
)
ORDER BY ps.total_quantity DESC;


-- Q524: Rank products within each category based on revenue
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
SELECT product_id,
       product_name,
       category,
       total_revenue,
       RANK() OVER (
           PARTITION BY category
           ORDER BY total_revenue DESC
       ) AS product_rank
FROM product_revenue
ORDER BY category, product_rank;


-- Q525: Find the highest-revenue product in each category
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY category
               ORDER BY total_revenue DESC
           ) AS product_rank
    FROM product_revenue
)
SELECT *
FROM ranked_products
WHERE product_rank = 1;


-- Q526: Calculate each product's percentage contribution
-- to its category's total revenue
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity * oi.price) AS revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT product_id,
       product_name,
       category,
       revenue,
       ROUND(
           revenue * 100.0 /
           SUM(revenue) OVER (
               PARTITION BY category
           ),
           2
       ) AS category_revenue_percentage
FROM product_revenue
ORDER BY category, revenue DESC;


-- Q527: Find categories whose revenue is greater than
-- the average category revenue
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.category
)
SELECT category,
       total_revenue
FROM category_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue)
    FROM category_revenue
)
ORDER BY total_revenue DESC;


-- Q528: Find the top 2 products by quantity sold
-- in each category
WITH product_quantity AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity) AS total_quantity
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY category
               ORDER BY total_quantity DESC
           ) AS product_rank
    FROM product_quantity
)
SELECT *
FROM ranked_products
WHERE product_rank <= 2
ORDER BY category, product_rank;


-- Q529: Find products that have never been ordered
SELECT p.product_id,
       p.product_name,
       p.category
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- Q530: Find the category with the highest average
-- product revenue
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           SUM(oi.quantity * oi.price) AS product_revenue
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
category_average AS (
    SELECT category,
           AVG(product_revenue) AS average_product_revenue
    FROM product_revenue
    GROUP BY category
),
ranked_categories AS (
    SELECT *,
           RANK() OVER (
               ORDER BY average_product_revenue DESC
           ) AS category_rank
    FROM category_average
)
SELECT category,
       average_product_revenue,
       category_rank
FROM ranked_categories
WHERE category_rank = 1;
